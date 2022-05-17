import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockingjay/mockingjay.dart';
import 'package:pocket_open_access/app/features/search/cubit/search_cubit.dart';
import 'package:pocket_open_access/app/features/splash_screen/view/splash_screen.dart';
import 'package:pocket_open_access/app/shared/common_imports/common_imports_barrel.dart';

import '../../material_wrapper.dart';

void main() {
  group('Splash screen', () {
    testWidgets('has pocketOpenAccessLogo present',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        materialWrapper(
            child: const SplashScreen(
          splashTestMode: true,
        )),
      );
      expect(find.byKey(const Key('pocketOpenAccessLogo')), findsOneWidget);
    });
    testWidgets('has poweredByCoreLogo present', (WidgetTester tester) async {
      await tester.pumpWidget(
        materialWrapper(
            child: const SplashScreen(
          splashTestMode: true,
        )),
      );
      expect(find.byKey(const Key('poweredByCoreLogo')), findsOneWidget);
    });
  });
  testWidgets('Splash screen forwards to /home generated route', (
    WidgetTester tester,
  ) async {
    MockNavigator _navigator = MockNavigator();
    when(() => _navigator.pushReplacementNamed(any())).thenAnswer(
      (_) async {
        return null;
      },
    );
    await tester.pumpWidget(
      BlocProvider(
        create: (context) => SearchCubit(),
        child: materialWrapper(
            child: MockNavigatorProvider(
          navigator: _navigator,
          child: const SplashScreen(
            splashTestMode: false,
          ),
        )),
      ),
    );
    await tester.pump(const Duration(seconds: 5));
    verify(() => _navigator.pushReplacementNamed(any())).called(1);
  });
}
