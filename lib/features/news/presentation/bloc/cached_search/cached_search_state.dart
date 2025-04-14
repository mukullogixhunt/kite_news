part of 'cached_search_bloc.dart';

/// Base class for all cached search states
sealed class CachedSearchState extends Equatable {
  const CachedSearchState();

  @override
  List<Object> get props => [];
}

/// Initial state before any action is taken
class CachedSearchInitial extends CachedSearchState {}

/// State when cached terms are being loaded
class CachedSearchLoading extends CachedSearchState {}

/// State when cached terms are successfully loaded
class CachedSearchLoaded extends CachedSearchState {
  final List<String> terms;

  const CachedSearchLoaded(this.terms);

  @override
  List<Object> get props => [terms];
}

/// State when an error occurs while handling cached terms
class CachedSearchError extends CachedSearchState {
  final String message;

  const CachedSearchError(this.message);

  @override
  List<Object> get props => [message];
}
