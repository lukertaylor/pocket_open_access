part of 'search_cubit.dart';

abstract class SearchState extends Equatable {
  const SearchState();

  @override
  List<Object> get props => [];
}

class HomeInitial extends SearchState {}

class NoInternet extends SearchState {}

class SearchInProgress extends SearchState {}

class SearchFailed extends SearchState {}

class SearchComplete extends SearchState {
  final List<Article> articles;

  const SearchComplete(this.articles);
}
