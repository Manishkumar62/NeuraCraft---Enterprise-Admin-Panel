import 'package:dio/dio.dart';
import 'token_storage.dart';

class DioClient {
  final Dio dio;
  final TokenStorage tokenStorage;

  DioClient(this.tokenStorage)
      : dio = Dio(
          BaseOptions(
            // baseUrl: "http://192.168.1.2:8000/api/",
            baseUrl: "http://http://127.0.0.1:8000/api/",
            connectTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 10),
          ),
        ) {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await tokenStorage.getAccessToken();
          if (token != null) {
            options.headers["Authorization"] = "Bearer $token";
          }
          return handler.next(options);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401) {
            final refreshed = await _refreshToken();
            if (refreshed) {
              final newToken = await tokenStorage.getAccessToken();
              error.requestOptions.headers["Authorization"] =
                  "Bearer $newToken";

              final cloneReq = await dio.fetch(error.requestOptions);
              return handler.resolve(cloneReq);
            }
          }
          return handler.next(error);
        },
      ),
    );
  }

  Future<bool> _refreshToken() async {
    try {
      final refreshToken = await tokenStorage.getRefreshToken();
      if (refreshToken == null) return false;

      final response = await dio.post(
        "token/refresh/",
        data: {"refresh": refreshToken},
      );

      final newAccess = response.data["access"];
      await tokenStorage.saveTokens(
        access: newAccess,
        refresh: refreshToken,
      );

      return true;
    } catch (_) {
      await tokenStorage.clear();
      return false;
    }
  }
}