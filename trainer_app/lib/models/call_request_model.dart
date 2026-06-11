class CallRequestModel {
  final String id;
  final String memberId;
  final String trainerId;
  final DateTime requestedAt;
  final DateTime scheduledFor;
  final String note;
  String status; // 'pending'|'approved'|'declined'|'cancelled'

  CallRequestModel({
    required this.id, required this.memberId, required this.trainerId,
    required this.requestedAt, required this.scheduledFor,
    required this.note, this.status = 'pending',
  });

  Map<String, dynamic> toMap() => {
    'id': id, 'memberId': memberId, 'trainerId': trainerId,
    'requestedAt': requestedAt.toIso8601String(),
    'scheduledFor': scheduledFor.toIso8601String(),
    'note': note, 'status': status,
  };

  factory CallRequestModel.fromMap(Map<String, dynamic> m) => CallRequestModel(
    id: m['id'], memberId: m['memberId'], trainerId: m['trainerId'],
    requestedAt: DateTime.parse(m['requestedAt']),
    scheduledFor: DateTime.parse(m['scheduledFor']),
    note: m['note'], status: m['status'],
  );
}