import 'package:pocket_open_access/app/shared/common_imports/common_imports_barrel.dart';

class LinkButton extends StatelessWidget {
  final String buttonText;
  final Function onButtonPressed;

  const LinkButton({
    Key? key,
    required this.buttonText,
    required this.onButtonPressed,
  }) : super(key: key);

  void _onPressed() {
    onButtonPressed();
  }

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: _onPressed,
      child: Text(
        buttonText,
        style: const TextStyle(
          fontSize: 18.0,
        ),
      ),
    );
  }
}
