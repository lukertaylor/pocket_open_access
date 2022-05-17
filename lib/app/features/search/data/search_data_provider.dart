import '../../../shared/utils/api_client.dart';
import '../../../shared/utils/utils.dart';

const String coreApiIp = 'api.core.ac.uk';
const String coreApiPath = '/v3/search/works/';
const String resultsLimit = '100';
late String apiKey;

class GetArticlesJsonException implements Exception {
  final ApiError error;

  GetArticlesJsonException({required this.error});
}

/// Gets JSON response containing article metadata from Core API
class SearchDataProvider {
  /// Gets JSON containing articles metadata from Core API.
  /// Throws GetArticlesJsonException if fails.
  Future<Map<String, dynamic>> httpGetArticlesJson({
    required String query,
  }) async {
    apiKey = await loadAppConfig(key: 'apiKey');
    final Uri url = Uri.https(
      coreApiIp,
      coreApiPath,
      {
        'q': query,
        'limit': resultsLimit,
        'api_key': apiKey,
      },
    );
    try {
      final _httpResponse = await ApiClient().request(
        method: HttpRequestMethod.get,
        uri: url,
      );
      if (_httpResponse.statusCode == 200) {
        return _httpResponse.data;
      } else {
        throw GetArticlesJsonException(error: ApiError.unknown);
      }
    } on HttpRequestException catch (e) {
      throw GetArticlesJsonException(error: e.error);
    }
  }
}
