import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:dio_smart_retry/dio_smart_retry.dart';

enum HttpRequestMethod { get, head, bytes }

enum ApiError { network, client, server, unknown }

class HttpRequestException implements Exception {
  final ApiError error;

  HttpRequestException({required this.error});
}

class ApiClient {
  Future<Response> request({
    required HttpRequestMethod method,
    required Uri uri,
    Dio? client,
  }) async {
    // allows us to inject in a mock client when testing.
    final dio = client ?? Dio();

    // configure auto-retry.
    dio.interceptors.add(RetryInterceptor(
      dio: dio,
      retries: 2,
      retryDelays: const [
        Duration(seconds: 2),
        Duration(seconds: 3),
      ],
    ));

    try {
      switch (method) {
        case HttpRequestMethod.get:
          final response = await dio.get(uri.toString(),
              options: Options(
                responseType: ResponseType.json,
              ));
          return response;
        case HttpRequestMethod.head:
          final response = await dio.head(uri.toString());
          return response;
        case HttpRequestMethod.bytes:
          final response = await dio.get<Uint8List>(uri.toString(),
              options: Options(
                responseType: ResponseType.bytes,
              ));
          return response;
        default:
          throw HttpRequestException(error: ApiError.client);
      }
    } on DioError catch (dioError) {
      _dioErrorHandler(dioError);
      rethrow;
    }
  }

  static void _dioErrorHandler(DioError dioError) {
    if (dioError.error is SocketException) {
      throw HttpRequestException(error: ApiError.network);
    }
    if (dioError.response != null) {
      final statusCode = dioError.response?.statusCode;
      if (statusCode != null) {
        if (_isClientError(statusCode)) {
          throw HttpRequestException(error: ApiError.client);
        } else if (_isServerError(statusCode)) {
          throw HttpRequestException(error: ApiError.server);
        }
      }
    }
    throw HttpRequestException(error: ApiError.unknown);
  }

  static bool _isServerError(int statusCode) =>
      statusCode >= 500 && statusCode < 600;

  static bool _isClientError(int statusCode) =>
      statusCode >= 400 && statusCode < 500;
}
