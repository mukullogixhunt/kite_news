import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:stack_wealth_news/features/news/domain/entities/article_entity.dart';

import '../../../../../core/constants/app_constants.dart';
import '../../../domain/usecases/get_news.dart';

part 'news_search_event.dart';

part 'news_search_state.dart';

class NewsSearchBloc extends Bloc<NewsSearchEvent, NewsSearchState> {
  final GetNews getNews;

  int _currentPage = 1;
  String _currentQuery = '';
  List<ArticleEntity> _articles = [];
  bool _isLoadingMore = false;
  bool _hasReachedMax = false;

  NewsSearchBloc({required this.getNews}) : super(NewsSearchInitial()) {
    on<NewsSearchEvent>((event, emit) {});

    on<SearchNewsEvent>(_onSearchNews, transformer: restartable());
    on<LoadMoreNewsEvent>(_onLoadMoreNews, transformer: droppable());

  }

  Future<void> _onSearchNews(
    SearchNewsEvent event,
    Emitter<NewsSearchState> emit,
  ) async {
    final trimmedQuery = event.query.trim();
    if (trimmedQuery.isEmpty) {
      return;
    }

    _currentQuery = trimmedQuery;
    _currentPage = 1;
    _articles = [];
    _hasReachedMax = false;
    _isLoadingMore = false;

    emit(NewsSearchLoading(isFirstFetch: true, query: _currentQuery));

    final result = await getNews(
      GetNewsParams(query: _currentQuery, page: _currentPage),
    );

    result.fold(
      (failure) {
        log("Search Error: ${failure.message}");
        emit(NewsSearchError(failure.message, failedQuery: _currentQuery));
      },
      (newArticles) {
        _articles = newArticles;
        _hasReachedMax = newArticles.length < AppConstants.pageSize;
        emit(
          NewsSearchLoaded(
            articles: List.of(_articles),
            hasReachedMax: _hasReachedMax,
            currentQuery: _currentQuery,
          ),
        );
      },
    );
  }

  Future<void> _onLoadMoreNews(
    LoadMoreNewsEvent event,
    Emitter<NewsSearchState> emit,
  ) async {
    final currentState = state;

    if (_isLoadingMore || _hasReachedMax || currentState is! NewsSearchLoaded) {
      log(
        "Load More condition not met: isLoading=$_isLoadingMore, hasReachedMax=$_hasReachedMax, state=$currentState",
      );
      return;
    }

    if (currentState.currentQuery.isEmpty) {
      log("Load More Error: No current query available in state.");
      return;
    }

    _isLoadingMore = true;

    final nextPage = _currentPage + 1;
    log("Loading page $nextPage for query '${currentState.currentQuery}'");

    final result = await getNews(
      GetNewsParams(query: currentState.currentQuery, page: nextPage),
    );

    result.fold(
      (failure) {
        log("Load More Error: ${failure.message}");

        emit(
          NewsSearchError(
            "Failed to load more: ${failure.message}",
            currentArticles: currentState.articles,
            failedQuery: currentState.currentQuery,
          ),
        );
      },
      (newArticles) {
        _currentPage = nextPage;
        _articles.addAll(newArticles);
        _hasReachedMax = newArticles.length < AppConstants.pageSize;
        emit(
          NewsSearchLoaded(
            articles: List.of(_articles),
            hasReachedMax: _hasReachedMax,
            currentQuery: currentState.currentQuery,
          ),
        );
      },
    );

    _isLoadingMore = false;
  }

}
