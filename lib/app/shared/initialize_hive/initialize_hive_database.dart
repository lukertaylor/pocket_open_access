import 'package:hive_flutter/hive_flutter.dart';

import '../common_imports/common_imports_barrel.dart';

Future<void> initialiseHiveDatabase() async {
  await Hive.initFlutter();
  Hive.registerAdapter(AuthorAdapter());
  Hive.registerAdapter(ArticleAdapter());
  await Hive.openBox<Article>(articleBoxName);
}
