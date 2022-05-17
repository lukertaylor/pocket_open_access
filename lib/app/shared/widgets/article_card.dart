import 'package:pocket_open_access/app/features/download/cubit/downloads_cubit.dart';
import 'package:pocket_open_access/app/shared/common_imports/common_imports_barrel.dart';
import 'package:provider/provider.dart';

class ArticleCard extends StatelessWidget {
  const ArticleCard({
    required this.article,
    required this.isDownloaded,
    Key? key,
  }) : super(key: key);

  final Article article;
  final bool isDownloaded;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Card(
          elevation: 5.0,
          child: InkWell(
            key: const Key('articleTapKey'),
            onTap: () async {
              if (isDownloaded) {
                Navigator.pushNamed(
                  context,
                  '/article-detail',
                  arguments: article,
                );
              } else {
                await hasInternet()
                    ? Navigator.pushNamed(
                        context,
                        '/article-detail',
                        arguments: article,
                      )
                    : showSnackBar(
                        key: const Key('noInternetSnackBar'),
                        text: AppLocalizations.of(context)!.noInternetSnackBar,
                        context: context,
                      );
              }
            },
            // splashColor: oxfordBlue50,
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    flex: 7,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          article.title,
                          key: const Key('titleKey'),
                          semanticsLabel:
                              '${AppLocalizations.of(context)!.titleSemanticLabel} ${article.title}',
                          style: const TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(
                          height: 5.0,
                        ),
                        Text(
                          'By: ${authorsAsString(
                            authors: article.authors,
                            limit: 5,
                          )}',
                          key: const Key('authorsKey'),
                        ),
                        const SizedBox(
                          height: 5.0,
                        ),
                        Text(
                          'Publisher: ${article.publisher}',
                          key: const Key('publisherKey'),
                        ),
                        const SizedBox(
                          height: 5.0,
                        ),
                        FutureBuilder(
                          future: localeFormattedDate(article.publishedDate),
                          builder: (BuildContext context,
                              AsyncSnapshot<String> snapshot) {
                            if (snapshot.hasData) {
                              String _formattedDate = snapshot.data!;
                              return Text(
                                'Date: $_formattedDate',
                                key: const Key('publishedDateKey'),
                              );
                            }
                            return const Text(
                              'Date: ',
                              key: Key('publishedDateKey'),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  Flexible(
                      flex: 1,
                      child: isDownloaded
                          ? IconButton(
                              icon: const Icon(
                                Icons.delete_outline_outlined,
                                // color: oxfordBlue,
                                size: 30.0,
                              ),
                              onPressed: () {
                                showDialog(
                                    context: context,
                                    builder: (_) => DefaultDialog(
                                            dialogKey: const Key(
                                                'deleteDownloadConfirmation'),
                                            message:
                                                "${AppLocalizations.of(context)!.deleteDownload} - '${article.title}'?",
                                            dialogButtons: [
                                              DefaultDialogButton(
                                                buttonKey: const Key('cancel'),
                                                buttonText: AppLocalizations.of(
                                                        context)!
                                                    .cancelButton,
                                                onButtonPressed: () =>
                                                    Navigator.pop(context),
                                              ),
                                              DefaultDialogButton(
                                                  buttonKey:
                                                      const Key('continue'),
                                                  buttonText:
                                                      AppLocalizations.of(
                                                              context)!
                                                          .continueButton,
                                                  onButtonPressed: () {
                                                    context
                                                        .read<DownloadsCubit>()
                                                        .removeDownload(
                                                          article: article,
                                                        );
                                                    Navigator.pop(context);
                                                  })
                                            ]));
                              },
                            )
                          : const Text(' '))
                ],
              ),
            ),
          ),
        ),
        const SizedBox(
          height: 10.0,
        )
      ],
    );
  }
}
