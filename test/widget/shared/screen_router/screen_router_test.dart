import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pocket_open_access/app/features/home_screen/view/home_screen.dart';
import 'package:pocket_open_access/app/features/search/cubit/search_cubit.dart';
import 'package:pocket_open_access/app/features/search/view/search_results.dart';
import 'package:pocket_open_access/app/features/splash_screen/view/splash_screen.dart';
import 'package:pocket_open_access/app/shared/common_imports/common_imports_barrel.dart';
import 'package:pocket_open_access/app/shared/screen_router/screen_router.dart';
import 'package:pocket_open_access/app/shared/widgets/undefined_route_screen.dart';

import '../../material_wrapper.dart';

class MockHomeCubit extends MockCubit<SearchState> implements SearchCubit {}

void main() {
  late SearchCubit _mockHomeCubit;
  setUp(() {
    _mockHomeCubit = MockHomeCubit();
  });

  tearDown(() => _mockHomeCubit.close());

  group('Validate routes', () {
    testWidgets('validate / route', (WidgetTester tester) async {
      when(() => _mockHomeCubit.state).thenReturn(HomeInitial());
      await tester.pumpWidget(BlocProvider.value(
        value: _mockHomeCubit,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Pocket Open Access',
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          onGenerateRoute: ScreenRouter().onGenerateRoute,
        ),
      ));
      await tester.pump(const Duration(seconds: 5));
      expect(find.byType(SplashScreen), findsOneWidget);
    });
    testWidgets('validate /home route', (WidgetTester tester) async {
      when(() => _mockHomeCubit.state).thenReturn(HomeInitial());
      await tester.pumpWidget(BlocProvider.value(
        value: _mockHomeCubit,
        child: materialWrapper(
          child: const Test(
            page: '/home',
          ),
        ),
      ));
      await tester.tap(find.byKey(const Key('buttonKey')));
      await tester.pumpAndSettle();
      expect(find.byType(HomeScreen), findsOneWidget);
    });
    testWidgets('validate /search-results route', (WidgetTester tester) async {
      Article _article = Article(
          123, 'title', [], 'publisher', null, 'summary', 'downloadUrl');
      when(() => _mockHomeCubit.state).thenReturn(SearchComplete([_article]));
      await tester.pumpWidget(BlocProvider.value(
        value: _mockHomeCubit,
        child: materialWrapper(
          child: const Test(
            page: '/search-results',
          ),
        ),
      ));
      await tester.tap(find.byKey(const Key('buttonKey')));
      await tester.pumpAndSettle();
      expect(find.byType(SearchResults), findsOneWidget);
    });
    // testWidgets('validate /article-detail route', (WidgetTester tester) async {
    //   Article _article = Article(
    //       123, 'title', [], 'publisher', null, 'summary', 'downloadUrl');
    //   when(() => _mockHomeCubit.state).thenReturn(SearchComplete([_article]));
    //   await tester.pumpWidget(BlocProvider.value(
    //     value: _mockHomeCubit,
    //     child: materialWrapper(
    //       child: Test(
    //         page: '/article-detail',
    //         args: _article,
    //       ),
    //     ),
    //   ));
    //   await tester.tap(find.byKey(const Key('buttonKey')));
    //   await tester.pumpAndSettle();
    //   expect(find.byType(ArticleDetailScreen), findsOneWidget);
    // });
    // testWidgets('validate /view-pdf route', (WidgetTester tester) async {
    //   Article _article = Article(
    //       123, 'title', [], 'publisher', null, 'summary', 'downloadUrl');
    //   when(() => _mockHomeCubit.state).thenReturn(SearchComplete([_article]));
    //   await tester.pumpWidget(BlocProvider.value(
    //     value: _mockHomeCubit,
    //     child: materialWrapper(
    //       child: Test(
    //         page: '/view-pdf',
    //         args: _article,
    //       ),
    //     ),
    //   ));
    //   await tester.tap(find.byKey(const Key('buttonKey')));
    //   await tester.pumpAndSettle();
    //   expect(find.byType(ViewPdfScreen), findsOneWidget);
    // });
    testWidgets('undefined route', (WidgetTester tester) async {
      when(() => _mockHomeCubit.state).thenReturn(HomeInitial());
      await tester.pumpWidget(BlocProvider.value(
        value: _mockHomeCubit,
        child: materialWrapper(
          child: const Test(
            page: '/BADROUTE',
          ),
        ),
      ));
      await tester.tap(find.byKey(const Key('buttonKey')));
      await tester.pumpAndSettle();
      expect(find.byType(UndefinedRouteScreen), findsOneWidget);
    });
  });
}

class Test extends StatelessWidget {
  const Test({required this.page, this.args, Key? key}) : super(key: key);

  final String page;
  final Object? args;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        key: const Key('buttonKey'),
        onPressed: () => Navigator.pushNamed(context, page, arguments: args),
        child: const Text('Test'));
  }
}
