import '../../../shared/common_imports/common_imports_barrel.dart';
import '../../../shared/utils/api_client.dart';
import '../data/search_data_provider.dart';

class GetArticlesException implements Exception {
  final ApiError error;

  GetArticlesException({required this.error});
}

class SearchRepository {
  SearchRepository({SearchDataProvider? searchDataProvider})
      : _searchDataProvider = searchDataProvider ?? SearchDataProvider();

  final SearchDataProvider _searchDataProvider;

  /// Retrieves a JSON list containing Articles from SearchDataProvider
  /// and converts to List<Article>
  Future<List<Article>> getArticles({required String query}) async {
    try {
      final _articlesJSON = await _searchDataProvider.httpGetArticlesJson(
        query: query,
      );
      return Response.fromJson(_articlesJSON).articles;
    } on GetArticlesJsonException catch (e) {
      throw GetArticlesException(error: e.error);
    }
  }
}
