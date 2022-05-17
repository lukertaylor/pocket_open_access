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
      emit(SearchComplete(articles));
    } on GetArticlesException catch (e) {
      if (e.error == ApiError.network) {
        emit(NoInternet());
      } else {
        emit(SearchFailed());
      }
    }
  }
}
