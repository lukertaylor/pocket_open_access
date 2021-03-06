import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../shared/common_imports/common_imports_barrel.dart';
import '../../../shared/utils/api_client.dart';
import '../repository/search_repository.dart';

part 'search_state.dart';

class SearchCubit extends Cubit<SearchState> {
  SearchCubit({
    SearchRepository? searchRepository,
  }) : super(HomeInitial()) {
    _searchRepository = searchRepository ?? SearchRepository();
  }
  late final SearchRepository _searchRepository;

  Future<void> search({required String query}) async {
    emit(SearchInProgress());
    try {
      final articles = await _searchRepository.getArticles(
        query: query,
      );
      List<Article> _justPdfArticles = _filterOnlyPdfArticles(articles);
      emit(SearchComplete(_justPdfArticles));
    } on GetArticlesException catch (e) {
      if (e.error == ApiError.network) {
        emit(NoInternet());
      } else {
        emit(SearchFailed());
      }
    }
  }
}

List<Article> _filterOnlyPdfArticles(List<Article> allArticles) {
  List<Article> onlyPdfArticles = [];
  for (var article in allArticles) {
    if (article.downloadUrl == null) continue;
    if (!_isPdf(article)) continue;
    if (_alreadyExists(article, onlyPdfArticles)) continue;
    onlyPdfArticles.add(article);
  }
  return onlyPdfArticles;
}

bool _isPdf(Article article) {
  return article.downloadUrl!.toLowerCase().contains('.pdf');
}

bool _alreadyExists(Article article, List<Article> articles) {
  return articles.any((a) => a.id == article.id);
}
