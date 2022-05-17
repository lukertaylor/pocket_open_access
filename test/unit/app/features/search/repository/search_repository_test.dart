import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pocket_open_access/app/features/search/data/search_data_provider.dart';
import 'package:pocket_open_access/app/features/search/repository/search_repository.dart';
import 'package:pocket_open_access/app/shared/common_imports/common_imports_barrel.dart';
import 'package:pocket_open_access/app/shared/utils/api_client.dart';

class MockSearchDataProvider extends Mock implements SearchDataProvider {}

class MockIsValidLink extends Mock {
  Future<bool> call({required Uri url});
}

void main() {
  group('Search repository', () {
    late SearchDataProvider _mockSearchDataProvider;
    late SearchRepository _searchRepository;

    setUp(() {
      _mockSearchDataProvider = MockSearchDataProvider();
      _searchRepository =
          SearchRepository(searchDataProvider: _mockSearchDataProvider);
    });

    group('getAuthors', () {
      test('returns empty string when there are no authors', () async {
        String authors = authorsAsString(
          authors: [],
          limit: 5,
        );
        expect(authors, '');
      });

      test('returns limited string when there are authors', () async {
        List<Author> authors = [
          const Author('Luke'),
          const Author('John'),
          const Author('Jess'),
          const Author('Jack'),
          const Author('June'),
          const Author('Miss'),
        ];
        String authorsString = authorsAsString(
          authors: authors,
          limit: 5,
        );
        expect(authorsString, 'Luke, John, Jess, Jack, June...');
      });

      test('returns all authors when limit is not supplied', () async {
        List<Author> authors = [
          const Author('Luke'),
          const Author('John'),
          const Author('Jess'),
          const Author('Jack'),
          const Author('June'),
          const Author('Jane'),
        ];
        String authorsString = authorsAsString(
          authors: authors,
        );
        expect(authorsString, 'Luke, John, Jess, Jack, June, Jane');
      });
    });

    group('getArticles ', () {
      test('throws GetArticlesException when search fails', () async {
        when(() => _mockSearchDataProvider.httpGetArticlesJson(
                query: any(named: 'query')))
            .thenThrow(GetArticlesJsonException(error: ApiError.unknown));
        expect(
          () async => await _searchRepository.getArticles(
            query: 'test',
          ),
          throwsA(
            predicate(
              (e) => e is GetArticlesException,
            ),
          ),
        );
      });

      test('returns empty list when no response is returned', () async {
        Map<String, dynamic> _emptyResponse = {'results': []};
        when(() => _mockSearchDataProvider.httpGetArticlesJson(
                query: any(named: 'query')))
            .thenAnswer((_) => Future.value(_emptyResponse));
        List<Article> _result =
            await _searchRepository.getArticles(query: 'test');
        expect(
          _result,
          <Article>[],
        );
      });

      test('returns Article list when response is returned', () async {
        Map<String, dynamic> _response = {
          'results': [
            {
              'id': 123,
              'title': 'the title',
              'authors': [],
            }
          ]
        };
        when(() => _mockSearchDataProvider.httpGetArticlesJson(
                query: any(named: 'query')))
            .thenAnswer((_) => Future.value(_response));
        List<Article> _result =
            await _searchRepository.getArticles(query: 'test');
        expect(
          _result.length == 1,
          true,
        );
      });
    });

    group('convert from JSON', () {
      test('converts article with all fields present', () {
        Map<String, dynamic> _testJSON = {
          'results': [
            {
              'id': 123,
              'title': 'A very interesting article',
              'authors': [
                {'name': 'Luke'}
              ],
              'publisher': 'Cotham publishing',
              'publishedDate': '2020-12-31T23:59:59',
              'abstract': 'This is such an interesting article',
              'downloadUrl': 'https://a.valid.link/',
            }
          ]
        };
        List<Article> _result = Response.fromJson(_testJSON).articles;
        expect(_result[0].id, 123);
        expect(_result[0].title, 'A very interesting article');
        expect(_result[0].authors[0], const Author('Luke'));
        expect(_result[0].publisher, 'Cotham publishing');
        expect(_result[0].publishedDate, '2020-12-31T23:59:59');
        expect(_result[0].summary, 'This is such an interesting article');
        expect(_result[0].downloadUrl, 'https://a.valid.link/');
      });

      test('converts article with just mandatory fields present', () {
        Map<String, dynamic> _testJSON = {
          'results': [
            {
              'id': 123,
              'title': 'the title',
              'authors': [],
            }
          ]
        };
        List<Article> _result = Response.fromJson(_testJSON).articles;
        expect(_result[0].id, 123);
        expect(_result[0].title, 'the title');
        expect(_result[0].authors, []);
        expect(_result[0].publisher, null);
        expect(_result[0].publishedDate, null);
        expect(_result[0].summary, null);
        expect(_result[0].downloadUrl, null);
      });
    });

    group('convert to JSON', () {
      test('converts author', () {
        Author _author = const Author('Luke');
        Map<String, dynamic> _result = _author.toJson();
        Map<String, dynamic> _expected = {'name': 'Luke'};
        expect(_result, _expected);
      });
      test('converts article with all fields present', () {
        List<Article> _article = [
          Article(
            123,
            'A very interesting article',
            [const Author('Luke')],
            'Cotham publishing',
            '2020-12-31T23:59:59',
            'This is such an interesting article',
            'https://a.valid.link/',
          ),
        ];
        Map<String, dynamic> _result = Response(_article).toJson();
        expect(_result['results'][0]['id'], 123);
        expect(_result['results'][0]['title'], 'A very interesting article');
        expect(_result['results'][0]['authors'], [const Author('Luke')]);
        expect(_result['results'][0]['publisher'], 'Cotham publishing');
        expect(_result['results'][0]['publishedDate'], '2020-12-31T23:59:59');
        expect(_result['results'][0]['abstract'],
            'This is such an interesting article');
        expect(_result['results'][0]['downloadUrl'], 'https://a.valid.link/');
      });
    });
  });
}
