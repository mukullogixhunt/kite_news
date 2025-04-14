part of 'news_search_bloc.dart';

sealed class NewsSearchEvent extends Equatable {
  const NewsSearchEvent();

  @override
  List<Object> get props => [];
}

class SearchNewsEvent extends NewsSearchEvent {
  final String query;

  const SearchNewsEvent(this.query);

  @override
  List<Object> get props => [query];
}

class LoadMoreNewsEvent extends NewsSearchEvent {}

class RefreshNewsEvent extends NewsSearchEvent {
  final String query;

  const RefreshNewsEvent(this.query);

  @override
  List<Object> get props => [query];
}

