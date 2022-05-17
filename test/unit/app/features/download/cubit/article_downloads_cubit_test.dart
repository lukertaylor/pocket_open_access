import 'dart:typed_data';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pocket_open_access/app/features/download/cubit/downloads_cubit.dart';
import 'package:pocket_open_access/app/features/download/repository/download_repository.dart';
import 'package:pocket_open_access/app/shared/common_imports/common_imports_barrel.dart';

class MockDownloadRepository extends Mock implements DownloadRepository {}

void main() {
  late DownloadRepository mockDownloadRepository;
  late List<Article> articles;
  late Article newArticle;
  late DownloadsCubit articleDownloadsCubit;
  late Uint8List pdf;

  setUp(() {
    mockDownloadRepository = MockDownloadRepository();
    articles = [
      Article(
        123,
        'A very interesting article',
        [const Author('Luke')],
        'Cotham publishing',
        '2020-12-31T23:59:59',
        'This is such an interesting article',
        'https://a.valid.link/',
      ),
      Article(
        321,
        'Another very interesting article',
        [],
        null,
        null,
        null,
        null,
      )
    ];
    registerFallbackValue(articles);
    newArticle = Article(
      111,
      'A new article',
      [],
      null,
      null,
      null,
      null,
    );
    registerFallbackValue(newArticle);
    pdf = Uint8List(1);
    registerFallbackValue(pdf);

    serviceLocator.isRegistered<DownloadRepository>()
        ? serviceLocator.unregister<DownloadRepository>()
        : null;
    serviceLocator
        .registerFactory<DownloadRepository>(() => mockDownloadRepository);

    articleDownloadsCubit = DownloadsCubit(
      downloads: articles,
    );
  });

  tearDown(() => articleDownloadsCubit.close());

  group('Article-downloads Cubit', () {
    blocTest<DownloadsCubit, List<Article>>(
      'downloadArticle saves Article and emits Article list that incorporates new Article, sorted by title.',
      setUp: () {
        when(
          () => mockDownloadRepository.save(
            article: any(named: 'article'),
            pdf: any(named: 'pdf'),
          ),
        ).thenAnswer(
          (_) => Future.value(true),
        );
      },
      build: () => articleDownloadsCubit,
      act: (cubit) => cubit.downloadArticle(article: newArticle, pdf: pdf),
      expect: () => <dynamic>[
        isA<List<Article>>()
            .having((a) => a.length, 'length', 3)
            .having((a) => a[0].id, 'id', 111)
      ],
    );

    blocTest<DownloadsCubit, List<Article>>(
      'removeDownload deletes Article download and emits new Article list without Article.',
      setUp: () {
        when(
          () => mockDownloadRepository.delete(id: any(named: 'id')),
        ).thenAnswer(
          (_) => Future.value(),
        );
      },
      build: () => articleDownloadsCubit,
      act: (cubit) => cubit.removeDownload(article: articles[0]),
      expect: () => <dynamic>[
        isA<List<Article>>()
            .having((a) => a.length, 'length', 1)
            .having((a) => a[0].id, 'id', 321)
      ],
    );
  });
}
