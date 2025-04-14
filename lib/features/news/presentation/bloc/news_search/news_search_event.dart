part of 'news_search_bloc.dart';

/// Base class for all search events
sealed class NewsSearchEvent extends Equatable {
  const NewsSearchEvent();

  @override
  List<Object> get props => [];
}

/// Trigger a new search
class SearchNewsEvent extends NewsSearchEvent {
  final String query;

  const SearchNewsEvent(this.query);

  @override
  List<Object> get props => [query];
}

/// Load next page of results
class LoadMoreNewsEvent extends NewsSearchEvent {}

/// Refresh current search query
class RefreshNewsEvent extends NewsSearchEvent {
  final String query;

  const RefreshNewsEvent(this.query);

  @override
  List<Object> get props => [query];
}
