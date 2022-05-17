import 'package:pocket_open_access/app/shared/common_imports/common_imports_barrel.dart';

class UndefinedRouteScreen extends StatelessWidget {
  const UndefinedRouteScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          AppLocalizations.of(context)!.noRouteDefinedError,
          key: const Key('undefinedRouteScreenText'),
        ),
      ),
    );
  }
}
