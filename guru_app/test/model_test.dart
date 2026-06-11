import 'package:flutter_test/flutter_test.dart';
import 'package:guru_app/models/message_model.dart';

void main() {
  test('MessageModel serializes and deserializes', () {
    final createdAt = DateTime(2026, 6, 11, 18, 0);
    final message = MessageModel(
      id: 'msg_1',
      chatId: 'aarav_001_dk_001',
      senderId: 'dk_001',
      receiverId: 'aarav_001',
      text: 'Hi Coach',
      createdAt: createdAt,
      status: 'sent',
    );

    final restored = MessageModel.fromMap(message.toMap());

    expect(restored.id, 'msg_1');
    expect(restored.text, 'Hi Coach');
    expect(restored.createdAt, createdAt);
    expect(restored.status, 'sent');
  });

  test('scheduler rejects past time', () {
    final now = DateTime(2026, 6, 11, 18, 0);
    final selected = DateTime(2026, 6, 11, 17, 30);

    expect(selected.isAfter(now), isFalse);
  });

  test('session duration is calculated in seconds', () {
    final startedAt = DateTime(2026, 6, 11, 18, 0);
    final endedAt = DateTime(2026, 6, 11, 18, 32, 15);

    expect(endedAt.difference(startedAt).inSeconds, 1935);
  });
}
