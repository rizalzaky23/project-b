import 'package:equatable/equatable.dart';

class ManagedUserEntity extends Equatable {
  final int id;
  final String name;
  final String email;
  final String role;
  final String? createdAt;

  const ManagedUserEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.createdAt,
  });

  @override
  List<Object?> get props => [id, name, email, role];
}
