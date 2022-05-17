import 'dart:typed_data';

import '../../../shared/common_imports/common_imports_barrel.dart';
import '../data/download_data_provider.dart';

/// Saves or deletes an Article's metadata to a key-value store
/// and its PDF to the phone's filesystem.
class DownloadRepository {
  final FileStore _pdfFileStore;
  final KeyValueStore _articleKVStore;

  DownloadRepository({
    FileStore? pdfFileStore,
    KeyValueStore? articleKVStore,
  })  : _pdfFileStore = pdfFileStore ?? LocalFileStore(),
        _articleKVStore = articleKVStore ?? HiveKeyValueStore();

  /// Saves Article PDF to phone's filestore and, if successful puts the path
  /// to the file in the Article's downloadFile field and then stores the
  /// Article metadata in the Articles list in the key-value store. Returns
  /// true if successful.
  Future<bool> save({
    required Article article,
    required Uint8List pdf,
  }) async {
    final filename = article.id.toString() + pdfFileExtension;
    final filePath = await _pdfFileStore.saveAsBytes(
      file: pdf,
      filename: filename,
    );
    if (filePath == null) {
      return false;
    } else {
      article.downloadFile = filePath;
      _articleKVStore.save(
        key: article.id,
        value: article,
      );
      return true;
    }
  }

  /// Deletes the Article PDF and its metadata.
  Future<void> delete({required int id}) async {
    // get Article if it exists
    final article = _articleKVStore.load(key: id);
    if (article != null) {
      final filePath = article.downloadFile!;
      _pdfFileStore.delete(filePath: filePath);
      _articleKVStore.delete(key: id);
    }
  }

  /// Gets a list of Articles from the key/value store and sorts by title.
  List<Article> get articleList {
    List keys = _articleKVStore.keys;
    List<Article> articles = [];
    for (var key in keys) {
      Article? article = _articleKVStore.load(key: key);
      if (article != null) {
        articles.add(article);
      }
    }
    articles.sort((a, b) => a.title.compareTo(b.title));
    return articles;
  }

  /// Checks if an Article has been downloaded
  bool exists({required Article article}) {
    final keys = _articleKVStore.keys;
    return keys.contains(article.id);
  }
}
