import 'dart:typed_data';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart' as dio;
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pocket_open_access/app/features/download/data/download_data_provider.dart';
import 'package:pocket_open_access/app/shared/common_imports/common_imports_barrel.dart';
import 'package:pocket_open_access/app/shared/utils/api_client.dart';

class MockConnectivity extends Mock implements Connectivity {}

class MockPdfFileStore extends Mock implements LocalFileStore {}

class MockApiClient extends Mock implements ApiClient {}

class MockBuildContext extends Mock implements BuildContext {}

final serviceLocator = GetIt.instance;

void main() {
  group('getArticlePdf', () {
    // late Article article;
    late LocalFileStore mockPdfFileStore;
    late Uint8List pdf;
    late Uint8List? result;

    setUp(() {
      // article = Article(
      //   123,
      //   'title',
      //   [const Author('Luke')],
      //   'publisher',
      //   '31/12/2021',
      //   'summary',
      //   'https://valid.link/article.pdf',
      // );
      mockPdfFileStore = MockPdfFileStore();
      pdf = Uint8List(1);
    });

    test('getPdfFromStore returns PDF when successful', () async {
      String filePath = '/path/article.pdf';
      when(() => mockPdfFileStore.loadAsBytes(filePath: filePath))
          .thenAnswer((_) => Future.value(pdf));
      Uint8List? result = await pdfFromStore(
        filePath: filePath,
        pdfFileStore: mockPdfFileStore,
      );
      expect(result, pdf);
    });

    test('getPdfFromStore returns null when unsuccessful', () async {
      String filePath = '/path/article.pdf';
      when(() => mockPdfFileStore.loadAsBytes(filePath: filePath))
          .thenAnswer((_) => Future.value());
      result = await pdfFromStore(
        filePath: filePath,
        pdfFileStore: mockPdfFileStore,
      );
      expect(result, null);
    });

    test('getPdfFromUrl returns PDF when successful', () async {
      ApiClient _mockApiClient = MockApiClient();
      String urlString = 'https://valid.link/article.pdf';

      when(
        () => _mockApiClient.request(
            method: HttpRequestMethod.bytes, uri: Uri.parse(urlString)),
      ).thenAnswer(
        (_) => Future.value(
          dio.Response<dynamic>(
            requestOptions: dio.RequestOptions(
              path: urlString,
            ),
            statusCode: 200,
            data: pdf,
          ),
        ),
      );

      result = await pdfFromUrl(
        urlString: urlString,
        apiClient: _mockApiClient,
      );
      expect(result, pdf);
    });

    test('getPdfFromUrl returns null when unsuccessful', () async {
      ApiClient _mockApiClient = MockApiClient();
      String urlString = 'https://valid.link/article.pdf';

      when(
        () => _mockApiClient.request(
            method: HttpRequestMethod.bytes, uri: Uri.parse(urlString)),
      ).thenThrow(Exception());

      result = await pdfFromUrl(
        urlString: urlString,
        apiClient: _mockApiClient,
      );
      expect(result, null);
    });
  });

  test('getDownloadFilesDirectory when running in test mode', () async {
    String? result = await downloadFilesDirectory();
    expect(result, '.');
  });

  test('getLocaleString returns a String', () {
    String _result = getLocaleString;
    expect(_result.isNotEmpty, true);
  });

  group('hasNoInternet', () {
    late Connectivity _mockConnectivity;
    List<ConnectivityResult> results = [
      ConnectivityResult.ethernet,
      ConnectivityResult.mobile,
      ConnectivityResult.wifi,
    ];
    setUp(() {
      _mockConnectivity = MockConnectivity();
    });
    test('returns true when there is Internet', () async {
      for (var result in results) {
        when(
          () => _mockConnectivity.checkConnectivity(),
        ).thenAnswer(
          (_) => Future.value(
            result,
          ),
        );
        expect(await hasInternet(connectivity: _mockConnectivity), true);
      }
    });
    test('returns false when there is no Internet', () async {
      when(
        () => _mockConnectivity.checkConnectivity(),
      ).thenAnswer(
        (_) => Future.value(
          ConnectivityResult.none,
        ),
      );
      expect(await hasInternet(connectivity: _mockConnectivity), false);
    });
  });
  // group('isValidLink', () {
  //   test('returns true when head returns 200 status code', () async {
  //     var _mockClient = MockClient((request) async {
  //       return http.Response(
  //         '',
  //         200,
  //       );
  //     });

  //     serviceLocator.isRegistered<http.Client>()
  //         ? serviceLocator.unregister<http.Client>()
  //         : null;

  //     serviceLocator.registerFactory<http.Client>(() => _mockClient);

  //     String validLink = 'https://valid.link/';
  //     bool result = await isValidLink(url: validLink);
  //     expect(result, true);
  //   });
  //   test("returns false when head doesn't return 200 status code", () async {
  //     var _mockClient = MockClient((request) async {
  //       return http.Response(
  //         '',
  //         999,
  //       );
  //     });

  //     serviceLocator.isRegistered<http.Client>()
  //         ? serviceLocator.unregister<http.Client>()
  //         : null;

  //     serviceLocator.registerFactory<http.Client>(() => _mockClient);

  //     String invalidLink = 'https://invalid.link/';
  //     bool result = await isValidLink(url: invalidLink);
  //     expect(result, false);
  //   });
  // });
  group('Get local formatted date', () {
    late String _unformattedDate;
    late String _result;
    test('gets date formatted to platform local when date string is parsable',
        () async {
      _unformattedDate = '2020-05-22T19:22:35';
      _result = await localeFormattedDate(_unformattedDate, 'en_GB');
      expect(_result, '22/05/2020');
    });
    test('gets empty string when getting date string causes exception',
        () async {
      _unformattedDate = 'NOT PARSABLE';
      _result = await localeFormattedDate(_unformattedDate);
      expect(_result, '');
    });
    test('gets empty string when date string is empty', () async {
      _unformattedDate = '';
      _result = await localeFormattedDate(_unformattedDate);
      expect(_result, '');
    });
  });
}
//   group(
//     'Validate email addresses',
//     () {
//       test(
//         'all valid email addresses are valid',
//         () {
//           for (final String validEmail in validEmails) {
//             expect(isValidEmail(validEmail), true);
//           }
//         },
//       );
//       test(
//         'all invalid email addresses are invalid',
//         () {
//           for (final String invalidEmail in invalidEmails) {
//             expect(isValidEmail(invalidEmail), false);
//           }
//         },
//       );
//     },
//   );
//   group(
//     'Validate passwords',
//     () {
//       test(
//         'all valid passwords are valid',
//         () {
//           for (final String validPassword in validPasswords) {
//             expect(isValidPassword(validPassword), true);
//           }
//         },
//       );
//       test(
//         'all invalid passwords are invalid',
//         () {
//           for (final String invalidPassword in invalidPasswords) {
//             expect(isValidPassword(invalidPassword), false);
//           }
//         },
//       );
//     },
//   );


// List<String> validEmails = <String>[
//   'email@example.com',
//   'firstname.lastname@example.com',
//   'email@subdomain.example.com',
//   'firstname+lastname@example.com',
//   'email@[123.123.123.123]',
//   'あいうえお@example.com',
//   '1234567890@example.com',
//   'email@example-one.com',
//   '_______@example.com',
//   'email@example.name',
//   'email@example.museum',
//   'email@example.co.jp',
//   'firstname-lastname@example.com',
// ];

// List<String> invalidEmails = <String>[
//   'plainaddress',
//   r'#@%^%#$@#$@#.com',
//   '@example.com',
//   'Joe Smith <email@example.com>',
//   'email.example.com',
//   'email@example@example.com',
//   '.email@example.com',
//   'email.@example.com',
//   'email..email@example.com',
//   'email@example.com (Joe Smith)',
//   'email@example',
//   'email@-example.com',
//   'email@111.222.333.44444',
//   'email@example..com',
//   'Abc..123@example.com',
// ];

// List<String> validPasswords = <String>[
//   // valid password must be at least 8 chars long,
//   // including at least one letter and one number
//   // and can also include these special characters
//   // !@#$&*
//   'abcdefg1',
//   '1234567a',
//   'ABCDEFG1',
//   'AbCdEfG1',
//   r'A!@#$&*2',
// ];

// List<String> invalidPasswords = <String>[
//   '123456a', // too short
//   '12345678', // no letters
//   'abcdefgh', // no numbers
//   r'!@#$&*!@#$&*' // just special characters
// ];
