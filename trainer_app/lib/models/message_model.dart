class MessageModel {
  final String id;
  final String chatId;
  final String senderId;
  final String receiverId;
  final String text;
  final DateTime createdAt;
  String status; // 'sending' | 'sent' | 'read'

  MessageModel({
    required this.id, required this.chatId,
    required this.senderId, required this.receiverId,
    required this.text, required this.createdAt,
    this.status = 'sent',
  });

  Map<String, dynamic> toMap() => {
    'id': id, 'chatId': chatId, 'senderId': senderId,
    'receiverId': receiverId, 'text': text,
    'createdAt': createdAt.toIso8601String(), 'status': status,
  };

  factory MessageModel.fromMap(Map<String, dynamic> m) => MessageModel(
    id: m['id'], chatId: m['chatId'], senderId: m['senderId'],
    receiverId: m['receiverId'], text: m['text'],
    createdAt: DateTime.parse(m['createdAt']), status: m['status'],
  );
}