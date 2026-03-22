import '../../../../core/network/dio_client.dart';
import '../../../../core/network/token_storage.dart';

class AuthRemoteDataSource {
  final DioClient dioClient;
  final TokenStorage tokenStorage;

  AuthRemoteDataSource(this.dioClient, this.tokenStorage);

  Future<void> login(String username, String password) async {
    final response = await dioClient.dio.post(
      "users/login/",
      data: {"username": username, "password": password},
    );

    await tokenStorage.saveTokens(
      access: response.data["access"],
      refresh: response.data["refresh"],
    );
  }

  Future<void> signup({
    required String username,
    required String email,
    required String password,
    required String passwordConfirm,
    required String firstName,
    required String lastName,
    required String phone,
  }) async {
    final response = await dioClient.dio.post(
      "users/signup/",
      data: {
        "username": username,
        "email": email,
        "password": password,
        "password_confirm": passwordConfirm,
        "first_name": firstName,
        "last_name": lastName,
        "phone": phone,
      },
    );

    await tokenStorage.saveTokens(
      access: response.data["access"],
      refresh: response.data["refresh"],
    );
  }

  Future<Map<String, dynamic>> getProfile() async {
    final response = await dioClient.dio.get("users/profile/");
    return response.data;
  }

  Future<List<dynamic>> getMyMenu() async {
    final response = await dioClient.dio.get(
      "modules/my-menu/",
      queryParameters: {"platform": "mobile"},
    );
    return response.data;
  }

  Future<void> logout() async {
    try {
      final refreshToken = await tokenStorage.getRefreshToken();

      if (refreshToken != null) {
        await dioClient.dio.post(
          "users/logout/",
          data: {"refresh": refreshToken},
        );
      }
    } catch (_) {
      // even if API fails, continue logout
    }

    // Always clear locally
    await tokenStorage.clear();
  }

  Future<String?> getStoredAccessToken() async{
    String? refreshToken = await tokenStorage.getAccessToken();
    return refreshToken;
  }
}
