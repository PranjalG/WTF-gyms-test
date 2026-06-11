class UserModel {
  final String id;
  final String name;
  final String role; // 'member' or 'trainer'
  final String? avatarUrl;
  final String? assignedTrainerId;

  UserModel({
    required this.id,
    required this.name,
    required this.role,
    this.avatarUrl,
    this.assignedTrainerId,
  });

  Map<dynamic, dynamic> toMap() => {
    'id': id, 'name': name, 'role': role,
    'avatarUrl': avatarUrl, 'assignedTrainerId': assignedTrainerId,
  };

  factory UserModel.fromMap(Map<dynamic, dynamic> m) => UserModel(
    id: m['id'], name: m['name'], role: m['role'],
    avatarUrl: m['avatarUrl'], assignedTrainerId: m['assignedTrainerId'],
  );
}