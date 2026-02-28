import '../domain/auth_repository.dart';
import 'auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remote;

  AuthRepositoryImpl(this.remote);

  @override
  Future<void> login({
    required String username,
    required String password,
  }) async {
    await remote.login(username, password);
  }

  @override
  Future<Map<String, dynamic>> getProfile() {
    return remote.getProfile();
  }

  @override
  Future<List<dynamic>> getMyMenu() {
    return remote.getMyMenu();
  }

  @override
  Future<void> logout() {
    return remote.logout();
  }
}