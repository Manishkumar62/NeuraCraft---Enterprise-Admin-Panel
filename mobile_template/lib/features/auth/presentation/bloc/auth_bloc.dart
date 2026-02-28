import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../menu/domain/models/module_model.dart';
import '../../domain/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository repository;

  AuthBloc(this.repository) : super(AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
    on<LogoutRequested>(_onLogoutRequested);
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      // 1️⃣ Login
      await repository.login(
        username: event.username,
        password: event.password,
      );

      // 2️⃣ Fetch Profile
      final user = await repository.getProfile();

      final menuJson = await repository.getMyMenu();

      final modules = menuJson
          .map<AppModule>((e) => AppModule.fromJson(e))
          .toList();

      emit(AuthAuthenticated(user: user, modules: modules));
    } catch (e) {
      print("LOGIN ERROR: $e");
      emit(const AuthFailure("Login failed"));
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await repository.logout();
    emit(AuthUnauthenticated());
  }
}
