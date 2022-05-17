import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockingjay/mockingjay.dart';
import 'package:pocket_open_access/app/features/search/cubit/search_cubit.dart';
import 'package:pocket_open_access/app/features/search/view/search_results.dart';
import 'package:pocket_open_access/app/shared/common_imports/common_imports_barrel.dart';

import '../../../material_wrapper.dart';

class MockSearchCubit extends MockCubit<SearchState> implements SearchCubit {}

void main() {
  late Article _article;
  setUp(() {
    _article = Article(
      123,
      'title',
      [const Author('Luke')],
      'publisher',
      '31/12/2021',
      'summary',
      'https://valid.link/article.pdf',
    );
  });

  group('Search results screen ', () {
    testWidgets('shows a list of cards', (WidgetTester tester) async {
      SearchCubit _mockSearchCubit = MockSearchCubit();
      when(() => _mockSearchCubit.state).thenReturn(SearchComplete([_article]));
      await tester.pumpWidget(
        materialWrapper(
          child: BlocProvider.value(
            value: _mockSearchCubit,
            child: const SearchResults(),
          ),
        ),
      );
      expect(find.byKey(const Key('0')), findsOneWidget);
    });
  });
  group('ArticleCard', () {
    testWidgets('displays Article Card', (WidgetTester tester) async {
      await tester.pumpWidget(
        materialWrapper(
          child: ArticleCard(
            article: _article,
            isDownloaded: true,
          ),
        ),
      );
      expect(find.byKey(const Key('titleKey')), findsOneWidget);
      expect(find.byKey(const Key('authorsKey')), findsOneWidget);
      expect(find.byKey(const Key('publisherKey')), findsOneWidget);
      expect(find.byKey(const Key('publishedDateKey')), findsOneWidget);
    });
    testWidgets('navigates to /article-detail when tapped',
        (WidgetTester tester) async {
      MockNavigator _navigator = MockNavigator();
      when(() =>
              _navigator.pushNamed(any(), arguments: any(named: 'arguments')))
          .thenAnswer(
        (_) async {
          return null;
        },
      );
      await tester.pumpWidget(
        materialWrapper(
          child: MockNavigatorProvider(
            navigator: _navigator,
            child: ArticleCard(
              article: _article,
              isDownloaded: true,
            ),
          ),
        ),
      );
      await tester.tap(find.byKey(const Key('articleTapKey')));
      verify(() =>
              _navigator.pushNamed(any(), arguments: any(named: 'arguments')))
          .called(1);
    });
  });
}
