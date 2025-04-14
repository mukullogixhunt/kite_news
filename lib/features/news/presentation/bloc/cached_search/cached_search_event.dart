part of 'cached_search_bloc.dart';

sealed class CachedSearchEvent extends Equatable {
  const CachedSearchEvent();

  @override
  List<Object> get props => [];
}

class LoadCachedTermsEvent extends CachedSearchEvent {}

class ClearCachedTermsEvent extends CachedSearchEvent {}

class AddSearchTermEvent extends CachedSearchEvent {
  final String term;

  const AddSearchTermEvent(this.term);

  @override
  List<Object> get props => [term];
}
