import 'package:pocket_open_access/app/shared/common_imports/common_imports_barrel.dart';
import 'package:pocket_open_access/app/shared/screen_router/screen_router.dart';

Widget materialWrapper({required Widget child}) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: child,
    locale: const Locale('en'),
    onGenerateRoute: ScreenRouter().onGenerateRoute,
  );
}
