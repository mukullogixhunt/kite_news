part of 'news_search_bloc.dart';

sealed class NewsSearchState extends Equatable {
  const NewsSearchState();

  @override
  List<Object?> get props => [];
}

class NewsSearchInitial extends NewsSearchState {}

class NewsSearchLoading extends NewsSearchState {
  final bool isFirstFetch;
  final List<ArticleEntity> oldArticles;
  final String query;

  const NewsSearchLoading({
    this.isFirstFetch = true,
    this.oldArticles = const [],
    required this.query,
  });

  @override
  List<Object?> get props => [isFirstFetch, oldArticles, query];
}

class NewsSearchLoaded extends NewsSearchState {
  final List<ArticleEntity> articles;
  final bool hasReachedMax;
  final String currentQuery;

  const NewsSearchLoaded({
    required this.articles,
    required this.hasReachedMax,
    required this.currentQuery,
  });

  @override
  List<Object?> get props => [articles, hasReachedMax, currentQuery];

  NewsSearchLoaded copyWith({
    List<ArticleEntity>? articles,
    bool? hasReachedMax,
    String? currentQuery,
  }) {
    return NewsSearchLoaded(
      articles: articles ?? this.articles,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      currentQuery: currentQuery ?? this.currentQuery,
    );
  }
}

class NewsSearchError extends NewsSearchState {
  final String message;
  final List<ArticleEntity> currentArticles;
  final String failedQuery;

  const NewsSearchError(
    this.message, {
    this.currentArticles = const [],
    required this.failedQuery,
  });

  @override
  List<Object?> get props => [message, currentArticles, failedQuery];
}
