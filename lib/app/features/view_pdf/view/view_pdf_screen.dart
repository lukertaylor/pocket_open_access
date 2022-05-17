import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import '../../../shared/common_imports/common_imports_barrel.dart';
import '../../../shared/themes/default_theme_data.dart';
import '../../../shared/widgets/loading_dots.dart';
import '../../download/cubit/downloads_cubit.dart';
import '../../download/repository/download_repository.dart';
import '../cubit/pdf_load_cubit.dart';
import '../cubit/pdf_search_status_cubit.dart';

class PdfViewerCubitProvider extends StatelessWidget {
  final Article article;

  const PdfViewerCubitProvider({required this.article, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => PdfLoadStatusCubit(),
        ),
        BlocProvider(
          create: (_) => PdfSearchStatusCubit(),
        ),
      ],
      child: ViewPdfScreen(
        article: article,
      ),
    );
  }
}

class ViewPdfScreen extends StatefulWidget {
  final Article article;

  const ViewPdfScreen({required this.article, Key? key}) : super(key: key);

  @override
  State<ViewPdfScreen> createState() => _ViewPdfScreenState();
}

class _ViewPdfScreenState extends State<ViewPdfScreen> {
  late PdfViewerController _pdfViewerController;
  late PdfTextSearchResult _pdfTextSearchResult;
  OverlayEntry? overlayEntry;

  @override
  void initState() {
    _pdfViewerController = PdfViewerController();
    _pdfTextSearchResult = PdfTextSearchResult();
    context.read<PdfLoadStatusCubit>().loadPdf(article: widget.article);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (screenIsTooSmall(context)) {
      return const ShowTooSmallScreen();
    }

    return SafeArea(
        child: Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size(double.infinity, kToolbarHeight),
        child: BlocBuilder<PdfSearchStatusCubit, PdfSearchStatus>(
          builder: (context, searchState) {
            return AppBar(
              leading: _leading(searchState),
              title: _title(searchState),
              actions: _actions(searchState),
              titleTextStyle: TextStyle(
                fontSize: 28.0,
                fontFamily: 'Roboto',
                fontWeight: FontWeight.w600,
                color: colorScheme().secondary,
              ),
            );
          },
        ),
      ),
      body: BlocConsumer<PdfLoadStatusCubit, PdfLoadState>(
        builder: (context, loadState) {
          return _bodyWidget(loadState);
        },
        listener: (context, loadState) {
          if (loadState is PdfLoadSuccess) {
            context.read<PdfSearchStatusCubit>().readyToSearch();
          }
        },
      ),
    ));
  }

  Widget _bodyWidget(PdfLoadState loadState) {
    if (loadState is PdfLoadSuccess) {
      return Semantics(
        label: AppLocalizations.of(context)!.pdfViewerSemanticLabel,
        child: SfPdfViewer.memory(
          loadState.pdf,
          controller: _pdfViewerController,
          canShowPaginationDialog: false,
          canShowScrollHead: false,
          canShowScrollStatus: false,
          onDocumentLoadFailed: (PdfDocumentLoadFailedDetails details) {
            context.read<PdfLoadStatusCubit>().loadFailed();
          },
          enableTextSelection: true,
          onTextSelectionChanged: (PdfTextSelectionChangedDetails details) {
            if (details.selectedText == null && overlayEntry != null) {
              overlayEntry!.remove();
              overlayEntry = null;
            } else if (details.selectedText != null && overlayEntry == null) {
              _pdfTextSearchResult.clear();
              context.read<PdfSearchStatusCubit>().cancelSearch();
              final OverlayState _overlayState = Overlay.of(context)!;
              overlayEntry = OverlayEntry(
                builder: (context) => Positioned(
                  top: details.globalSelectedRegion!.center.dy - 55,
                  left: details.globalSelectedRegion!.bottomLeft.dx + 100,
                  child: ElevatedButton(
                    onPressed: () {
                      Clipboard.setData(
                          ClipboardData(text: details.selectedText));
                      _pdfViewerController.clearSelection();
                    },
                    child: Text(
                      AppLocalizations.of(context)!.pdfCopyButtonText,
                      style: const TextStyle(
                        fontSize: 17,
                      ),
                    ),
                    style:
                        ButtonStyle(elevation: MaterialStateProperty.all(10.0)),
                  ),
                ),
              );
              _overlayState.insert(overlayEntry!);
            }
          },
        ),
      );
    } else if (loadState is PdfLoadFailed) {
      return const PdfLoadFailureMessage();
    } else {
      return LoadingDots(
        color: colorScheme().primary,
        text: AppLocalizations.of(context)!.loadingSemantic,
      );
    }
  }

  List<Widget> _actions(PdfSearchStatus searchState) {
    if (searchState is Initial) {
      return [
        const Padding(
          padding: EdgeInsets.only(right: 8.0),
          child: SearchInPage(),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 12.0),
          child: DownloadArticle(
            article: widget.article,
          ),
        )
      ];
    } else if (searchState is Complete) {
      return [
        Align(
          child: Text(
            '${_pdfTextSearchResult.currentInstanceIndex} ${AppLocalizations.of(context)!.pdfSearchResultOf} ${_pdfTextSearchResult.totalInstanceCount}',
            style: const TextStyle(fontSize: 16.0),
          ),
        ),
        IconButton(
          onPressed: () {
            setState(() {
              _pdfTextSearchResult.previousInstance();
            });
          },
          icon: Icon(
            Icons.chevron_left_outlined,
            size: 30.0,
            semanticLabel: AppLocalizations.of(context)!.previousSearchSemantic,
          ),
        ),
        IconButton(
          onPressed: () {
            setState(() {
              _pdfTextSearchResult.nextInstance();
            });
          },
          icon: Icon(
            Icons.navigate_next_outlined,
            size: 30.0,
            semanticLabel: AppLocalizations.of(context)!.nextSearchSemantic,
          ),
        )
      ];
    } else {
      return [];
    }
  }

  Widget? _leading(PdfSearchStatus searchState) {
    if (_isSearch(searchState)) {
      return IconButton(
        onPressed: () {
          _pdfTextSearchResult.clear();
          context.read<PdfSearchStatusCubit>().cancelSearch();
        },
        icon: Icon(
          Icons.close_outlined,
          size: 30.0,
          semanticLabel: AppLocalizations.of(context)!.clearSearchSemantic,
        ),
      );
    } else {
      return null;
    }
  }

  Widget _title(PdfSearchStatus searchState) {
    if (_isSearch(searchState)) {
      return TextField(
        autofocus: true,
        onSubmitted: (text) async {
          if (text.isNotEmpty) {
            _pdfViewerController.clearSelection();
            _pdfTextSearchResult = await _pdfViewerController.searchText(text);
            context.read<PdfSearchStatusCubit>().searchComplete();
          }
        },
        textInputAction: TextInputAction.search,
        showCursor: true,
        cursorColor: colorScheme().background,
        style: TextStyle(color: colorScheme().background, fontSize: 20.0),
        decoration: InputDecoration(
          hintText: AppLocalizations.of(context)!.pdfSearchHint,
          hintStyle: TextStyle(color: colorScheme().background),
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          focusedErrorBorder: InputBorder.none,
        ),
      );
    } else {
      return const PdfViewTitle();
    }
  }

  bool _isSearch(PdfSearchStatus state) {
    return state is InProgress || state is Complete;
  }
}

class PdfViewTitle extends StatelessWidget {
  const PdfViewTitle({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      AppLocalizations.of(context)!.viewPdfScreenTitle,
      key: const Key('appBarTitleKey'),
    );
  }
}

class SearchInPage extends StatelessWidget {
  const SearchInPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      key: const Key('searchIconButtonKey'),
      onPressed: () {
        context.read<PdfSearchStatusCubit>().searchInProgress();
      },
      icon: Icon(
        Icons.search_outlined,
        semanticLabel: AppLocalizations.of(context)!.searchSemantic,
        size: 30.0,
      ),
    );
  }
}

class DownloadArticle extends StatefulWidget {
  const DownloadArticle({
    required this.article,
    Key? key,
  }) : super(key: key);

  final Article article;

  @override
  State<DownloadArticle> createState() => _DownloadArticleState();
}

class _DownloadArticleState extends State<DownloadArticle> {
  late bool articleIsDownloaded;

  @override
  void initState() {
    articleIsDownloaded = serviceLocator.get<DownloadRepository>().exists(
          article: widget.article,
        );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return articleIsDownloaded
        ? Icon(
            Icons.check_circle_outlined,
            semanticLabel: AppLocalizations.of(context)!.downloadedSemantic,
            size: 30.0,
          )
        : BlocBuilder<PdfLoadStatusCubit, PdfLoadState>(
            builder: (context, state) {
              return IconButton(
                key: const Key('downloadArticleKey'),
                onPressed: () {
                  if (state is PdfLoadSuccess) {
                    context.read<DownloadsCubit>().downloadArticle(
                          article: widget.article,
                          pdf: state.pdf,
                        );
                    setState(() {
                      articleIsDownloaded = true;
                    });
                  }
                },
                icon: Icon(
                  Icons.file_download_outlined,
                  semanticLabel:
                      AppLocalizations.of(context)!.downloadArticleSemantic,
                  size: 30.0,
                ),
              );
            },
          );
  }
}

class PdfLoadFailureMessage extends StatelessWidget {
  const PdfLoadFailureMessage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Text(
          AppLocalizations.of(context)!.pdfLoadFailureMessage,
          key: const Key('pdfLoadFailureMessage'),
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 17.0,
          ),
        ),
      ),
    );
  }
}
