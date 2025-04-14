import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';

import '../../../../../core/usecase/usecase.dart';
import '../../../domain/usecases/cache_search_term.dart';
import '../../../domain/usecases/clear_cached_search_terms.dart';
import '../../../domain/usecases/get_cached_search_terms.dart';

part 'cached_search_event.dart';

part 'cached_search_state.dart';

class CachedSearchBloc extends Bloc<CachedSearchEvent, CachedSearchState> {
  final GetCachedSearchTerms getCachedSearchTerms;
  final CacheSearchTerm cacheSearchTerm;
  final ClearCachedSearchTerms clearCachedSearchTerms;

  CachedSearchBloc({
    required this.getCachedSearchTerms,
    required this.cacheSearchTerm,
    required this.clearCachedSearchTerms,
  }) : super(CachedSearchInitial()) {
    on<CachedSearchEvent>((event, emit) {});

    on<LoadCachedTermsEvent>(_onLoadCachedTerms);
    on<AddSearchTermEvent>(_onAddSearchTerm, transformer: sequential());
    on<ClearCachedTermsEvent>(_onClearCachedTerms);
  }

  Future<void> _onLoadCachedTerms(
    LoadCachedTermsEvent event,
    Emitter<CachedSearchState> emit,
  ) async {
    emit(CachedSearchLoading());
    final result = await getCachedSearchTerms(NoParams());
    result.fold(
      (failure) => emit(CachedSearchError(failure.message)),
      (terms) => emit(CachedSearchLoaded(terms)),
    );
  }

  Future<void> _onAddSearchTerm(
    AddSearchTermEvent event,
    Emitter<CachedSearchState> emit,
  ) async {
    final trimmedTerm = event.term.trim();
    if (trimmedTerm.isEmpty) return;

    final cacheResult = await cacheSearchTerm(
      CacheSearchTermParams(term: trimmedTerm),
    );

    cacheResult.fold((failure) {
      emit(CachedSearchError("Failed to save search: ${failure.message}"));
      add(LoadCachedTermsEvent());
    }, (_) => add(LoadCachedTermsEvent()));
  }

  Future<void> _onClearCachedTerms(
    ClearCachedTermsEvent event,
    Emitter<CachedSearchState> emit,
  ) async {
    final result = await clearCachedSearchTerms(NoParams());
    result.fold((failure) {
      emit(CachedSearchError("Failed to clear searches: ${failure.message}"));
      add(LoadCachedTermsEvent());
    }, (_) => emit(const CachedSearchLoaded([])));
  }
}
