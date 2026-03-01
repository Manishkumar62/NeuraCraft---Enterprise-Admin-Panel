import '../../../../core/network/dio_client.dart';
import '../../../../core/network/token_storage.dart';


class AuthRemoteDataSource {
  final DioClient dioClient;
  final TokenStorage tokenStorage;

  AuthRemoteDataSource(this.dioClient, this.tokenStorage);

  Future<void> login(String username, String password) async {
    final response = await dioClient.dio.post(
      "users/login/",
      data: {
        "username": username,
        "password": password,
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
    final response = await dioClient.dio.get("modules/my-menu/");
    return response.data;
  }

  Future<void> logout() async {
    await tokenStorage.clear();
  }
}