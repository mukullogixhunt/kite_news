part of 'cached_search_bloc.dart';

sealed class CachedSearchState extends Equatable {
  const CachedSearchState();
  @override
  List<Object> get props => [];
}

class CachedSearchInitial extends CachedSearchState {}


class CachedSearchLoading extends CachedSearchState {}

class CachedSearchLoaded extends CachedSearchState {
  final List<String> terms;
  const CachedSearchLoaded(this.terms);

  @override
  List<Object> get props => [terms]; 
}


class CachedSearchError extends CachedSearchState {
  final String message;
  const CachedSearchError(this.message);

  @override
  List<Object> get props => [message];
}
