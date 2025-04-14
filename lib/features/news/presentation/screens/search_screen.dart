import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import 'package:stack_wealth_news/features/news/presentation/screens/news_detail_screen.dart';

import '../../../../core/constants/text_constants.dart';
import '../../domain/entities/article_entity.dart';
import '../bloc/cached_search/cached_search_bloc.dart';
import '../bloc/news_search/news_search_bloc.dart';
import '../widgets/news_list_item_shimmer.dart';
import '../widgets/news_list_item_widget.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  static const path = '/search';

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  final _focusNode = FocusNode();
  String _lastQuery = '';
  bool _isSearchFocused = false;

  @override
  void initState() {
    super.initState();
    context.read<CachedSearchBloc>().add(LoadCachedTermsEvent());
    _scrollController.addListener(_onScroll);

    _focusNode.addListener(_onFocusChange);

    _isSearchFocused = _focusNode.hasFocus;
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (_isSearchFocused != _focusNode.hasFocus) {
      setState(() {
        _isSearchFocused = _focusNode.hasFocus;
      });

      if (_isSearchFocused) {
        context.read<CachedSearchBloc>().add(LoadCachedTermsEvent());
      }
    }
  }

  void _performSearch(String query) {
    final trimmedQuery = query.trim();
    _lastQuery = trimmedQuery;

    _focusNode.unfocus();

    if (trimmedQuery.isNotEmpty) {
      context.read<NewsSearchBloc>().add(SearchNewsEvent(trimmedQuery));
      context.read<CachedSearchBloc>().add(AddSearchTermEvent(trimmedQuery));
    } else {}
  }

  void _onScroll() {
    if (!_isSearchFocused) {
      if (!_scrollController.hasClients) return;
      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentScroll = _scrollController.offset;
      if (currentScroll >= (maxScroll * 0.9)) {
        final currentState = context.read<NewsSearchBloc>().state;
        if (currentState is NewsSearchLoaded && !currentState.hasReachedMax) {
          context.read<NewsSearchBloc>().add(LoadMoreNewsEvent());
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_ios_new),
        ),
        title: const Text(TextConstants.exploreHeadlines),
        titleSpacing: 6,
      ),

      body: GestureDetector(
        onTap: () {
          if (_focusNode.hasFocus) {
            _focusNode.unfocus();
          }
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                autofocus: true,
                controller: _searchController,
                focusNode: _focusNode,

                decoration: InputDecoration(
                  hintText: 'Search articles...',
                  prefixIcon: const Icon(CupertinoIcons.search, size: 20),
                  suffixIcon:
                      _searchController.text.isNotEmpty
                          ? IconButton(
                            icon: const Icon(Icons.clear, size: 20),
                            onPressed: () {
                              _searchController.clear();

                              _focusNode.requestFocus();

                              setState(() {});
                            },
                          )
                          : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: BorderSide(
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 10.0),
                ),
                textInputAction: TextInputAction.search,
                onChanged: (value) {
                  setState(() {});
                },

                onSubmitted: _performSearch,
              ),
            ),

            Expanded(
              child:
                  _isSearchFocused
                      ? _buildRecentSearches(context)
                      : _buildBlocResults(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBlocResults(BuildContext context) {
    return BlocConsumer<NewsSearchBloc, NewsSearchState>(
      listener: (context, state) {
        if (state is NewsSearchError &&
            (state.currentArticles.isNotEmpty ?? false)) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Couldn't load more: ${state.message}"),
              backgroundColor: Colors.orangeAccent,
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is NewsSearchLoading && state.isFirstFetch) {
          return _buildLoadingShimmer();
        }

        if (state is NewsSearchError &&
            (state.currentArticles.isEmpty ?? true)) {
          return _buildErrorWidget(context, state.message, () {
            _performSearch(state.failedQuery ?? _lastQuery);
          });
        }

        List<ArticleEntity> articlesToShow = [];
        bool isLoadingMore = false;
        bool isLoadMoreError = false;
        String queryForDisplay = _lastQuery;

        if (state is NewsSearchLoaded) {
          articlesToShow = state.articles;
          queryForDisplay = state.currentQuery;
          isLoadingMore = false;
          isLoadMoreError = false;

          if (articlesToShow.isEmpty) {
            return _buildEmptyResultsWidget(queryForDisplay);
          }
        } else if (state is NewsSearchLoading && !state.isFirstFetch) {
          articlesToShow = state.oldArticles;
          queryForDisplay = state.query ?? _lastQuery;
          isLoadingMore = true;
          isLoadMoreError = false;
        } else if (state is NewsSearchError &&
            (state.currentArticles.isNotEmpty ?? false)) {
          articlesToShow = state.currentArticles;
          queryForDisplay = state.failedQuery ?? _lastQuery;
          isLoadingMore = false;
          isLoadMoreError = true;
        } else if (state is NewsSearchInitial) {
          return const Center(child: Text("Perform a search to see results."));
        } else {
          return const Center(child: Text("An unexpected error occurred."));
        }

        if (articlesToShow.isNotEmpty || isLoadingMore || isLoadMoreError) {
          return _buildSearchResultsList(
            context,
            articlesToShow,
            isLoadingMore,
            isLoadMoreError,
          );
        } else {
          return _buildEmptyResultsWidget(queryForDisplay);
        }
      },
    );
  }

  Widget _buildRecentSearches(BuildContext context) {
    return BlocBuilder<CachedSearchBloc, CachedSearchState>(
      builder: (context, cacheState) {
        if (cacheState is CachedSearchLoading) {
          return const Center(child: CircularProgressIndicator(strokeWidth: 2));
        } else if (cacheState is CachedSearchLoaded) {
          final terms = cacheState.terms;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Recent Searches',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.grey[800],
                      ),
                    ),
                    if (terms.isNotEmpty)
                      TextButton(
                        onPressed:
                            () => context.read<CachedSearchBloc>().add(
                              ClearCachedTermsEvent(),
                            ),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(50, 30),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          alignment: Alignment.centerRight,
                        ),
                        child: const Text(
                          "Clear All",
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                  ],
                ),
              ),
              if (terms.isEmpty)
                const Expanded(
                  child: Center(
                    child: Text(
                      'No recent searches.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                )
              else
                Expanded(
                  child: ListView.builder(
                    itemCount: terms.length,
                    itemBuilder: (context, index) {
                      final term = terms[index];
                      return ListTile(
                        leading: const Icon(Icons.history, color: Colors.grey),
                        title: Text(term),
                        onTap: () {
                          _searchController.text = term;
                          _searchController
                              .selection = TextSelection.fromPosition(
                            TextPosition(offset: _searchController.text.length),
                          );

                          _performSearch(term);
                        },
                        dense: true,
                      );
                    },
                  ),
                ),
            ],
          );
        } else if (cacheState is CachedSearchError) {
          return Center(
            child: Text('Error loading recent searches: ${cacheState.message}'),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildLoadingShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.builder(
        itemCount: 8,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) => const NewsListItemShimmer(),
      ),
    );
  }

  Widget _buildSearchResultsList(
    BuildContext context,
    List<ArticleEntity> articles,
    bool isLoadingMore,
    bool isLoadMoreError,
  ) {
    return ListView.separated(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: articles.length + (isLoadingMore || isLoadMoreError ? 1 : 0),
      separatorBuilder:
          (context, index) =>
              const Divider(height: 1, indent: 16, endIndent: 16),
      itemBuilder: (context, index) {
        if (index >= articles.length) {
          if (isLoadingMore) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(strokeWidth: 3),
              ),
            );
          }
          if (isLoadMoreError) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Icon(
                  Icons.error_outline,
                  color: Colors.orangeAccent,
                  size: 24,
                ),
              ),
            );
          }
          return const SizedBox.shrink();
        }
        final article = articles[index];
        return NewsListItemWidget(
          article: article,
          itemIndex: index,
          onTap: () => context.push(NewsDetailScreen.path, extra: article),
        );
      },
    );
  }

  Widget _buildErrorWidget(
    BuildContext context,
    String message,
    VoidCallback onRetry,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.redAccent, size: 40),
            const SizedBox(height: 10),
            Text(
              'Error fetching results:\n$message',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.red[700]),
            ),
            const SizedBox(height: 15),
            ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyResultsWidget(String query) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, color: Colors.grey[400], size: 50),
            const SizedBox(height: 10),
            Text('No results found for "$query".', textAlign: TextAlign.center),
            const SizedBox(height: 10),
            Text(
              'Try searching for something else.',
              style: TextStyle(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
