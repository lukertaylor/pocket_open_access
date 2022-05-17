import '../common_imports/common_imports_barrel.dart';

class ShowTooSmallScreen extends StatelessWidget {
  const ShowTooSmallScreen({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Center(
          child: Text(
            AppLocalizations.of(context)!.screenTooSmall,
            key: const Key('screenTooSmallText'),
            semanticsLabel: AppLocalizations.of(context)!.screenTooSmall,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18.0,
            ),
          ),
        ),
      ),
    );
  }
}
