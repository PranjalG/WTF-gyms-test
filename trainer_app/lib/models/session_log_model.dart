class SessionLogModel {
  final String id;
  final String memberId;
  final String trainerId;
  final DateTime startedAt;
  final DateTime endedAt;
  final int durationSec;
  final int? rating;
  final String? trainerNotes;
  final String? memberNotes;

  SessionLogModel({
    required this.id,
    required this.memberId,
    required this.trainerId,
    required this.startedAt,
    required this.endedAt,
    required this.durationSec,
    this.rating,
    this.trainerNotes,
    this.memberNotes,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'memberId': memberId,
        'trainerId': trainerId,
        'startedAt': startedAt.toIso8601String(),
        'endedAt': endedAt.toIso8601String(),
        'durationSec': durationSec,
        'rating': rating,
        'trainerNotes': trainerNotes,
        'memberNotes': memberNotes,
      };

  factory SessionLogModel.fromMap(Map<String, dynamic> map) => SessionLogModel(
        id: map['id'],
        memberId: map['memberId'],
        trainerId: map['trainerId'],
        startedAt: DateTime.parse(map['startedAt']),
        endedAt: DateTime.parse(map['endedAt']),
        durationSec: map['durationSec'],
        rating: map['rating'],
        trainerNotes: map['trainerNotes'],
        memberNotes: map['memberNotes'],
      );
}
