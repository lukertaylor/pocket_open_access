import 'package:flutter_bloc/flutter_bloc.dart';

import 'features/download/cubit/downloads_cubit.dart';
import 'features/download/repository/download_repository.dart';
import 'features/search/cubit/search_cubit.dart';
import 'shared/common_imports/common_imports_barrel.dart';
import 'shared/screen_router/screen_router.dart';
import 'shared/themes/default_theme_data.dart';

class PocketOpenAccessApp extends StatelessWidget {
  const PocketOpenAccessApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => SearchCubit(),
        ),
        BlocProvider(
          create: (context) => DownloadsCubit(
            downloads: serviceLocator.get<DownloadRepository>().articleList,
          ),
          lazy: false,
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Pocket Open Access',
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: defaultThemeData(context),
        onGenerateRoute: ScreenRouter().onGenerateRoute,
        // showSemanticsDebugger: true,
      ),
    );
  }
}
