import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pocket_open_access/app/features/search/cubit/search_cubit.dart';
import 'package:pocket_open_access/app/features/home_screen/view/home_screen.dart';
import 'package:pocket_open_access/app/features/search/view/search_results.dart';
import 'package:pocket_open_access/app/shared/common_imports/common_imports_barrel.dart';

import '../../../material_wrapper.dart';

class MockHomeCubit extends MockCubit<SearchState> implements SearchCubit {}

// ignore: avoid_implementing_value_types
class FakeHomeState extends Fake implements SearchState {}

class FakeArticle extends Fake implements Article {}

void main() {
  late SearchCubit _mockHomeCubit;
  late HomeScreen _homeScreen;

  setUp(
    () {
      registerFallbackValue(FakeHomeState());
      _mockHomeCubit = MockHomeCubit();
      _homeScreen = const HomeScreen();
    },
  );

  tearDown(() => _mockHomeCubit.close());

  group('Home screen', () {
    final Finder simpleSearchTextFormFieldFinder = find.byKey(
      const Key('simpleSearchTextFormField'),
    );
    final Finder searchButtonFinder = find.byKey(
      const Key('searchButton'),
    );

    testWidgets(
      'created Home screen and found widgets',
      (WidgetTester tester) async {
        when(() => _mockHomeCubit.state).thenReturn(HomeInitial());
        await tester.pumpWidget(
          BlocProvider.value(
            value: _mockHomeCubit,
            child: materialWrapper(
              child: _homeScreen,
            ),
          ),
        );
        expect(
          simpleSearchTextFormFieldFinder,
          findsOneWidget,
        );
        expect(
          searchButtonFinder,
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'accessibility test',
      (WidgetTester tester) async {
        when(() => _mockHomeCubit.state).thenReturn(HomeInitial());
        await tester.pumpWidget(
          BlocProvider.value(
            value: _mockHomeCubit,
            child: materialWrapper(
              child: _homeScreen,
            ),
          ),
        );
        // await expectLater(tester, meetsGuideline(textContrastGuideline));
        await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
        await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
        await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
      },
    );

    // Given the user enters a valid search and Search button is pressed
    // When there is no internet
    // Then a snackbar shows momentarily and the Search does not continue
    testWidgets(
      'shows snackbar when Search is attempted and there is no internet',
      (WidgetTester tester) async {
        when(
          () => _mockHomeCubit.search(query: any(named: 'query')),
        ).thenAnswer(
          (_) => Future.value(),
        );
        whenListen(
          _mockHomeCubit,
          Stream.fromIterable([
            SearchInProgress(),
            NoInternet(),
          ]),
        );
        when(() => _mockHomeCubit.state).thenReturn(NoInternet());

        await tester.pumpWidget(
          BlocProvider.value(
            value: _mockHomeCubit,
            child: materialWrapper(
              child: _homeScreen,
            ),
          ),
        );
        await tester.enterText(simpleSearchTextFormFieldFinder, 'query');
        await tester.tap(searchButtonFinder);
        await tester.pump();

        final Finder noInternetSnackBarFinder = find.byKey(
          const Key(
            'noInternetSnackBar',
          ),
        );
        expect(noInternetSnackBarFinder, findsOneWidget);
      },
    );

    // Given the user enters a valid search and there is internet
    // When the Search button is pressed
    // Then the results screen shown
    testWidgets(
      'goes to results screen when Search is attempted and there is internet',
      (WidgetTester tester) async {
        List<Article> results = [];
        when(
          () => _mockHomeCubit.search(query: any(named: 'query')),
        ).thenAnswer(
          (_) => Future.value(),
        );
        whenListen(
          _mockHomeCubit,
          Stream.fromIterable([
            SearchInProgress(),
            SearchComplete(results),
          ]),
        );
        when(() => _mockHomeCubit.state).thenReturn(SearchComplete(results));

        await tester.pumpWidget(
          BlocProvider.value(
            value: _mockHomeCubit,
            child: materialWrapper(
              child: _homeScreen,
            ),
          ),
        );
        await tester.pump();
        await tester.enterText(simpleSearchTextFormFieldFinder, 'query');
        await tester.tap(searchButtonFinder, warnIfMissed: false);
        await tester.pump();

        Finder searchResultsFinder = find.byType(SearchResults);

        expect(searchResultsFinder, findsOneWidget);
      },
    );
  });
}
