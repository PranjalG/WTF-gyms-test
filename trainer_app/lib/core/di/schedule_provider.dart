import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:trainer_app/models/call_request_model.dart';
import 'package:uuid/uuid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth_provider.dart';

const uuid = Uuid();

/// All pending call requests for trainer
final pendingCallRequestsProvider =
    StreamProvider.family<List<CallRequestModel>, String>(
  (ref, trainerId) async* {
    final requestsBox = Hive.box('callRequests');

    List<CallRequestModel> getRequests() {
      final requests = requestsBox.values
          .map(
            (r) => CallRequestModel.fromMap(
              Map<String, dynamic>.from(r as Map),
            ),
          )
          .where(
            (req) => req.trainerId == trainerId && req.status == 'pending',
          )
          .toList();

      requests.sort(
        (a, b) => a.scheduledFor.compareTo(b.scheduledFor),
      );

      return requests;
    }

    // Emit immediately
    yield getRequests();

    // Emit on changes
    yield* requestsBox.watch().map((_) => getRequests());
  },
);

/// All scheduled calls for user (member or trainer)
final scheduledCallsProvider =
    StreamProvider.family<List<CallRequestModel>, String>(
  (ref, userId) async* {
    final requestsBox = Hive.box('callRequests');

    List<CallRequestModel> getCalls() {
      final calls = requestsBox.values
          .map(
            (r) => CallRequestModel.fromMap(
              Map<String, dynamic>.from(r as Map),
            ),
          )
          .where(
            (req) =>
                (req.memberId == userId || req.trainerId == userId) &&
                (req.status == 'approved' || req.status == 'pending'),
          )
          .toList();

      calls.sort(
        (a, b) => a.scheduledFor.compareTo(b.scheduledFor),
      );

      return calls;
    }

    // Emit current data immediately
    yield getCalls();

    // Emit future updates
    yield* requestsBox.watch().map((_) => getCalls());
  },
);

/// Unread pending request count
final pendingRequestCountProvider =
    StreamProvider.family<int, String>((ref, trainerId) {
  final requestsBox = Hive.box('callRequests');

  return requestsBox.watch().map((_) {
    final pendingCount = requestsBox.values
        .whereType<Map>()
        .map((r) => CallRequestModel.fromMap(Map<String, dynamic>.from(r)))
        .where((req) => req.trainerId == trainerId && req.status == 'pending')
        .length;

    return pendingCount;
  });
});

/// Provider to initialize remote Firestore listener for call requests
final syncCallRequestsProvider =
    StreamProvider.family<void, String>((ref, userId) {
  final firestore = FirebaseFirestore.instance;
  final requestsBox = Hive.box('callRequests');

  // Listen for call requests where the current user is the member
  final memberSub = firestore
      .collection('callRequests')
      .where('trainerId', isEqualTo: userId)
      .snapshots()
      .listen((snapshot) {
    for (var change in snapshot.docChanges) {
      final data = change.doc.data();
      if (data != null) {
        final Map<String, dynamic> requestMap = Map<String, dynamic>.from(data);
        // Convert Firestore Timestamps back to ISO Strings for Hive compatibility
        if (data['requestedAt'] is Timestamp) {
          requestMap['requestedAt'] =
              (data['requestedAt'] as Timestamp).toDate().toIso8601String();
        }
        if (data['scheduledFor'] is Timestamp) {
          requestMap['scheduledFor'] =
              (data['scheduledFor'] as Timestamp).toDate().toIso8601String();
        }
        requestsBox.put(data['id'], requestMap);
      }
    }
  });

  // Listen for call requests where the current user is the trainer
  final trainerSub = firestore
      .collection('callRequests')
      .where('trainerId', isEqualTo: userId)
      .snapshots()
      .listen((snapshot) {
    for (var change in snapshot.docChanges) {
      final data = change.doc.data();
      if (data != null) {
        final Map<String, dynamic> requestMap = Map<String, dynamic>.from(data);
        if (data['requestedAt'] is Timestamp) {
          requestMap['requestedAt'] =
              (data['requestedAt'] as Timestamp).toDate().toIso8601String();
        }
        if (data['scheduledFor'] is Timestamp) {
          requestMap['scheduledFor'] =
              (data['scheduledFor'] as Timestamp).toDate().toIso8601String();
        }
        requestsBox.put(data['id'], requestMap);
      }
    }
  });

  ref.onDispose(() {
    memberSub.cancel();
    trainerSub.cancel();
  });

  return const Stream.empty();
});

final requestCallProvider = FutureProvider.family<
    void,
    (
      String trainerId,
      DateTime scheduledFor,
      String note
    )>((ref, params) async {
  final (trainerId, scheduledFor, note) = params;
  final currentUser = ref.watch(currentUserProvider);

  if (currentUser == null) return;

  final callRequest = CallRequestModel(
    id: uuid.v4(),
    memberId: currentUser.id,
    trainerId: trainerId,
    requestedAt: DateTime.now(),
    scheduledFor: scheduledFor,
    note: note,
    status: 'pending',
    roomCode: 'hof-lelw-qme',
  );

  try {
    // Write locally to Hive
    final requestsBox = Hive.box('callRequests');
    await requestsBox.put(callRequest.id, callRequest.toMap());

    // Sync to Firestore
    await FirebaseFirestore.instance
        .collection('callRequests')
        .doc(callRequest.id)
        .set({
      ...callRequest.toMap(),
      'requestedAt': Timestamp.fromDate(callRequest.requestedAt),
      // Store as Timestamp
      'scheduledFor': Timestamp.fromDate(callRequest.scheduledFor),
      // Store as Timestamp
    });
  } catch (e) {
    // print('[CALL_SCHEDULE] Error requesting call: $e');
  }
});

final respondToCallRequestProvider =
    FutureProvider.family<void, (String requestId, String status)>(
        (ref, params) async {
  final (requestId, status) = params;
  // const fallbackRoomCode = 'lif-nsqz-pye';
  const fallbackRoomId = '6a28fc5381141ec4c9968fed';

  try {
    // Write locally to Hive
    final requestsBox = Hive.box('callRequests');
    final requestData = requestsBox.get(requestId);

    if (requestData != null && requestData is Map) {
      final request =
          CallRequestModel.fromMap(Map<String, dynamic>.from(requestData));
      request.status = status;
      if (status == 'approved') {
        // request.roomCode = fallbackRoomCode;
        request.roomCode = fallbackRoomId;
      }
      await requestsBox.put(requestId, request.toMap());
    }

    // Sync the status update to Firestore
    await FirebaseFirestore.instance
        .collection('callRequests')
        .doc(requestId)
        .update({
      'status': status,
      if (status == 'approved') 'roomCode': fallbackRoomId,
    });
  } catch (e) {
    // print('[CALL_SCHEDULE] Error responding to call request: $e');
  }
});
