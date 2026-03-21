abstract class AuthRepository {
  Future<void> login({
    required String username,
    required String password,
  });

  Future<void> signup({
    required String username,
    required String email,
    required String password,
    required String passwordConfirm,
    required String firstName,
    required String lastName,
    required String phone,
  });

  Future<Map<String, dynamic>> getProfile();

  Future<List<dynamic>> getMyMenu();

  Future<void> logout();

  Future<String?> getStoredAccessToken();
}
