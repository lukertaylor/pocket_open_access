import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_open_access/app/shared/common_imports/common_imports_barrel.dart';

void main() {
  testWidgets('Show logo image from asset', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: LogoImage(
          width: 100,
          key: Key('logoKey'),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(
      find.byKey(
        const Key(
          'logoKey',
        ),
      ),
      findsOneWidget,
    );
  });
}
