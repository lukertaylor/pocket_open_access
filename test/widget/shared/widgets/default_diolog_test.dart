import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_open_access/app/shared/common_imports/common_imports_barrel.dart';

void main() {
  testWidgets('Show default dialog', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: DefaultDialog(
          dialogKey: Key('dialogKey'),
          message: 'message',
          dialogButtons: [],
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(
      find.byKey(
        const Key(
          'dialogKey',
        ),
      ),
      findsOneWidget,
    );
  });
  testWidgets('Show default dialog button', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: DefaultDialogButton(
          buttonKey: const Key('buttonKey'),
          buttonText: 'buttonText',
          onButtonPressed: () {},
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(
      find.byKey(
        const Key(
          'buttonKey',
        ),
      ),
      findsOneWidget,
    );
  });
}
