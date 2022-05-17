import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'app/features/download/repository/download_repository.dart';
import 'app/pocket_open_access_app.dart';
import 'app/shared/common_imports/common_imports_barrel.dart';
import 'app/shared/initialize_hive/initialize_hive_database.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initialiseHiveDatabase();
  initialisetServiceLocator();

  if (kDebugMode) {
    await _loadTestArticleDownload();
    // Prints all Cubit state changes to the console.
    BlocOverrides.runZoned(
      () => runApp(const PocketOpenAccessApp()),
      blocObserver: CubitObserver(),
    );
  } else {
    runApp(const PocketOpenAccessApp());
  }
}

class CubitObserver extends BlocObserver {
  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    // ignore: avoid_print
    print('${bloc.runtimeType} $change');
  }
}

Article testArticleMetaData = Article(
  123,
  'A very interesting article',
  [const Author('Luke')],
  'Cotham publishing',
  '2020-12-31T23:59:59',
  'This is such an interesting article',
  'https://a.valid.link/',
);

/// when the application is in debug mode, this function will create
/// a test download.
Future<void> _loadTestArticleDownload() async {
  final data = await rootBundle.load('assets/test.pdf');
  final testPdf = data.buffer.asUint8List();
  await serviceLocator.get<DownloadRepository>().save(
        article: testArticleMetaData,
        pdf: testPdf,
      );
}
