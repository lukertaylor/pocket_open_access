import 'dart:typed_data';

import 'package:bloc/bloc.dart';

import '../../../shared/model/article/article_model.dart';
import '../../../shared/service_locator/service_locator.dart';
import '../repository/download_repository.dart';

class DownloadsCubit extends Cubit<List<Article>> {
  DownloadsCubit({
    required List<Article> downloads,
  }) : super(downloads);

  void downloadArticle({
    required Article article,
    required Uint8List pdf,
  }) async {
    final articleSaved = await serviceLocator
        .get<DownloadRepository>()
        .save(article: article, pdf: pdf);
    if (articleSaved) {
      var newList = state;
      newList.add(article);
      newList.sort((a, b) => a.title.compareTo(b.title));
      emit(newList);
    }
  }

  void removeDownload({required Article article}) async {
    await serviceLocator.get<DownloadRepository>().delete(
          id: article.id,
        );
    List<Article> newList = List.from(state);
    newList.removeWhere((a) => a.id == article.id);
    emit(newList);
  }
}
