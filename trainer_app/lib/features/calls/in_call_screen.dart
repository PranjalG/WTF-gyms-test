import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hmssdk_flutter/hmssdk_flutter.dart';

import '../../core/di/calls_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../models/call_request_model.dart';

class InCallScreen extends ConsumerStatefulWidget {
  final CallRequestModel call;
  final String token;
  final String userName;
  final bool micOn;
  final bool cameraOn;

  const InCallScreen({
    super.key,
    required this.call,
    required this.token,
    required this.userName,
    required this.micOn,
    required this.cameraOn,
  });

  @override
  ConsumerState<InCallScreen> createState() => _InCallScreenState();
}

class _InCallScreenState extends ConsumerState<InCallScreen> {
  bool _joiningStarted = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _join());
  }

  Future<void> _join() async {
    if (_joiningStarted) return;
    _joiningStarted = true;
    final notifier = ref.read(callsProvider.notifier);
    await notifier.joinRoom(userName: widget.userName, token: widget.token);
    if (!widget.micOn) {
      await notifier.toggleAudio();
    }
    if (!widget.cameraOn) {
      await notifier.toggleVideo();
    }
  }

  @override
  Widget build(BuildContext context) {
    final callState = ref.watch(callsProvider);

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppTheme.grey900,
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Row(
                  children: [
                    const Icon(Icons.video_call, color: Colors.white),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _statusText(callState.status),
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
              if (callState.status == CallStatus.reconnecting)
                const LinearProgressIndicator(color: AppTheme.warning, minHeight: 3),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: GridView.count(
                    crossAxisCount: 1,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.82,
                    children: [
                      _ParticipantTile(
                        name: widget.userName,
                        track: callState.localVideoTrack,
                        isMuted: callState.isLocalVideoMuted,
                        isLocal: true,
                      ),
                      _ParticipantTile(
                        name: callState.remotePeer?.name ?? 'Waiting for the other person',
                        track: callState.remoteVideoTrack,
                        isMuted: false,
                        isLocal: false,
                      ),
                    ],
                  ),
                ),
              ),
              if (callState.errorMessage != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(callState.errorMessage!, style: const TextStyle(color: AppTheme.error)),
                ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 18),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _RoundCallButton(
                      icon: callState.isLocalAudioMuted ? Icons.mic_off : Icons.mic,
                      label: callState.isLocalAudioMuted ? 'Unmute' : 'Mute',
                      onPressed: () => ref.read(callsProvider.notifier).toggleAudio(),
                    ),
                    _RoundCallButton(
                      icon: callState.isLocalVideoMuted ? Icons.videocam_off : Icons.videocam,
                      label: callState.isLocalVideoMuted ? 'Video on' : 'Video off',
                      onPressed: () => ref.read(callsProvider.notifier).toggleVideo(),
                    ),
                    _RoundCallButton(
                      icon: Icons.flip_camera_ios,
                      label: 'Flip',
                      onPressed: () => ref.read(callsProvider.notifier).flipCamera(),
                    ),
                    _RoundCallButton(
                      icon: Icons.call_end,
                      label: 'End',
                      color: AppTheme.error,
                      onPressed: _leave,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _statusText(CallStatus status) {
    switch (status) {
      case CallStatus.connecting:
        return 'Connecting to 100ms...';
      case CallStatus.joined:
        return 'Live call';
      case CallStatus.reconnecting:
        return 'Reconnecting...';
      case CallStatus.disconnected:
        return 'Disconnected';
      case CallStatus.error:
        return 'Call error';
      case CallStatus.idle:
        return 'Starting call...';
    }
  }

  Future<void> _leave() async {
    await ref.read(callsProvider.notifier).leaveRoom(
          requestId: widget.call.id,
          memberId: widget.call.memberId,
          trainerId: widget.call.trainerId,
        );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Session saved to your logs.')),
    );
    context.go('/home');
  }
}

class _ParticipantTile extends StatelessWidget {
  final String name;
  final HMSVideoTrack? track;
  final bool isMuted;
  final bool isLocal;

  const _ParticipantTile({
    required this.name,
    required this.track,
    required this.isMuted,
    required this.isLocal,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        color: AppTheme.grey800,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (track != null && !isMuted)
              HMSVideoView(track: track!, setMirror: isLocal)
            else
              const Center(
                child: Icon(Icons.person, color: Colors.white54, size: 64),
              ),
            Positioned(
              left: 12,
              right: 12,
              bottom: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoundCallButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final Color? color;

  const _RoundCallButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final buttonColor = color ?? Colors.white.withValues(alpha: 0.12);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton.filled(
          onPressed: onPressed,
          icon: Icon(icon),
          style: IconButton.styleFrom(
            backgroundColor: buttonColor,
            foregroundColor: Colors.white,
            fixedSize: const Size(52, 52),
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
      ],
    );
  }
}
