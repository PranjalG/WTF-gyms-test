import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../models/message_model.dart';
import '../di/auth_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

const uuid = Uuid();

/// Get all messages for a conversation (stream)
final messagesProvider = StreamProvider.family<List<MessageModel>, String>((ref, chatId) {
  final messagesBox = Hive.box('messages');
  
  // Return stream that listens to box changes
  return messagesBox.watch().map((_) {
    final allMessages = messagesBox.values
        .whereType<Map>()
        .map((m) => MessageModel.fromMap(Map<String, dynamic>.from(m)))
        .where((msg) => msg.chatId == chatId)
        .toList();
    
    // Sort by timestamp (oldest first)
    allMessages.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return allMessages;
  });
});

/// Get current chat partner details
final chatPartnerProvider = Provider.family<String, String>((ref, userId) {
  // If userId is 'dk_001', partner is 'aarav_001'
  // If userId is 'aarav_001', partner is 'dk_001'
  return userId == 'dk_001' ? 'aarav_001' : 'dk_001';
});

/// Get chat ID between two users (always consistent order)
final chatIdProvider = Provider.family<String, String>((ref, otherUserId) {
  final currentUser = ref.watch(currentUserProvider);
  final userId1 = currentUser?.id ?? '';
  final userId2 = otherUserId;
  
  // Always use alphabetical order for consistency
  final ids = [userId1, userId2]..sort();
  return '${ids[0]}_${ids[1]}';
});

/// Send a message
final sendMessageProvider = FutureProvider.family<void, String>((ref, messageText) async {
  final currentUser = ref.watch(currentUserProvider);
  if (currentUser == null || messageText.trim().isEmpty) return;

  final chatPartner = ref.watch(chatPartnerProvider(currentUser.id));
  final chatId = ref.watch(chatIdProvider(chatPartner));

  final message = MessageModel(
    id: uuid.v4(),
    chatId: chatId,
    senderId: currentUser.id,
    receiverId: chatPartner,
    text: messageText.trim(),
    createdAt: DateTime.now(),
    status: 'sent',
  );

  try {
    // 1. Optimistic write to local cache (Hive)
    final messagesBox = Hive.box('messages');
    await messagesBox.put(message.id, message.toMap());

    // 2. Sync write to remote server (Firestore)
    await FirebaseFirestore.instance
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .doc(message.id)
        .set({
      ...message.toMap(),
      'createdAt': Timestamp.fromDate(message.createdAt), // Store as Firestore Timestamp
    });
  } catch (e) {
    // print('[CHAT] Error sending message: $e');
  }
});

/// Typing indicator state (simulated)
final typingIndicatorProvider = StateProvider<bool>((ref) => false);

/// Set typing indicator with auto-reset
final setTypingProvider = FutureProvider.family<void, bool>((ref, isTyping) async {
  ref.read(typingIndicatorProvider.notifier).state = isTyping;
  
  if (isTyping) {
    // Auto-reset after 400ms
    await Future.delayed(const Duration(milliseconds: 400));
    if (ref.read(typingIndicatorProvider)) {
      ref.read(typingIndicatorProvider.notifier).state = false;
    }
  }
});

/// Last message preview for chat list
final lastMessageProvider = Provider.family<MessageModel?, String>((ref, chatId) {
  final messagesBox = Hive.box('messages');
  
  final messages = messagesBox.values
      .whereType<Map>()
      .map((m) => MessageModel.fromMap(Map<String, dynamic>.from(m)))
      .where((msg) => msg.chatId == chatId)
      .toList();
  
  if (messages.isEmpty) return null;
  messages.sort((a, b) => b.createdAt.compareTo(a.createdAt));
  return messages.first;
});

/// Unread count
final unreadCountProvider = Provider.family<int, String>((ref, chatId) {
  final currentUser = ref.watch(currentUserProvider);
  if (currentUser == null) return 0;
  
  final messagesBox = Hive.box('messages');
  
  final unreadMessages = messagesBox.values
      .whereType<Map>()
      .map((m) => MessageModel.fromMap(Map<String, dynamic>.from(m)))
      .where((msg) => msg.chatId == chatId && msg.status != 'read')
      .length;
  
  return unreadMessages;
});

/// Provider to initialize remote Firestore listener for a specific chat
final syncFirestoreProvider = StreamProvider.family<void, String>((ref, chatId) {
  final firestore = FirebaseFirestore.instance;
  final messagesBox = Hive.box('messages');
  // Listen to remote Firestore messages collection
  final subscription = firestore
      .collection('chats')
      .doc(chatId)
      .collection('messages')
      .snapshots()
      .listen((snapshot) {
    for (var change in snapshot.docChanges) {
      if (change.type == DocumentChangeType.added || change.type == DocumentChangeType.modified) {
        final data = change.doc.data();
        if (data != null) {
          // Convert Firestore Timestamp back to ISO String for local Hive compatibility
          final Map<String, dynamic> messageMap = Map<String, dynamic>.from(data);
          if (data['createdAt'] is Timestamp) {
            messageMap['createdAt'] = (data['createdAt'] as Timestamp).toDate().toIso8601String();
          }

          // Write directly to local Hive.
          // The local messagesProvider stream listens to Hive and will update the UI automatically.
          messagesBox.put(data['id'], messageMap);
        }
      }
    }
  });
  ref.onDispose(() {
    subscription.cancel();
  });

  return const Stream.empty();
});
