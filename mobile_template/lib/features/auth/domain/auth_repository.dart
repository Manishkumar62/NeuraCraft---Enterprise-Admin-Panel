abstract class AuthRepository {
  Future<void> login({
    required String username,
    required String password,
  });

  Future<Map<String, dynamic>> getProfile();

  Future<List<dynamic>> getMyMenu();

  Future<void> logout();
}