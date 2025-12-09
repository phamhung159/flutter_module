import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import 'token_interceptor.dart';
import 'token_storage.dart';

@module
abstract class DioModule {
  @factoryMethod
  Dio provideDio() {
    final dio = Dio();
    dio.options = BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        "Content-Type": "application/json",
      },
    );
    dio.interceptors.add(TokenInterceptor(dio, TokenStorage()));
    dio.interceptors.add(LogInterceptor(
      request: false,
      requestHeader: false,
      responseHeader: false,
      requestBody: true,
      responseBody: true,
      error: true,
      // ignore: avoid_print
      logPrint: (obj) => print(obj),
    ));
    return dio;
  }
}
