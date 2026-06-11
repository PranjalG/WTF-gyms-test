import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../models/call_request_model.dart';
import 'auth_provider.dart';

const uuid = Uuid();

/// All pending call requests for trainer
final pendingCallRequestsProvider = StreamProvider.family<List<CallRequestModel>, String>((ref, trainerId) {
  final requestsBox = Hive.box('callRequests');
  
  return requestsBox.watch().map((_) {
    final allRequests = requestsBox.values
        .whereType<Map>()
        .map((r) => CallRequestModel.fromMap(Map<String, dynamic>.from(r)))
        .where((req) => req.trainerId == trainerId && req.status == 'pending')
        .toList();
    
    // Sort by scheduled time (earliest first)
    allRequests.sort((a, b) => a.scheduledFor.compareTo(b.scheduledFor));
    return allRequests;
  });
});

/// All scheduled calls for user (member or trainer)
final scheduledCallsProvider = StreamProvider.family<List<CallRequestModel>, String>((ref, userId) {
  final requestsBox = Hive.box('callRequests');
  
  return requestsBox.watch().map((_) {
    final allCalls = requestsBox.values
        .whereType<Map>()
        .map((r) => CallRequestModel.fromMap(Map<String, dynamic>.from(r)))
        .where((req) => (req.memberId == userId || req.trainerId == userId) && 
                        (req.status == 'approved' || req.status == 'pending'))
        .toList();
    
    allCalls.sort((a, b) => a.scheduledFor.compareTo(b.scheduledFor));
    return allCalls;
  });
});

/// Request a call
final requestCallProvider = FutureProvider.family<void, (String trainerId, DateTime scheduledFor, String note)>((ref, params) async {
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
  );
  
  try {
    final requestsBox = Hive.box('callRequests');
    await requestsBox.put(callRequest.id, callRequest.toMap());
  } catch (e) {
    print('[CALL_SCHEDULE] Error requesting call: $e');
  }
});

/// Approve or decline a call request
final respondToCallRequestProvider = FutureProvider.family<void, (String requestId, String status)>((ref, params) async {
  final (requestId, status) = params;
  
  try {
    final requestsBox = Hive.box('callRequests');
    final requestData = requestsBox.get(requestId);
    
    if (requestData != null && requestData is Map) {
      final request = CallRequestModel.fromMap(Map<String, dynamic>.from(requestData));
      request.status = status; // 'approved' or 'declined'
      await requestsBox.put(requestId, request.toMap());
    }
  } catch (e) {
    print('[CALL_SCHEDULE] Error responding to call request: $e');
  }
});

/// Unread pending request count
final pendingRequestCountProvider = StreamProvider.family<int, String>((ref, trainerId) {
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
