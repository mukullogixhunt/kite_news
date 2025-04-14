part of 'cached_search_bloc.dart';

/// Base class for all cached search events
sealed class CachedSearchEvent extends Equatable {
  const CachedSearchEvent();

  @override
  List<Object> get props => [];
}

/// Event to load cached search terms
class LoadCachedTermsEvent extends CachedSearchEvent {}

/// Event to clear all cached search terms
class ClearCachedTermsEvent extends CachedSearchEvent {}

/// Event to add a new search term to cache
class AddSearchTermEvent extends CachedSearchEvent {
  final String term;

  const AddSearchTermEvent(this.term);

  @override
  List<Object> get props => [term];
}
