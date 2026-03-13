import 'package:dio/dio.dart';
import 'token_storage.dart';

class DioClient {
  final Dio dio;
  final TokenStorage tokenStorage;

  bool _isRefreshing = false;
  final List<_QueuedRequest> _requestQueue = [];

  DioClient(this.tokenStorage)
      : dio = Dio(
          BaseOptions(
            baseUrl: "https://neuracraft-enterprise-admin-panel-backend-production.up.railway.app/api/",
            // baseUrl: "http://192.168.1.2:8000/api/",
            // baseUrl: "http://127.0.0.1:8000/api/",
            connectTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 10),
          ),
        ) {
    dio.interceptors.add(
      LogInterceptor(
        request: true, // Print request info
        requestHeader: true, // Print request headers
        requestBody: true, // Print request payload (POST/PUT data)
        responseHeader: false, // Set to true if you need response headers
        responseBody: true, // Print the JSON response from server
        error: true, // Print errors
      ),
    );

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
            return _handle401(error, handler);
          }
          return handler.next(error);
        },
      ),
    );
  }

  Future<void> _handle401(
    DioException error,
    ErrorInterceptorHandler handler,
  ) async {
    final refreshToken = await tokenStorage.getRefreshToken();

    if (refreshToken == null) {
      return handler.next(error);
    }

    if (!_isRefreshing) {
      _isRefreshing = true;

      final success = await _refreshToken(refreshToken);

      _isRefreshing = false;

      if (success) {
        final newToken = await tokenStorage.getAccessToken();

        await _resolveQueuedRequests(newToken);

        error.requestOptions.headers["Authorization"] = "Bearer $newToken";

        try {
          final response = await dio.fetch(error.requestOptions);
          return handler.resolve(response);
        } on DioException catch (retryError) {
          return handler.next(retryError);
        }
      }

      await tokenStorage.clear();
      await _rejectQueuedRequests(error);
      return handler.next(error);
    }

    _requestQueue.add(
      _QueuedRequest(
        requestOptions: error.requestOptions,
        handler: handler,
      ),
    );
  }

  Future<void> _resolveQueuedRequests(String? accessToken) async {
    final pendingRequests = List<_QueuedRequest>.from(_requestQueue);
    _requestQueue.clear();

    for (final queuedRequest in pendingRequests) {
      queuedRequest.requestOptions.headers["Authorization"] =
          "Bearer $accessToken";

      try {
        final response = await dio.fetch(queuedRequest.requestOptions);
        queuedRequest.handler.resolve(response);
      } on DioException catch (error) {
        queuedRequest.handler.next(error);
      }
    }
  }

  Future<void> _rejectQueuedRequests(DioException error) async {
    final pendingRequests = List<_QueuedRequest>.from(_requestQueue);
    _requestQueue.clear();

    for (final queuedRequest in pendingRequests) {
      queuedRequest.handler.next(error);
    }
  }

  Future<bool> _refreshToken(String refreshToken) async {
    try {
      final refreshDio = Dio(BaseOptions(baseUrl: dio.options.baseUrl));

      final response = await refreshDio.post(
        "users/token/refresh/",
        data: {"refresh": refreshToken},
      );

      final newAccess = response.data["access"];
      await tokenStorage.saveTokens(
        access: newAccess,
        refresh: refreshToken,
      );

      return true;
    } catch (_) {
      return false;
    }
  }
}

class _QueuedRequest {
  final RequestOptions requestOptions;
  final ErrorInterceptorHandler handler;

  _QueuedRequest({
    required this.requestOptions,
    required this.handler,
  });
}
