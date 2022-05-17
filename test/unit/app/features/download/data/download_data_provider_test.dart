import 'dart:typed_data';

import 'package:file/file.dart';
import 'package:file/memory.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pocket_open_access/app/features/download/data/download_data_provider.dart';
import 'package:pocket_open_access/app/shared/common_imports/common_imports_barrel.dart';

class MockArticleBox extends Mock implements Box<Article> {}

void main() {
  late Uint8List pdf;
  late Article article;

  setUp(() {
    pdf = Uint8List(1);
    registerFallbackValue(pdf);

    article = Article(
      123,
      'A very interesting article',
      [const Author('Luke')],
      'Cotham publishing',
      '2020-12-31T23:59:59',
      'This is such an interesting article',
      'https://a.valid.link/',
    );
    registerFallbackValue(article);
  });

  group('PDF persistence', () {
    late FileSystem memoryFileSystem;
    late FileStore pdfFileStore;
    setUp(() async {
      memoryFileSystem = MemoryFileSystem();
      pdfFileStore = LocalFileStore(fileSystem: memoryFileSystem);
    });

    test('retrieves file successfully given a valid path', () async {
      memoryFileSystem.systemTempDirectory;
      File testFile = memoryFileSystem.file('test.pdf');
      testFile = await testFile.writeAsBytes(pdf);
      Uint8List? result =
          await pdfFileStore.loadAsBytes(filePath: testFile.path);
      expect(result, isA<Uint8List>());
    });

    test('FileSystemException occurs during file retrieval and returns null',
        () async {
      Uint8List? result =
          await pdfFileStore.loadAsBytes(filePath: 'non-existent-path');
      expect(result, isNull);
    });

    test('saves PDF successfully and returns path to file', () async {
      String? result =
          await pdfFileStore.saveAsBytes(file: pdf, filename: 'test.pdf');
      expect(result, isNotNull);
    });

    test('FileSystemException occurs during save and returns null', () async {
      // use invalid filename to cause FileSystemException
      String? result = await pdfFileStore.saveAsBytes(
        file: pdf,
        filename: '.',
      );
      expect(result, isNull);
    });

    test('deletes PDF', () async {
      String? filePath =
          await pdfFileStore.saveAsBytes(file: pdf, filename: 'test.pdf');
      await pdfFileStore.delete(filePath: filePath!);
    });
  });
  group('Article persistence', () {
    late Box<Article> mockArticleBox;

    setUp(() {
      mockArticleBox = MockArticleBox();
    });

    test('gets list of keys from key/value store', () {
      List listOfKeys = [123, 321];
      when(() => mockArticleBox.keys).thenReturn(listOfKeys);

      KeyValueStore _articleKeyValueStore =
          HiveKeyValueStore(articleBox: mockArticleBox);
      List result = _articleKeyValueStore.keys;

      verify(() => mockArticleBox.keys).called(1);
      expect(result, listOfKeys);
    });

    test('deletes Article in device storage key/value store', () {
      when(() => mockArticleBox.delete(any()))
          .thenAnswer((_) => Future.value(null));

      KeyValueStore _articleKeyValueStore =
          HiveKeyValueStore(articleBox: mockArticleBox);
      _articleKeyValueStore.delete(key: 123);

      verify(() => mockArticleBox.delete(123)).called(1);
    });

    test('stores Article metadata in device storage key/value store', () {
      when(() => mockArticleBox.put(any(), any()))
          .thenAnswer((_) => Future.value(null));

      KeyValueStore _articleKeyValueStore =
          HiveKeyValueStore(articleBox: mockArticleBox);

      _articleKeyValueStore.save(key: article.id, value: article);
      verify(() => mockArticleBox.put(article.id, article)).called(1);
    });
    test('gets Article metadata from device storage key/value store', () {
      when(() => mockArticleBox.get(any())).thenReturn(article);

      KeyValueStore _articleKeyValueStore =
          HiveKeyValueStore(articleBox: mockArticleBox);
      expect(_articleKeyValueStore.load(key: 123), isA<Article?>());
    });
    test('gets null when Article key does not exist', () {
      when(() => mockArticleBox.get(any())).thenReturn(null);

      KeyValueStore _articleKeyValueStore =
          HiveKeyValueStore(articleBox: mockArticleBox);
      Article? _result = _articleKeyValueStore.load(key: 123);
      expect(_result, equals(null));
    });
  });
}
