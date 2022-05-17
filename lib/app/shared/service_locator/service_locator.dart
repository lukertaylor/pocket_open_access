import 'package:get_it/get_it.dart';

import '../../features/download/repository/download_repository.dart';

final serviceLocator = GetIt.instance;

void initialisetServiceLocator() {
  serviceLocator.registerLazySingleton<DownloadRepository>(
    () => DownloadRepository(),
  );
}
