import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:pocket_open_access/app/shared/utils/api_client.dart';

void main() {
  late Dio dio;
  late DioAdapter dioAdapter;

  setUp(() {
    dio = Dio();
    dioAdapter = DioAdapter(dio: dio);
  });
  group('HTTP request', () {
    test('GET request is successful and has response code 200', () async {
      Uri uri = Uri(
        scheme: 'http',
        host: 'test.com',
        path: '/',
      );

      // mock the response
      dioAdapter.onGet(
        uri.toString(),
        (server) => server.reply(200, {'message': 'Success!'}),
      );

      Response response = await ApiClient().request(
        method: HttpRequestMethod.get,
        uri: uri,
        client: dio,
      );

      expect(response.statusCode, 200);
      expect(response.data['message'], 'Success!');
    });
    test('GET request fails because there is no Internet', () async {
      Uri uri = Uri(
        scheme: 'http',
        host: 'test.com',
        path: '/',
      );

      // mock the response
      dioAdapter.onGet(
        uri.toString(),
        (server) => server.throws(
            0,
            DioError(
              requestOptions: RequestOptions(path: 'http://test.com/'),
              response: null,
              type: DioErrorType.other,
              error: const SocketException(''),
            )),
      );

      expect(
        () async => await ApiClient().request(
          method: HttpRequestMethod.get,
          uri: uri,
          client: dio,
        ),
        throwsA(
          predicate(
            (e) => e is HttpRequestException && e.error == ApiError.network,
          ),
        ),
      );
    });
    test('GET request fails because of a client error', () async {
      Uri uri = Uri(
        scheme: 'http',
        host: 'test.com',
        path: '/',
      );

      // mock the response
      dioAdapter.onGet(
        uri.toString(),
        (server) => server.reply(401, {'message': 'Oops!'}),
      );

      expect(
        () async => await ApiClient().request(
          method: HttpRequestMethod.get,
          uri: uri,
          client: dio,
        ),
        throwsA(
          predicate(
            (e) => e is HttpRequestException && e.error == ApiError.client,
          ),
        ),
      );
    });
    test('GET request fails because of a server error', () async {
      Uri uri = Uri(
        scheme: 'http',
        host: 'test.com',
        path: '/',
      );

      // mock the response
      dioAdapter.onGet(
        uri.toString(),
        (server) => server.reply(500, {'message': 'Oops!'}),
      );

      expect(
        () async => await ApiClient().request(
          method: HttpRequestMethod.get,
          uri: uri,
          client: dio,
        ),
        throwsA(
          predicate(
            (e) => e is HttpRequestException && e.error == ApiError.server,
          ),
        ),
      );
    });
    test('GET request fails because of unknown error', () async {
      Uri uri = Uri(
        scheme: 'http',
        host: 'test.com',
        path: '/',
      );

      // mock the response
      dioAdapter.onGet(
        uri.toString(),
        (server) => server.reply(999, {'message': 'Oops!'}),
      );

      expect(
        () async => await ApiClient().request(
          method: HttpRequestMethod.get,
          uri: uri,
          client: dio,
        ),
        throwsA(
          predicate(
            (e) => e is HttpRequestException && e.error == ApiError.unknown,
          ),
        ),
      );
    });
    test('HEAD request is successful and has response code 200', () async {
      Uri uri = Uri(
        scheme: 'http',
        host: 'test.com',
        path: '/',
      );

      // mock the response
      dioAdapter.onHead(
        uri.toString(),
        (server) => server.reply(200, {'message': 'Success!'}),
      );

      Response response = await ApiClient().request(
        method: HttpRequestMethod.head,
        uri: uri,
        client: dio,
      );

      expect(response.statusCode, 200);
      expect(response.data['message'], 'Success!');
    });
  });
}
