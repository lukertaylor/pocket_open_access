import 'package:pocket_open_access/app/shared/common_imports/common_imports_barrel.dart';
import 'package:pocket_open_access/app/shared/themes/default_theme_data.dart';
import 'package:pocket_open_access/app/shared/widgets/loading_dots.dart';

class DefaultButton extends StatelessWidget {
  final bool isLoading;
  final String buttonText;
  final Function onButtonPressed;

  const DefaultButton({
    Key? key,
    required this.isLoading,
    required this.buttonText,
    required this.onButtonPressed,
  }) : super(key: key);

  void _onPressed() {
    onButtonPressed();
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: _onPressed,
      style: ElevatedButton.styleFrom(
        fixedSize: const Size(double.maxFinite, 50.0),
      ),
      child: isLoading
          ? LoadingDots(color: colorScheme().onPrimary)
          // ? CircularProgressIndicator(
          //     color: colorScheme().onPrimary,
          //     semanticsLabel: AppLocalizations.of(context)!.loadingSemantic,
          //   )
          : Text(
              buttonText,
            ),
    );
  }
}
