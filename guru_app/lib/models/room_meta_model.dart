class RoomMetaModel {
  final String id;
  final String callRequestId;
  final String hmsRoomId;
  final String hmsRoleMember;
  final String hmsRoleTrainer;

  RoomMetaModel({
    required this.id, required this.callRequestId,
    required this.hmsRoomId,
    this.hmsRoleMember = 'member',
    this.hmsRoleTrainer = 'trainer',
  });

  Map<String, dynamic> toMap() => {
    'id': id, 'callRequestId': callRequestId,
    'hmsRoomId': hmsRoomId,
    'hmsRoleMember': hmsRoleMember,
    'hmsRoleTrainer': hmsRoleTrainer,
  };

  factory RoomMetaModel.fromMap(Map<String, dynamic> m) => RoomMetaModel(
    id: m['id'], callRequestId: m['callRequestId'],
    hmsRoomId: m['hmsRoomId'],
    hmsRoleMember: m['hmsRoleMember'] ?? 'member',
    hmsRoleTrainer: m['hmsRoleTrainer'] ?? 'trainer',
  );
}