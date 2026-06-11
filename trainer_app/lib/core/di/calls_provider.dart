import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hmssdk_flutter/hmssdk_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/session_log_model.dart';

enum CallStatus { idle, connecting, joined, reconnecting, disconnected, error }

class CallState {
  final CallStatus status;
  final HMSPeer? localPeer;
  final HMSPeer? remotePeer;
  final HMSVideoTrack? localVideoTrack;
  final HMSVideoTrack? remoteVideoTrack;
  final bool isLocalAudioMuted;
  final bool isLocalVideoMuted;
  final String? errorMessage;

  CallState({
    required this.status,
    this.localPeer,
    this.remotePeer,
    this.localVideoTrack,
    this.remoteVideoTrack,
    required this.isLocalAudioMuted,
    required this.isLocalVideoMuted,
    this.errorMessage,
  });

  CallState copyWith({
    CallStatus? status,
    HMSPeer? localPeer,
    HMSPeer? remotePeer,
    HMSVideoTrack? localVideoTrack,
    HMSVideoTrack? remoteVideoTrack,
    bool? isLocalAudioMuted,
    bool? isLocalVideoMuted,
    String? errorMessage,
    bool clearRemotePeer = false,
    bool clearLocalVideoTrack = false,
    bool clearRemoteVideoTrack = false,
  }) {
    return CallState(
      status: status ?? this.status,
      localPeer: localPeer ?? this.localPeer,
      remotePeer: clearRemotePeer ? null : remotePeer ?? this.remotePeer,
      localVideoTrack: clearLocalVideoTrack ? null : localVideoTrack ?? this.localVideoTrack,
      remoteVideoTrack: clearRemoteVideoTrack ? null : remoteVideoTrack ?? this.remoteVideoTrack,
      isLocalAudioMuted: isLocalAudioMuted ?? this.isLocalAudioMuted,
      isLocalVideoMuted: isLocalVideoMuted ?? this.isLocalVideoMuted,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class CallsNotifier extends StateNotifier<CallState> implements HMSUpdateListener {
  late HMSSDK _hmsSdk;
  Future<void>? _initFuture;
  DateTime? _startedAt;

  CallsNotifier()
      : super(CallState(
          status: CallStatus.idle,
          isLocalAudioMuted: false,
          isLocalVideoMuted: false,
        )) {
    _hmsSdk = HMSSDK();
  }

  Future<void> init() async {
    if (_initFuture != null) return _initFuture;
    _initFuture = _init();
    return _initFuture;
  }

  Future<void> _init() async {
    await _hmsSdk.build();
    _hmsSdk.addUpdateListener(listener: this);
  }

  Future<void> joinRoom({required String userName, required String token}) async {
    await init();
    state = state.copyWith(status: CallStatus.connecting);
    _startedAt = DateTime.now();
    final config = HMSConfig(
      authToken: token,
      userName: userName,
    );
    await _hmsSdk.join(config: config);
  }

  Future<void> leaveRoom({
    required String requestId,
    required String memberId,
    required String trainerId,
  }) async {
    try {
      await _hmsSdk.leave();
      await _saveSessionLog(requestId, memberId, trainerId);
    } catch (e) {
      state = state.copyWith(status: CallStatus.error, errorMessage: e.toString());
    }
    state = CallState(
      status: CallStatus.idle,
      isLocalAudioMuted: false,
      isLocalVideoMuted: false,
    );
  }

  Future<void> toggleAudio() async {
    final isMuted = !state.isLocalAudioMuted;
    final error = await _hmsSdk.toggleMicMuteState();
    if (error != null) {
      state = state.copyWith(status: CallStatus.error, errorMessage: error.message);
      return;
    }
    state = state.copyWith(isLocalAudioMuted: isMuted);
  }

  Future<void> toggleVideo() async {
    final isMuted = !state.isLocalVideoMuted;
    final error = await _hmsSdk.toggleCameraMuteState();
    if (error != null) {
      state = state.copyWith(status: CallStatus.error, errorMessage: error.message);
      return;
    }
    state = state.copyWith(isLocalVideoMuted: isMuted);
  }

  Future<void> flipCamera() => _hmsSdk.switchCamera();

  Future<void> _saveSessionLog(String requestId, String memberId, String trainerId) async {
    if (_startedAt == null) return;
    final endedAt = DateTime.now();
    final duration = endedAt.difference(_startedAt!).inSeconds;

    final sessionLog = SessionLogModel(
      id: requestId,
      memberId: memberId,
      trainerId: trainerId,
      startedAt: _startedAt!,
      endedAt: endedAt,
      durationSec: duration,
      rating: 5,
      trainerNotes: "Completed video coaching session.",
    );

    try {
      // Save locally to Hive
      final box = Hive.box('sessionLogs');
      await box.put(sessionLog.id, sessionLog.toMap());

      // Sync to Firestore remotely
      await FirebaseFirestore.instance
          .collection('sessionLogs')
          .doc(sessionLog.id)
          .set(sessionLog.toMap());
    } catch (e) {
      state = state.copyWith(status: CallStatus.error, errorMessage: e.toString());
    }
  }

  // HMSUpdateListener Overrides
  @override
  void onJoin({required HMSRoom room}) {
    HMSPeer? local;
    HMSPeer? remote;
    for (final peer in room.peers ?? <HMSPeer>[]) {
      if (peer.isLocal) {
        local = peer;
      } else {
        remote ??= peer;
      }
    }
    state = state.copyWith(
      status: CallStatus.joined,
      localPeer: local,
      remotePeer: remote,
    );
  }

  @override
  void onRoomUpdate({required HMSRoom room, required HMSRoomUpdate update}) {}

  @override
  void onPeerUpdate({required HMSPeer peer, required HMSPeerUpdate update}) {
    if (peer.isLocal) {
      if (update == HMSPeerUpdate.peerJoined) {
        state = state.copyWith(localPeer: peer);
      }
    } else {
      if (update == HMSPeerUpdate.peerJoined) {
        state = state.copyWith(remotePeer: peer);
      } else if (update == HMSPeerUpdate.peerLeft) {
        state = state.copyWith(clearRemotePeer: true, clearRemoteVideoTrack: true);
      }
    }
  }

  @override
  void onTrackUpdate({
    required HMSTrack track,
    required HMSTrackUpdate trackUpdate,
    required HMSPeer peer,
  }) {
    if (track.kind == HMSTrackKind.kHMSTrackKindVideo && track is HMSVideoTrack) {
      if (peer.isLocal) {
        if (trackUpdate == HMSTrackUpdate.trackRemoved) {
          state = state.copyWith(clearLocalVideoTrack: true);
        } else {
          state = state.copyWith(localVideoTrack: track);
        }
      } else {
        if (trackUpdate == HMSTrackUpdate.trackAdded) {
          state = state.copyWith(
            remoteVideoTrack: track,
            remotePeer: peer,
          );
        } else if (trackUpdate == HMSTrackUpdate.trackRemoved) {
          state = state.copyWith(clearRemoteVideoTrack: true);
        }
      }
    }
  }

  @override
  void onHMSError({required HMSException error}) {
    state = state.copyWith(
      status: CallStatus.error,
      errorMessage: error.message,
    );
  }

  @override
  void onMessage({required HMSMessage message}) {}

  @override
  void onUpdateSpeakers({required List<HMSSpeaker> updateSpeakers}) {}

  @override
  void onReconnecting() {
    state = state.copyWith(status: CallStatus.reconnecting);
  }

  @override
  void onReconnected() {
    state = state.copyWith(status: CallStatus.joined);
  }

  @override
  void onRoleChangeRequest({required HMSRoleChangeRequest roleChangeRequest}) {}

  @override
  void onChangeTrackStateRequest({required HMSTrackChangeRequest hmsTrackChangeRequest}) {}

  @override
  void onRemovedFromRoom({required HMSPeerRemovedFromPeer hmsPeerRemovedFromPeer}) {
    state = state.copyWith(status: CallStatus.disconnected);
  }

  @override
  void onAudioDeviceChanged({HMSAudioDevice? currentAudioDevice, List<HMSAudioDevice>? availableAudioDevice}) {}

  @override
  void onSessionStoreAvailable({HMSSessionStore? hmsSessionStore}) {}

  @override
  void onPeerListUpdate({required List<HMSPeer> addedPeers, required List<HMSPeer> removedPeers}) {
    for (final peer in addedPeers) {
      if (peer.isLocal) {
        state = state.copyWith(localPeer: peer);
      } else {
        state = state.copyWith(remotePeer: peer);
      }
    }
    if (removedPeers.any((peer) => !peer.isLocal)) {
      state = state.copyWith(clearRemotePeer: true, clearRemoteVideoTrack: true);
    }
  }
}

final callsProvider = StateNotifierProvider<CallsNotifier, CallState>((ref) {
  final notifier = CallsNotifier();
  notifier.init();
  return notifier;
});
