import 'package:flutter_test/flutter_test.dart';
import 'package:mockingjay/mockingjay.dart';
import 'package:pocket_open_access/app/features/article_detail/view/article_detail_screen.dart';
import 'package:pocket_open_access/app/features/download/repository/download_repository.dart';
import 'package:pocket_open_access/app/shared/common_imports/common_imports_barrel.dart';
import 'package:pocket_open_access/app/shared/widgets/loading_dots.dart';

import '../../material_wrapper.dart';

class MockIsValidLink extends Mock {
  Future<bool> call({String? url});
}

class MockDownloadRepository extends Mock implements DownloadRepository {}

class MockHasInternetFunction extends Mock {
  Future<bool> call();
}

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
    registerFallbackValue(_article);
  });
  group('ArticleLink', () {
    late Future<bool> Function({String? url}) _mockIsValidLink;
    late DownloadRepository _mockDownloadRepository;

    setUp(() {
      _mockIsValidLink = MockIsValidLink();
      _mockDownloadRepository = MockDownloadRepository();
      serviceLocator.isRegistered<DownloadRepository>()
          ? serviceLocator.unregister<DownloadRepository>()
          : null;
      serviceLocator
          .registerFactory<DownloadRepository>(() => _mockDownloadRepository);
    });

    testWidgets('shows no article link message when link is invalid',
        (WidgetTester tester) async {
      when(() => _mockIsValidLink(url: any(named: 'url')))
          .thenAnswer((_) => Future.value(false));
      when(() => _mockDownloadRepository.exists(article: any(named: 'article')))
          .thenReturn(false);
      await tester.pumpWidget(
        materialWrapper(
          child: FutureBuilder(
              future: articleLink(
                article: _article,
                linkCheck: _mockIsValidLink,
              ),
              builder: (BuildContext context, AsyncSnapshot<Widget> snapshot) {
                if (snapshot.hasData) {
                  return snapshot.data!;
                }
                return const LoadingDots(
                  color: Colors.black,
                );
              }),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(NoArticleLinkMessage), findsOneWidget);
    });
    testWidgets('shows view PDF button when valid link is to pdf',
        (WidgetTester tester) async {
      when(() => _mockIsValidLink(url: any(named: 'url')))
          .thenAnswer((_) => Future.value(true));
      when(() => _mockDownloadRepository.exists(article: any(named: 'article')))
          .thenReturn(false);
      await tester.pumpWidget(
        materialWrapper(
          child: FutureBuilder(
              future: articleLink(
                article: _article,
                linkCheck: _mockIsValidLink,
              ),
              builder: (BuildContext context, AsyncSnapshot<Widget> snapshot) {
                if (snapshot.hasData) {
                  return snapshot.data!;
                }
                return const LoadingDots(
                  color: Colors.black,
                );
              }),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(ViewPdfButton), findsOneWidget);
    });
    testWidgets('shows view PDF button when article is downloaded',
        (WidgetTester tester) async {
      when(() => _mockIsValidLink(url: any(named: 'url')))
          .thenAnswer((_) => Future.value(true));
      when(() => _mockDownloadRepository.exists(article: any(named: 'article')))
          .thenReturn(true);
      await tester.pumpWidget(
        materialWrapper(
          child: FutureBuilder(
              future: articleLink(
                article: _article,
                linkCheck: _mockIsValidLink,
              ),
              builder: (BuildContext context, AsyncSnapshot<Widget> snapshot) {
                if (snapshot.hasData) {
                  return snapshot.data!;
                }
                return const LoadingDots(
                  color: Colors.black,
                );
              }),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(ViewPdfButton), findsOneWidget);
    });
    testWidgets('shows view web link button when valid link is to web',
        (WidgetTester tester) async {
      Article _webArticle = Article(
        123,
        'title',
        [const Author('Luke')],
        'publisher',
        '31/12/2021',
        'summary',
        'https://valid.link/article.html',
      );
      when(() => _mockIsValidLink(url: any(named: 'url')))
          .thenAnswer((_) => Future.value(true));
      when(() => _mockDownloadRepository.exists(article: any(named: 'article')))
          .thenReturn(false);
      await tester.pumpWidget(
        materialWrapper(
          child: FutureBuilder(
              future: articleLink(
                article: _webArticle,
                linkCheck: _mockIsValidLink,
              ),
              builder: (BuildContext context, AsyncSnapshot<Widget> snapshot) {
                if (snapshot.hasData) {
                  return snapshot.data!;
                }
                return const LoadingDots(
                  color: Colors.black,
                );
              }),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(LinkToWebButton), findsOneWidget);
    });
    testWidgets('shows progress indicator', (WidgetTester tester) async {
      await tester.pumpWidget(
        materialWrapper(
          child: const LoadingDots(
            key: Key('linkCheckProgressIndicatorKey'),
            color: Colors.black,
          ),
        ),
      );
      expect(find.byKey(const Key('linkCheckProgressIndicatorKey')),
          findsOneWidget);
    });
  });
  group('View PDF button', () {
    late Future<bool> Function() _mockHasInternetFunction;
    setUp(() {
      _mockHasInternetFunction = MockHasInternetFunction();
    });
    testWidgets('shows snackbar when there is no Internet',
        (WidgetTester tester) async {
      when(() => _mockHasInternetFunction())
          .thenAnswer((_) => Future.value(false));
      await tester.pumpWidget(materialWrapper(
          child: Scaffold(
        body: ViewPdfButton(
          article: _article,
          isDownloaded: false,
          internetCheck: _mockHasInternetFunction,
        ),
      )));
      await tester.tap(find.byKey(const Key('viewPdfButton')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('noInternetSnackBar')), findsOneWidget);
    });
    testWidgets('navigates to view PDF when there is Internet',
        (WidgetTester tester) async {
      MockNavigator _navigator = MockNavigator();
      when(() =>
              _navigator.pushNamed(any(), arguments: any(named: 'arguments')))
          .thenAnswer(
        (_) async {
          return null;
        },
      );
      when(() => _mockHasInternetFunction())
          .thenAnswer((_) => Future.value(true));
      await tester.pumpWidget(materialWrapper(
          child: MockNavigatorProvider(
        navigator: _navigator,
        child: Scaffold(
          body: ViewPdfButton(
            article: _article,
            isDownloaded: false,
            internetCheck: _mockHasInternetFunction,
          ),
        ),
      )));
      await tester.tap(find.byKey(const Key('viewPdfButton')));
      verify(() =>
              _navigator.pushNamed(any(), arguments: any(named: 'arguments')))
          .called(1);
    });
  });
}
