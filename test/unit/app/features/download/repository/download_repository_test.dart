import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pocket_open_access/app/features/download/data/download_data_provider.dart';
import 'package:pocket_open_access/app/features/download/repository/download_repository.dart';
import 'package:pocket_open_access/app/shared/common_imports/common_imports_barrel.dart';

class MockPdfFileStore extends Mock implements LocalFileStore {}

class MockHiveKeyValueStore extends Mock implements HiveKeyValueStore {}

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

  group('Download repository', () {
    late FileStore mockPdfFileStore;
    late KeyValueStore mockHiveKeyValueStore;
    late DownloadRepository downloadRepository;
    late String filePath;

    setUp(() {
      mockPdfFileStore = MockPdfFileStore();
      mockHiveKeyValueStore = MockHiveKeyValueStore();
      downloadRepository = DownloadRepository(
        pdfFileStore: mockPdfFileStore,
        articleKVStore: mockHiveKeyValueStore,
      );
      filePath = '/path/file.pdf';
      article.downloadFile = filePath;
    });

    test('gets list of Articles', () {
      when(() => mockHiveKeyValueStore.keys).thenReturn([123]);
      when(() => mockHiveKeyValueStore.load(key: 123)).thenReturn(article);
      List<Article> result = downloadRepository.articleList;
      expect(result, [article]);
    });

    test('deletes Article metadata and PDF', () async {
      when(() => mockPdfFileStore.delete(
            filePath: filePath,
          )).thenAnswer((_) => Future.value());

      when(() => mockHiveKeyValueStore.delete(key: 123))
          .thenAnswer((_) => Future.value());

      when(() => mockHiveKeyValueStore.load(key: 123)).thenReturn(article);

      await downloadRepository.delete(id: 123);
      verify(() => mockHiveKeyValueStore.delete(key: 123)).called(1);
      verify(() => mockPdfFileStore.delete(filePath: filePath)).called(1);
    });

    test(
        'saves Article metadata and PDF in a transaction safe manner and returns true',
        () async {
      when(() => mockPdfFileStore.saveAsBytes(
            file: any(named: 'file'),
            filename: any(named: 'filename'),
          )).thenAnswer((_) => Future.value(filePath));

      when(() => mockHiveKeyValueStore.save(
            key: any(named: 'key'),
            value: any(named: 'value'),
          )).thenAnswer((_) => Future.value());

      bool result = await downloadRepository.save(
        article: article,
        pdf: pdf,
      );
      expect(result, true);
    });

    test(
        'fails to save Article metadata and PDF in a transaction safe manner and returns false',
        () async {
      when(() => mockPdfFileStore.saveAsBytes(
            file: any(named: 'file'),
            filename: any(named: 'filename'),
          )).thenAnswer((_) => Future.value(null));

      bool result = await downloadRepository.save(
        article: article,
        pdf: pdf,
      );
      expect(result, false);
    });
  });
}
