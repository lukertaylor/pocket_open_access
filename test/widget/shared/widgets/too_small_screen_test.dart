import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_open_access/app/shared/common_imports/common_imports_barrel.dart';

void main() {
  const ShowTooSmallScreen showTooSmallScreen = ShowTooSmallScreen();
  testWidgets(
    'Show too small screen',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: Locale('en'),
          home: showTooSmallScreen,
        ),
      );
      expect(
        find.byKey(
          const Key(
            'screenTooSmallText',
          ),
        ),
        findsOneWidget,
      );
    },
  );
}
