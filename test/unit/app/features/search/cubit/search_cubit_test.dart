import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pocket_open_access/app/features/search/cubit/search_cubit.dart';
import 'package:pocket_open_access/app/features/search/repository/search_repository.dart';
import 'package:pocket_open_access/app/shared/common_imports/common_imports_barrel.dart';
import 'package:pocket_open_access/app/shared/utils/api_client.dart';

class MockSearchRepository extends Mock implements SearchRepository {}

void main() {
  const String query = 'piriformis';
  late SearchRepository _mockSearchRepository;
  late SearchCubit _homeCubit;
  Author author = const Author('author');
  Article article = Article(
    123,
    'title',
    [author],
    'publisher',
    null,
    'summary',
    null,
  );
  List<Article> articles = [article];

  setUp(
    () {
      _mockSearchRepository = MockSearchRepository();
      _homeCubit = SearchCubit(
        searchRepository: _mockSearchRepository,
      );
    },
  );

  tearDown(() => _homeCubit.close());

  group('Home Cubit', () {
    test('initial state is HomeInitial', () {
      expect(_homeCubit.state, HomeInitial());
    });
    blocTest<SearchCubit, SearchState>(
      'emits SearchInProgress then NoInternet when simpleSearch is called and there is no internet',
      setUp: () {
        when(() => _mockSearchRepository.getArticles(
                query: any(
              named: 'query',
            ))).thenThrow(GetArticlesException(error: ApiError.network));
      },
      build: () => _homeCubit,
      act: (cubit) => cubit.search(query: query),
      expect: () => <SearchState>[SearchInProgress(), NoInternet()],
    );

    blocTest<SearchCubit, SearchState>(
      'emits SearchInProgress then SearchComplete with articles when simpleSearch is called and there is internet',
      setUp: () {
        when(() => _mockSearchRepository.getArticles(
                query: any(
              named: 'query',
            ))).thenAnswer((_) => Future.value(articles));
      },
      build: () => _homeCubit,
      act: (cubit) => cubit.search(query: query),
      expect: () => <SearchState>[SearchInProgress(), SearchComplete(articles)],
    );

    blocTest<SearchCubit, SearchState>(
      'emits SearchInProgress then SearchFailed when simpleSearch fails and there is internet',
      setUp: () {
        when(() => _mockSearchRepository.getArticles(
                query: any(
              named: 'query',
            ))).thenThrow(GetArticlesException(error: ApiError.unknown));
      },
      build: () => _homeCubit,
      act: (cubit) => cubit.search(query: query),
      expect: () => <SearchState>[SearchInProgress(), SearchFailed()],
    );
  });
}
