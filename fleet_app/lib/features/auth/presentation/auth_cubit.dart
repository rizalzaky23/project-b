import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../data/auth_repository.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _repo;

  AuthCubit(this._repo) : super(AuthInitial());

  Future<void> login(String email, String password) async {
    emit(AuthLoading());
    try {
      final resp = await _repo.login(email, password);
      emit(Authenticated(resp.token, resp.user));
    } catch (e) {
      String errorMessage = 'Login gagal';
      if (e is Exception) {
        final msg = e.toString();
        if (msg.contains('Exception: ')) {
          errorMessage = msg.replaceFirst('Exception: ', '');
        } else {
          errorMessage = msg;
        }
      }
      emit(AuthError(errorMessage));
    }
  }

  Future<void> logout() async {
    await _repo.logout();
    emit(Unauthenticated());
  }
}
