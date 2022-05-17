import '../../../shared/common_imports/common_imports_barrel.dart';
import '../../../shared/themes/default_theme_data.dart';
import '../../../shared/widgets/loading_dots.dart';
import '../../download/repository/download_repository.dart';

/// Shows more detailed information about an Article.
/// Linked to from a list of Articles
class ArticleDetailScreen extends StatelessWidget {
  const ArticleDetailScreen({
    required this.article,
    Key? key,
  }) : super(key: key);

  final Article article;

  @override
  Widget build(BuildContext context) {
    if (screenIsTooSmall(context)) {
      return const ShowTooSmallScreen();
    }
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.articleDetailTitle),
          titleTextStyle: TextStyle(
            fontSize: 28.0,
            fontFamily: 'Roboto',
            fontWeight: FontWeight.w600,
            color: colorScheme().secondary,
          ),
          key: const Key('articleDetailAppBarKey'),
        ),
        body: ListView(
          padding: const EdgeInsets.all(20.0),
          children: [
            Text(
              article.title,
              key: const Key('titleKey'),
              semanticsLabel:
                  '${AppLocalizations.of(context)!.titleSemanticLabel}: ${article.title}',
              style: const TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            Text(
              '${AppLocalizations.of(context)!.articleBy}: ${authorsAsString(authors: article.authors)}',
              key: const Key('authorsKey'),
              style: const TextStyle(
                fontSize: 16.0,
              ),
            ),
            const Spacer(),
            Text(
              "${AppLocalizations.of(context)!.articlePublisher}: ${article.publisher ?? ''}",
              key: const Key('publisherKey'),
              style: const TextStyle(
                fontSize: 16.0,
              ),
            ),
            const Spacer(),
            FutureBuilder(
              future: localeFormattedDate(article.publishedDate),
              builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                return Text(
                  "${AppLocalizations.of(context)!.articleDate}: ${snapshot.hasData ? snapshot.data! : ''}",
                  key: const Key('dateKey'),
                  style: const TextStyle(
                    fontSize: 16.0,
                  ),
                );
              },
            ),
            const Spacer(),
            Text(
              "${AppLocalizations.of(context)!.articleSummary}: ${article.summary ?? ''}",
              key: const Key('summaryKey'),
              style: const TextStyle(
                fontSize: 16.0,
              ),
            ),
            const Spacer(),
            FormItemPadding(
              child: FutureBuilder(
                  future: articleLink(article: article),
                  builder:
                      (BuildContext context, AsyncSnapshot<Widget> snapshot) {
                    if (snapshot.hasData) {
                      return snapshot.data!;
                    }
                    return LoadingDots(
                      key: const Key('linkCheckProgressIndicatorKey'),
                      color: colorScheme().primary,
                      text: AppLocalizations.of(context)!.lookingForPdf,
                    );
                  }),
            ),
          ],
        ),
      ),
    );
  }
}

// Shows either button to link to PDF,
// button to link to web,
// or message that article is not available
Future<Widget> articleLink({
  required Article article,
  Future<bool> Function({required String? url})? linkCheck,
}) async {
  Future<bool> Function({required String? url}) _isValidLink =
      linkCheck ?? isValidLink;
  final _articleIsDownloaded = serviceLocator.get<DownloadRepository>().exists(
        article: article,
      );
  if (_articleIsDownloaded) {
    return ViewPdfButton(
      article: article,
      isDownloaded: true,
    );
  } else {
    bool articleLinkIsValid;
    if (article.downloadUrl == '') {
      articleLinkIsValid = false;
    } else {
      articleLinkIsValid = await _isValidLink(url: article.downloadUrl);
    }
    if (articleLinkIsValid) {
      final url = article.downloadUrl!;
      final articleIsPdf = url.toLowerCase().contains('.pdf');
      if (articleIsPdf) {
        return ViewPdfButton(
          article: article,
          isDownloaded: false,
        );
      } else {
        return LinkToWebButton(url: url);
      }
    } else {
      return const NoArticleLinkMessage();
    }
  }
}

class Spacer extends StatelessWidget {
  const Spacer({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 12.0,
    );
  }
}

class LinkToWebButton extends StatelessWidget {
  const LinkToWebButton({
    required this.url,
    Key? key,
  }) : super(key: key);

  final String url;

  @override
  Widget build(BuildContext context) {
    return DefaultButton(
      key: const Key('linkToWebButton'),
      isLoading: false,
      buttonText: AppLocalizations.of(context)!.articleGoToWeb,
      onButtonPressed: () async {
        await launchLinkInBrowser(url);
      },
    );
  }
}

class ViewPdfButton extends StatelessWidget {
  const ViewPdfButton({
    required this.article,
    required this.isDownloaded,
    Future<bool> Function()? internetCheck,
    Key? key,
  })  : _hasInternet = internetCheck ?? hasInternet,
        super(key: key);

  final Article article;
  final bool isDownloaded;
  final Future<bool> Function() _hasInternet;

  @override
  Widget build(BuildContext context) {
    return DefaultButton(
      key: const Key('viewPdfButton'),
      isLoading: false,
      buttonText: AppLocalizations.of(context)!.articleViewPdf,
      onButtonPressed: () async {
        if (await _hasInternet() || isDownloaded) {
          Navigator.pushNamed(
            context,
            '/view-pdf',
            arguments: article,
          );
        } else {
          showSnackBar(
            key: const Key('noInternetSnackBar'),
            text: AppLocalizations.of(context)!.noInternetSnackBar,
            context: context,
          );
        }
      },
    );
  }
}

class NoArticleLinkMessage extends StatelessWidget {
  const NoArticleLinkMessage({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 8.0,
        horizontal: 0.0,
      ),
      child: Text(
        AppLocalizations.of(context)!.noPdf,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 16.0,
        ),
      ),
    ));
  }
}
