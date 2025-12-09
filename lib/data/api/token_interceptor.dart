
import 'package:dio/dio.dart';
import 'package:flutter_module/app/utils/app_macro.dart';
import 'package:flutter_module/data/api/api_constants.dart';
import 'package:synchronized/synchronized.dart';
import 'token_storage.dart';

class TokenInterceptor extends Interceptor {
  final Dio dio;
  final TokenStorage storage;

  Future<String?>? _refreshTokenFuture;
  final _lock = Lock();

  TokenInterceptor(this.dio, this.storage);

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await storage.getToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response != null) {
      switch (err.response?.statusCode) {
        case 400:
          _handleError(err, handler, 'Bad Request');
          break;
        case 403:
          await _handleTokenRefresh(err, handler);
          return;
        case 500:
          _handleError(err, handler, 'Internal Server Error');
          break;
        default:
          _handleError(err, handler, 'Unhandled Error');
      }
    } else {
      _handleError(err, handler, 'Network Error');
    }
  }

  void _handleError(
      DioException err, ErrorInterceptorHandler handler, String message) {
    handler.reject(
      DioException(
        requestOptions: err.requestOptions,
        response: err.response,
        error: message,
      ),
    );
  }

  Future<void> _handleTokenRefresh(
      DioException err, ErrorInterceptorHandler handler) async {
    await _lock.synchronized(() async {
      if (_refreshTokenFuture != null) {
        try {
          final newToken = await _refreshTokenFuture!;
          if (newToken != null) {
            await _retryRequest(err, handler, newToken);
          } else {
            await storage.clear();
            handler.reject(err);
          }
        } catch (e) {
          tLog('=== Error waiting for refresh token: $e ===');
          await storage.clear();
          handler.reject(err);
        }
        return;
      }

      _refreshTokenFuture = _performTokenRefresh();
      try {
        final newToken = await _refreshTokenFuture!;
        if (newToken != null) {
          await _retryRequest(err, handler, newToken);
        } else {
          await storage.clear();
          handler.reject(err);
        }
      } catch (e) {
        tLog('=== Refresh token process failed: $e ===');
        await storage.clear();
        handler.reject(err);
      } finally {
        _refreshTokenFuture = null;
        tLog('=== Refresh token process completed ===');
      }
    });
  }

  Future<String?> _performTokenRefresh() async {
    //TODO: Implement token refresh logic
    return null;
  }

  Future<void> _retryRequest(DioException err, ErrorInterceptorHandler handler,
      String newToken) async {
    try {
      final dioClone = Dio();
      dioClone.options = BaseOptions(
        baseUrl: APIPath.baseURL,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          "Content-Type": "application/json",
        },
      );

      dioClone.interceptors.add(LogInterceptor(
        request: false,
        requestHeader: false,
        responseHeader: false,
        requestBody: true,
        responseBody: true,
        error: true,
        // ignore: avoid_print
        logPrint: (obj) => print(obj),
      ));

      final updatedHeaders =
          Map<String, dynamic>.from(err.requestOptions.headers);
      updatedHeaders['Authorization'] = 'Bearer $newToken';

      final clone = await dioClone.request(
        err.requestOptions.path,
        options: Options(
          method: err.requestOptions.method,
          headers: updatedHeaders,
          sendTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ),
        data: err.requestOptions.data,
        queryParameters: err.requestOptions.queryParameters,
      );

      tLog('=== Original request retry successful ===');
      handler.resolve(clone);
    } catch (e) {
      tLog('=== Original request retry failed: $e ===');
      handler.reject(
        DioException(
          requestOptions: err.requestOptions,
          error: 'Retry request failed: $e',
        ),
      );
    }
  }
}
