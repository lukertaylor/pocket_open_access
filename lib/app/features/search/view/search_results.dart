import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../shared/common_imports/common_imports_barrel.dart';
import '../../../shared/themes/default_theme_data.dart';
import '../cubit/search_cubit.dart';

class SearchResults extends StatelessWidget {
  const SearchResults({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (screenIsTooSmall(context)) {
      return const ShowTooSmallScreen();
    }
    return BlocBuilder<SearchCubit, SearchState>(
      builder: (context, searchState) {
        if (searchState is SearchComplete) {
          return SafeArea(
            child: Scaffold(
              appBar: AppBar(
                title: Text(AppLocalizations.of(context)!.searchResultsTitle),
                titleTextStyle: TextStyle(
                  fontSize: 28.0,
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w600,
                  color: colorScheme().secondary,
                ),
              ),
              body: searchState.articles.isEmpty
                  ? const NoResults()
                  : ListView.builder(
                      padding: const EdgeInsets.all(10.0),
                      itemCount: searchState.articles.length,
                      itemBuilder: (BuildContext context, int index) {
                        return ArticleCard(
                          article: searchState.articles[index],
                          isDownloaded: false,
                          key: Key(index.toString()),
                        );
                      },
                    ),
            ),
          );
        } else {
          throw InvalidStateException(searchState);
        }
      },
    );
  }
}

class NoResults extends StatelessWidget {
  const NoResults({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        AppLocalizations.of(context)!.noResultsMessage,
        style: const TextStyle(
          fontSize: 18.0,
        ),
      ),
    );
  }
}
