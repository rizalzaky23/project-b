import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/managed_user_entity.dart';
import '../../domain/repositories/user_repository.dart';

// ─── Events ───────────────────────────────────────────────────────────────────
abstract class UserEvent extends Equatable {
  const UserEvent();
  @override
  List<Object?> get props => [];
}

class UserLoadRequested extends UserEvent {}

class UserCreateRequested extends UserEvent {
  final String name, email, password, role;
  const UserCreateRequested({
    required this.name,
    required this.email,
    required this.password,
    required this.role,
  });
  @override
  List<Object?> get props => [name, email, password, role];
}

class UserUpdateRequested extends UserEvent {
  final int id;
  final String? name, email, password, role;
  const UserUpdateRequested({
    required this.id,
    this.name,
    this.email,
    this.password,
    this.role,
  });
  @override
  List<Object?> get props => [id, name, email, password, role];
}

class UserDeleteRequested extends UserEvent {
  final int id;
  const UserDeleteRequested(this.id);
  @override
  List<Object?> get props => [id];
}

// ─── States ───────────────────────────────────────────────────────────────────
abstract class UserState extends Equatable {
  const UserState();
  @override
  List<Object?> get props => [];
}

class UserInitial extends UserState {}
class UserLoading extends UserState {}

class UserLoaded extends UserState {
  final List<ManagedUserEntity> users;
  const UserLoaded(this.users);
  @override
  List<Object?> get props => [users];
}

class UserActionSuccess extends UserState {
  final String message;
  final List<ManagedUserEntity> users;
  const UserActionSuccess(this.message, this.users);
  @override
  List<Object?> get props => [message, users];
}

class UserError extends UserState {
  final String message;
  const UserError(this.message);
  @override
  List<Object?> get props => [message];
}

// ─── Bloc ─────────────────────────────────────────────────────────────────────
class UserBloc extends Bloc<UserEvent, UserState> {
  final UserRepository _repo;
  List<ManagedUserEntity> _users = [];

  UserBloc(this._repo) : super(UserInitial()) {
    on<UserLoadRequested>(_onLoad);
    on<UserCreateRequested>(_onCreate);
    on<UserUpdateRequested>(_onUpdate);
    on<UserDeleteRequested>(_onDelete);
  }

  Future<void> _onLoad(UserLoadRequested e, Emitter<UserState> emit) async {
    emit(UserLoading());
    try {
      _users = await _repo.getUsers();
      emit(UserLoaded(_users));
    } catch (ex) {
      emit(UserError(ex.toString()));
    }
  }

  Future<void> _onCreate(UserCreateRequested e, Emitter<UserState> emit) async {
    emit(UserLoading());
    try {
      await _repo.createUser(
        name: e.name,
        email: e.email,
        password: e.password,
        role: e.role,
      );
      _users = await _repo.getUsers();
      emit(UserActionSuccess('User berhasil dibuat.', _users));
    } catch (ex) {
      emit(UserError(ex.toString()));
    }
  }

  Future<void> _onUpdate(UserUpdateRequested e, Emitter<UserState> emit) async {
    emit(UserLoading());
    try {
      await _repo.updateUser(
        e.id,
        name: e.name,
        email: e.email,
        password: e.password,
        role: e.role,
      );
      _users = await _repo.getUsers();
      emit(UserActionSuccess('User berhasil diperbarui.', _users));
    } catch (ex) {
      emit(UserError(ex.toString()));
    }
  }

  Future<void> _onDelete(UserDeleteRequested e, Emitter<UserState> emit) async {
    try {
      await _repo.deleteUser(e.id);
      _users = _users.where((u) => u.id != e.id).toList();
      emit(UserActionSuccess('User berhasil dihapus.', _users));
    } catch (ex) {
      emit(UserError(ex.toString()));
    }
  }
}
