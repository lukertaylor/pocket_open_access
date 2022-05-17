import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../shared/common_imports/common_imports_barrel.dart';
import '../../../shared/themes/default_theme_data.dart';
import '../../download/cubit/downloads_cubit.dart';
import '../../search/cubit/advanced_search_cubit.dart';
import '../../search/cubit/search_cubit.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (screenIsTooSmall(context)) {
      return const ShowTooSmallScreen();
    }
    return BlocProvider(
      create: (_) => AdvancedSearchCubit(),
      child: BlocConsumer<SearchCubit, SearchState>(
        listener: (context, searchState) {
          if (searchState is NoInternet) {
            showSnackBar(
              key: const Key('noInternetSnackBar'),
              text: AppLocalizations.of(context)!.noInternetSnackBar,
              context: context,
            );
          } else if (searchState is SearchComplete) {
            Navigator.pushNamed(
              context,
              '/search-results',
              arguments: searchState.articles,
            );
          } else if (searchState is SearchFailed) {
            showSnackBar(
              key: const Key('searchFailedSnackBar'),
              text: AppLocalizations.of(context)!.searchFailed,
              context: context,
            );
          }
        },
        builder: (context, searchState) {
          return SafeArea(
            child: DefaultTabController(
              length: 2,
              child: Scaffold(
                appBar: const PreferredSize(
                  preferredSize:
                      Size(double.infinity, kToolbarHeight + kTextTabBarHeight),
                  child: HomeAppBar(),
                ),
                body: TabBarView(
                  children: [
                    BlocBuilder<AdvancedSearchCubit, bool>(
                        builder: (context, showAdvancedSearch) {
                      if (showAdvancedSearch) {
                        return AdvancedSearchForm(searchState: searchState);
                      } else {
                        return SimpleSearchForm(searchState: searchState);
                      }
                    }),
                    const DownloadsList(),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class DownloadsList extends StatelessWidget {
  const DownloadsList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DownloadsCubit, List<Article>>(
      builder: (context, downloadList) {
        return downloadList.isEmpty
            ? const NoDownloads()
            : ListView.builder(
                padding: const EdgeInsets.all(10.0),
                itemCount: downloadList.length,
                itemBuilder: (BuildContext context, int index) {
                  return ArticleCard(
                    article: downloadList[index],
                    isDownloaded: true,
                    key: Key(index.toString()),
                  );
                },
              );
      },
    );
  }
}

class NoDownloads extends StatelessWidget {
  const NoDownloads({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        AppLocalizations.of(context)!.noDownloads,
        style: const TextStyle(
          fontSize: 18.0,
        ),
      ),
    );
  }
}

class HomeAppBar extends StatelessWidget {
  const HomeAppBar({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      iconTheme: Theme.of(context).iconTheme,
      title: Row(
        children: [
          Transform.scale(
            scale: 1.2,
            child: ImageIcon(
              const AssetImage(
                'assets/images/open-access-logo-transparent.png',
              ),
              color: colorScheme().secondary,
            ),
          ),
          const SizedBox(
            width: 5.0,
          ),
          Text(
            'Pocket',
            semanticsLabel: AppLocalizations.of(context)!.semanticAppTitle,
          ),
        ],
      ),
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontSize: 28.0,
        fontFamily: 'Roboto',
        fontWeight: FontWeight.w600,
        color: colorScheme().secondary,
      ),
      bottom: TabBar(
        indicatorColor: colorScheme().secondary,
        tabs: [
          Tab(text: AppLocalizations.of(context)!.searchTab),
          Tab(text: AppLocalizations.of(context)!.downloadsTab),
        ],
      ),
    );
  }
}

class SimpleSearchForm extends StatefulWidget {
  const SimpleSearchForm({required this.searchState, Key? key})
      : super(key: key);

  final SearchState searchState;

  @override
  _SimpleSearchFormState createState() => _SimpleSearchFormState();
}

class _SimpleSearchFormState extends State<SimpleSearchForm> {
  final _searchResetFormKey = GlobalKey<FormState>();
  final _searchTextFormFieldController = TextEditingController();
  var _autovalidateMode = AutovalidateMode.disabled;
  var _showClearButton = false;

  @override
  void initState() {
    super.initState();
    _searchTextFormFieldController.addListener(() {
      setState(() {
        _showClearButton = _searchTextFormFieldController.text.isNotEmpty;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: maxFormFieldWidth),
          child: Form(
            key: _searchResetFormKey,
            autovalidateMode: _autovalidateMode,
            child: Column(
              children: [
                FormItemPadding(
                  child: TextFormField(
                      key: const Key('simpleSearchTextFormField'),
                      textAlign: TextAlign.center,
                      controller: _searchTextFormFieldController,
                      textInputAction: TextInputAction.search,
                      maxLength: 1000,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        hintText: AppLocalizations.of(context)!.searchHint,
                        counterText: '',
                        suffixIcon: _clearButton(),
                      ),
                      validator: (String? value) {
                        if (textFieldIsNotEmpty(value)) return null;
                        return AppLocalizations.of(context)!.invalidSearch;
                      }),
                ),
                FormItemPadding(
                  child: DefaultButton(
                    key: const Key('searchButton'),
                    isLoading: widget.searchState is SearchInProgress,
                    buttonText: AppLocalizations.of(context)!.searchButton,
                    onButtonPressed: () async {
                      // remove focus from current focus node
                      final currentFocus = FocusScope.of(context);
                      if (!currentFocus.hasPrimaryFocus) {
                        currentFocus.unfocus();
                      }
                      if (_searchResetFormKey.currentState!.validate()) {
                        _searchResetFormKey.currentState!.save();
                        await context.read<SearchCubit>().search(
                              query: _searchTextFormFieldController.text,
                            );
                      } else {
                        // auto validate from this point forward
                        setState(() {
                          _autovalidateMode =
                              AutovalidateMode.onUserInteraction;
                        });
                      }
                    },
                  ),
                ),
                FormItemPadding(
                  child: LinkButton(
                    buttonText:
                        AppLocalizations.of(context)!.switchToAdvancedSearch,
                    onButtonPressed: context
                        .read<AdvancedSearchCubit>()
                        .switchToAdvancedSearch,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget? _clearButton() {
    if (_showClearButton) {
      return IconButton(
        onPressed: () => _searchTextFormFieldController.clear(),
        icon: Icon(
          Icons.clear,
          semanticLabel: AppLocalizations.of(context)!.clearSearchSemantic,
        ),
      );
    } else {
      return null;
    }
  }

  @override
  void dispose() {
    _searchTextFormFieldController.dispose();
    super.dispose();
  }
}

class AdvancedSearchForm extends StatefulWidget {
  const AdvancedSearchForm({
    required this.searchState,
    Key? key,
  }) : super(key: key);

  final SearchState searchState;

  @override
  State<AdvancedSearchForm> createState() => _AdvancedSearchFormState();
}

class _AdvancedSearchFormState extends State<AdvancedSearchForm> {
  final _advancedSearchFormKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _fromYearController = TextEditingController();
  final _toYearController = TextEditingController();
  final _publisherController = TextEditingController();
  var _autovalidateMode = AutovalidateMode.disabled;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: maxFormFieldWidth),
          child: Form(
            key: _advancedSearchFormKey,
            autovalidateMode: _autovalidateMode,
            child: Column(
              children: [
                FormItemPadding(
                  child: TextFormField(
                    key: const Key('titleTextFormField'),
                    textAlign: TextAlign.center,
                    controller: _titleController,
                    textInputAction: TextInputAction.search,
                    maxLength: 1000,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      hintText: AppLocalizations.of(context)!.titleHint,
                      counterText: '',
                    ),
                  ),
                ),
                FormItemPadding(
                  child: TextFormField(
                    key: const Key('authorTextFormField'),
                    textAlign: TextAlign.center,
                    controller: _authorController,
                    textInputAction: TextInputAction.search,
                    maxLength: 1000,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      hintText: AppLocalizations.of(context)!.authorHint,
                      counterText: '',
                    ),
                  ),
                ),
                FormItemPadding(
                  child: TextFormField(
                    key: const Key('fromYearTextFormField'),
                    textAlign: TextAlign.center,
                    controller: _fromYearController,
                    textInputAction: TextInputAction.search,
                    maxLength: 4,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: AppLocalizations.of(context)!.fromYearHint,
                      counterText: '',
                    ),
                    validator: (String? value) {
                      if (isValidNumberOrEmpty(value)) return null;
                      return AppLocalizations.of(context)!.invalidSearch;
                    },
                  ),
                ),
                FormItemPadding(
                  child: TextFormField(
                    key: const Key('toYearTextFormField'),
                    textAlign: TextAlign.center,
                    controller: _toYearController,
                    textInputAction: TextInputAction.search,
                    maxLength: 4,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: AppLocalizations.of(context)!.toYearHint,
                      counterText: '',
                    ),
                    validator: (String? value) {
                      if (isValidNumberOrEmpty(value)) return null;
                      return AppLocalizations.of(context)!.invalidSearch;
                    },
                  ),
                ),
                FormItemPadding(
                  child: TextFormField(
                    key: const Key('publisherTextFormField'),
                    textAlign: TextAlign.center,
                    controller: _publisherController,
                    textInputAction: TextInputAction.search,
                    maxLength: 1000,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      hintText: AppLocalizations.of(context)!.publisherHint,
                      counterText: '',
                    ),
                  ),
                ),
                FormItemPadding(
                  child: DefaultButton(
                    key: const Key('searchButton'),
                    isLoading: widget.searchState is SearchInProgress,
                    buttonText: AppLocalizations.of(context)!.searchButton,
                    onButtonPressed: () async {
                      // remove focus from current focus node
                      final currentFocus = FocusScope.of(context);
                      if (!currentFocus.hasPrimaryFocus) {
                        currentFocus.unfocus();
                      }
                      if (_advancedSearchFormKey.currentState!.validate()) {
                        _advancedSearchFormKey.currentState!.save();
                        String query = buildAdvancedSearchQuery(
                          title: _titleController.text,
                          author: _authorController.text,
                          fromYear: _fromYearController.text,
                          toYear: _toYearController.text,
                          publisher: _publisherController.text,
                        );
                        await context.read<SearchCubit>().search(
                              query: query,
                            );
                      } else {
                        // auto validate from this point forward
                        setState(() {
                          _autovalidateMode =
                              AutovalidateMode.onUserInteraction;
                        });
                      }
                    },
                  ),
                ),
                const SizedBox(
                  height: 20.0,
                ),
                LinkButton(
                  buttonText: AppLocalizations.of(context)!.resetForm,
                  onButtonPressed: _resetForm,
                ),
                LinkButton(
                  buttonText:
                      AppLocalizations.of(context)!.switchToSimpleSearch,
                  onButtonPressed:
                      context.read<AdvancedSearchCubit>().switchToSimpleSearch,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _resetForm() {
    // remove focus from current focus node
    final currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus) {
      currentFocus.unfocus();
    }
    _titleController.clear();
    _authorController.clear();
    _fromYearController.clear();
    _toYearController.clear();
    _publisherController.clear();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _fromYearController.dispose();
    _toYearController.dispose();
    _publisherController.dispose();
    super.dispose();
  }
}

String buildAdvancedSearchQuery({
  required String title,
  required String author,
  required String fromYear,
  required String toYear,
  required String publisher,
}) {
  var query = '';
  var queryHasOtherElement = false;
  if (title.isNotEmpty) {
    query += 'title:$title';
    queryHasOtherElement = true;
  }
  if (author.isNotEmpty) {
    if (queryHasOtherElement) query += ' AND ';
    query += 'author:$author';
    queryHasOtherElement = true;
  }
  if (fromYear.isNotEmpty || toYear.isNotEmpty) {
    if (queryHasOtherElement) query += ' AND ';
    query += '(';
    if (fromYear.isNotEmpty) {
      query += 'yearPublished>=$fromYear';
      queryHasOtherElement = true;
    }
    if (toYear.isNotEmpty) {
      if (fromYear.isNotEmpty) query += ' AND ';
      query += 'yearPublished<=$toYear';
      queryHasOtherElement = true;
    }
    query += ')';
  }
  if (publisher.isNotEmpty) {
    if (queryHasOtherElement) query += ' AND ';
    query += 'publisher:$publisher';
    queryHasOtherElement = true;
  }
  return query;
}

bool textFieldIsNotEmpty(String? value) {
  if (value == '' || value == null) {
    return false;
  } else {
    return true;
  }
}

bool isValidNumberOrEmpty(String? value) {
  if (value == '' || value == null) return true;
  if (int.tryParse(value) != null) return true;
  return false;
}
