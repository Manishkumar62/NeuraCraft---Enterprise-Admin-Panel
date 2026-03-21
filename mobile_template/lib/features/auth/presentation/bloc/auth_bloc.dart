import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/session/session_manager.dart';
import '../../../menu/domain/models/module_model.dart';
import '../../domain/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository repository;

  AuthBloc(this.repository) : super(AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
    on<SignupRequested>(_onSignupRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<AppStarted>(_onAppStarted);
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      // 1️⃣ Login (stores tokens internally)
      await repository.login(
        username: event.username,
        password: event.password,
      );

      // 2️⃣ Fetch profile
      final user = await repository.getProfile();

      // 3️⃣ Fetch modules
      final menuJson = await repository.getMyMenu();

      final modules = menuJson
          .map<AppModule>((e) => AppModule.fromJson(e))
          .toList();

      // 4️⃣ Store in SessionManager
      getIt<SessionManager>().setSession(user: user, modules: modules);

      // emit(AuthSuccess());
    } catch (e) {
      await repository.logout();
      emit(AuthFailure("Login failed"));
    }
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    // Clear session
    getIt<SessionManager>().clearSession();

    emit(AuthInitial());
    
    try {
      await repository.logout(); // blacklist refresh token
    } catch (_) {
      // even if API fails, continue logout locally
    }
  }

  Future<void> _onSignupRequested(
    SignupRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      await repository.signup(
        username: event.username,
        email: event.email,
        password: event.password,
        passwordConfirm: event.passwordConfirm,
        firstName: event.firstName,
        lastName: event.lastName,
        phone: event.phone,
      );

      final user = await repository.getProfile();
      final menuJson = await repository.getMyMenu();

      final modules = menuJson
          .map<AppModule>((e) => AppModule.fromJson(e))
          .toList();

      getIt<SessionManager>().setSession(user: user, modules: modules);
    } catch (_) {
      await repository.logout();
      emit(AuthFailure("Signup failed"));
    }
  }

  Future<void> _onAppStarted(AppStarted event, Emitter<AuthState> emit) async {
    emit(AuthLoading());

    final session = getIt<SessionManager>();
    final accessToken = await repository.getStoredAccessToken();

    if (accessToken == null) {
      session.markBootstrapped();
      emit(AuthInitial());
      return;
    }

    try {
      final user = await repository.getProfile();
      final menuJson = await repository.getMyMenu();

      final modules = menuJson
          .map<AppModule>((e) => AppModule.fromJson(e))
          .toList();

      session.setSession(user: user, modules: modules);

      session.markBootstrapped();
      emit(AuthSuccess());
    } catch (_) {
      await repository.logout();
      session.clearSession();

      session.markBootstrapped();
      emit(AuthInitial());
    }
  }
}
