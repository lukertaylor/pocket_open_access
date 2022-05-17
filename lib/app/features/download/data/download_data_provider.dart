import 'dart:typed_data';

import 'package:file/file.dart';
import 'package:file/local.dart';
import 'package:hive/hive.dart';

import 'package:pocket_open_access/app/shared/common_imports/common_imports_barrel.dart';

abstract class FileStore {
  Future<String?> saveAsBytes(
      {required Uint8List file, required String filename});

  Future<Uint8List?> loadAsBytes({required String filePath});

  Future<void> delete({required String filePath});
}

/// Loads and Saves PDF file to LocalFileSystem
class LocalFileStore extends FileStore {
  final FileSystem _fileSystem;

  LocalFileStore({FileSystem? fileSystem})
      : _fileSystem = fileSystem ?? const LocalFileSystem();

  /// Returns a Uint8List of the PDF from the supplied filePath,
  /// or returns null if PDF cannot be read.
  @override
  Future<Uint8List?> loadAsBytes({required String filePath}) async {
    try {
      final file = _fileSystem.file(filePath);
      return await file.readAsBytes();
    } on FileSystemException {
      return null;
    }
  }

  /// Saves PDF to the phone's local file system with the supplied name.
  @override
  Future<String?> saveAsBytes({
    required Uint8List file,
    required String filename,
  }) async {
    final dirPath = await downloadFilesDirectory();
    if (dirPath != null) {
      var fileRef = _fileSystem.file(dirPath + '/' + filename);
      try {
        fileRef = await fileRef.writeAsBytes(file);
        return fileRef.path;
      } on FileSystemException {
        return null;
      }
    } else {
      return null;
    }
  }

  /// Deletes the file at the given filePath.
  @override
  Future<void> delete({required String filePath}) async {
    final fileRef = _fileSystem.file(filePath);
    try {
      await fileRef.delete();
    } catch (_) {
      // ignored
    }
  }
}

/// Stores, retrieves and deletes Article using a key value store.
abstract class KeyValueStore {
  void save({required int key, required dynamic value});
  dynamic load({required int key});
  void delete({required int key});
  List<dynamic> get keys;
}

class HiveKeyValueStore extends KeyValueStore {
  final Box<Article> _articleBox;

  HiveKeyValueStore({Box<Article>? articleBox})
      : _articleBox = articleBox ?? Hive.box<Article>(articleBoxName);

  /// Load Article metadata using the supplied key.
  /// If the key does not exist then null is returned.
  @override
  Article? load({required int key}) {
    return _articleBox.get(key);
  }

  /// Saves Article to key value store using Article ID as the key.
  @override
  Future<void> save({required int key, required value}) async {
    _articleBox.put(key, value);
  }

  /// Deletes Article metadata and key.
  @override
  Future<void> delete({required int key}) async {
    _articleBox.delete(key);
  }

  /// Gets all keys from key/value store
  @override
  List get keys {
    var keysList = [];
    keysList.addAll(_articleBox.keys);
    return keysList;
  }
}
