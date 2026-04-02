import '../../domain/entities/managed_user_entity.dart';

class ManagedUserModel extends ManagedUserEntity {
  const ManagedUserModel({
    required super.id,
    required super.name,
    required super.email,
    required super.role,
    super.createdAt,
  });

  factory ManagedUserModel.fromJson(Map<String, dynamic> json) {
    return ManagedUserModel(
      id:        int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name:      json['name'] ?? '',
      email:     json['email'] ?? '',
      role:      json['role'] ?? 'staff',
      createdAt: json['created_at'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id':    id,
    'name':  name,
    'email': email,
    'role':  role,
  };
}
