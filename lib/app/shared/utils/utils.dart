import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform;
import 'dart:typed_data';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart' as path;
import 'package:url_launcher/url_launcher.dart' as launcher;

import '../../features/download/data/download_data_provider.dart';
import '../../features/download/repository/download_repository.dart';
import '../common_imports/common_imports_barrel.dart';
import 'api_client.dart';

/// Gets an app config setting from app config file.
Future<String> loadAppConfig({required String key}) async {
  final configItems = await rootBundle.loadString(
    'assets/config/app-config.json',
  );
  final itemsJson = jsonDecode(configItems);
  return itemsJson[key];
}

/// Gets an article's PDF either from the local filestore
/// (if it has been downloaded), or from the article URL.
Future<Uint8List?> articlePdf({required Article article}) async {
  final articleIsDownloaded = serviceLocator.get<DownloadRepository>().exists(
        article: article,
      );
  if (articleIsDownloaded) {
    return await pdfFromStore(filePath: article.downloadFile!);
  } else {
    return await pdfFromUrl(urlString: article.downloadUrl!);
  }
}

/// Retrieves article PDF from filestore.
Future<Uint8List?> pdfFromStore({
  required String filePath,
  FileStore? pdfFileStore,
}) async {
  final _pdfFileStore = pdfFileStore ?? LocalFileStore();
  return await _pdfFileStore.loadAsBytes(filePath: filePath);
}

/// Retrieves article PDF from the article download url.
Future<Uint8List?> pdfFromUrl({
  required String urlString,
  ApiClient? apiClient,
}) async {
  final _apiClient = apiClient ?? ApiClient();
  dynamic _result;
  try {
    _result = await _apiClient.request(
      method: HttpRequestMethod.bytes,
      uri: Uri.parse(urlString),
    );
    return _result.data;
  } catch (e) {
    return null;
  }
}

/// Returns the phone's Application Support Directory,
/// or null if the directory cannot be found.
Future<String?> downloadFilesDirectory() async {
  try {
    if (Platform.isAndroid || Platform.isIOS) {
      return (await path.getApplicationSupportDirectory()).path;
    } else {
      // Allows for unit testing
      return '.';
    }
  } on path.MissingPlatformDirectoryException {
    return null;
  }
}

/// Determines if the screen is too small to display the app.
bool screenIsTooSmall(BuildContext context) {
  return false;
  // if (MediaQuery.of(context).size.width < appMinScreenWidth) {
  //   return true;
  // }
  // return false;
}

/// Launches the supplied URL in the phone's default browser
Future<void> launchLinkInBrowser(String url) async {
  final uri = Uri.parse(url);
  await launcher.launchUrl(
    uri,
  );
}

/// Sends an HTTP HEAD request to the given URL to find out if
/// it is a valid URL. Returns true if a 200 status code is
/// returned, or otherwise false.
Future<bool> isValidLink({required String? url}) async {
  try {
    final _uri = Uri.parse(url ?? '');
    final _response = await ApiClient().request(
      method: HttpRequestMethod.head,
      uri: _uri,
    );
    return _response.statusCode == 200 ? true : false;
  } catch (_) {
    return false;
  }
}

/// Shows Snackbar with supplied text for 6 seconds before auto-dismissing
void showSnackBar({
  required Key key,
  required String text,
  required BuildContext context,
}) {
  final snackBar = SnackBar(
    key: key,
    content: Text(
      text,
      style: const TextStyle(
        fontSize: 16,
      ),
    ),
    duration: const Duration(seconds: 6),
  );
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}

/// Returns true if there is internet available.
/// Otherwise returns false.
Future<bool> hasInternet({Connectivity? connectivity}) async {
  final _connectivity = connectivity ?? Connectivity();
  final connectivityResult = await _connectivity.checkConnectivity();

  if (connectivityResult == ConnectivityResult.wifi ||
      connectivityResult == ConnectivityResult.mobile ||
      connectivityResult == ConnectivityResult.ethernet) {
    return true;
  } else {
    return false;
  }
}

/// Converts date from ISO 8601 Extended format,
/// to current locale format
Future<String> localeFormattedDate(String? unformattedDate,
    [String? localeString]) async {
  if (unformattedDate != null) {
    final _localeString = localeString ?? getLocaleString;
    return await formatDate(
      date: unformattedDate,
      locale: _localeString,
    );
  } else {
    return '';
  }
}

/// Converts date from ISO 8601 Extended format,
/// to the provided locale format
Future<String> formatDate(
    {required String? date, required String locale}) async {
  if (date == null) {
    return '';
  } else {
    try {
      final dt = DateTime.parse(date);
      await initializeDateFormatting(locale);
      final localFormat = DateFormat.yMd(locale);
      return localFormat.format(dt);
    } catch (_) {
      return '';
    }
  }
}

/// Returns the locale string for the current platform locale
String get getLocaleString {
  try {
    return Platform.localeName;
  } catch (_) {
    return 'en_US';
  }
}

/// Takes a list of Author and returns as a single, comma separated String.
///
/// A limit can be provided to restrict the number of authors in the returned
/// string, in which case '...' is appended. If the limit is ommitted then
/// all authors are returned.
String authorsAsString({required List<Author> authors, int? limit}) {
  limit ??= authors.length;
  var authorsString = '';
  int i = 0;
  for (; i < authors.length; i++) {
    authorsString = authorsString + authors[i].name + ', ';
    if (i == limit - 1) {
      break;
    }
  }
  if (authorsString.length > 1) {
    authorsString = authorsString.substring(
      0,
      authorsString.length - 2,
    );
    if (limit < authors.length) {
      authorsString = authorsString + '...';
    }
  }
  return authorsString;
}
