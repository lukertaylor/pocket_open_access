import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_open_access/app/shared/common_imports/common_imports_barrel.dart';
import 'package:pocket_open_access/app/shared/widgets/undefined_route_screen.dart';

void main() {
  const UndefinedRouteScreen _undefinedRouteScreen = UndefinedRouteScreen();
  testWidgets(
    'Show undefined route screen',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: Locale('en'),
          home: _undefinedRouteScreen,
        ),
      );
      expect(
        find.byKey(
          const Key(
            'undefinedRouteScreenText',
          ),
        ),
        findsOneWidget,
      );
    },
  );
}
