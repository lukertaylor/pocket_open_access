import 'package:pocket_open_access/app/shared/common_imports/common_imports_barrel.dart';

class DefaultDialog extends StatelessWidget {
  final Key dialogKey;
  final String message;
  final List<Widget> dialogButtons;

  const DefaultDialog({
    Key? key,
    required this.dialogKey,
    required this.message,
    required this.dialogButtons,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      key: dialogKey,
      content: Text(message),
      actions: dialogButtons,
    );
  }
}

class DefaultDialogButton extends StatelessWidget {
  final Key buttonKey;
  final String buttonText;
  final Function onButtonPressed;

  const DefaultDialogButton({
    Key? key,
    required this.buttonKey,
    required this.buttonText,
    required this.onButtonPressed,
  }) : super(key: key);

  void _onPressed() {
    onButtonPressed();
  }

  @override
  Widget build(BuildContext context) {
    return TextButton(
      key: buttonKey,
      onPressed: _onPressed,
      child: Text(buttonText),
    );
  }
}
