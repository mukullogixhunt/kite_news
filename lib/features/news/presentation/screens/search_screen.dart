import 'dart:async';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import 'package:stack_wealth_news/features/news/presentation/screens/news_detail_screen.dart';

// Core App Imports
import '../../../../core/constants/text_constants.dart';
// *** Use your actual dependency injection file import ***
import '../../../../injection_container.dart'; // Or service_locator.dart

// Domain Layer Imports
import '../../domain/entities/article_entity.dart';
import '../../domain/usecases/get_news.dart';

// Presentation Layer Imports (Blocs, Events, States)
// *** Using the Blocs YOU provided ***
import '../bloc/cached_search/cached_search_bloc.dart';
import '../bloc/news_search/news_search_bloc.dart';

// Presentation Layer Imports (Widgets)
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
  String _lastQuery = ''; // Store the last search query for retries

  @override
  void initState() {
    super.initState();
    // Load recent searches
    context.read<CachedSearchBloc>().add(LoadCachedTermsEvent());
    // Add listener for infinite scrolling
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  /// Performs the search
  void _performSearch(String query) {
    final trimmedQuery = query.trim();
    _lastQuery = trimmedQuery;
    FocusScope.of(context).unfocus(); // Unfocus keyboard

    if (trimmedQuery.isNotEmpty) {
      log('>>> UI: Performing search for: $trimmedQuery');
      // Dispatch Search event to NewsSearchBloc
      context.read<NewsSearchBloc>().add(SearchNewsEvent(trimmedQuery));
      // Dispatch cache event to CachedSearchBloc
      context.read<CachedSearchBloc>().add(AddSearchTermEvent(trimmedQuery));
    }
    // NOTE: No else block to dispatch ClearSearchEvent here,
    // as the provided Bloc doesn't handle it.
    // Clearing happens via the clear button only.
  }

  /// Listener for the scroll controller for pagination
  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    if (currentScroll >= (maxScroll * 0.9)) { // Threshold
      final currentState = context.read<NewsSearchBloc>().state;
      // Only dispatch LoadMore if currently in Loaded state and not maxed out
      if (currentState is NewsSearchLoaded && !currentState.hasReachedMax) {
        log('>>> UI: Reached bottom, dispatching LoadMoreNewsEvent');
        context.read<NewsSearchBloc>().add(LoadMoreNewsEvent());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Provide the screen-specific NewsSearchBloc instance
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_ios_new),
        ),
        title: const Text(TextConstants.exploreHeadlines),
        titleSpacing: 6,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Search Input Field ---
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Search articles...',
                prefixIcon: const Icon(CupertinoIcons.search, size: 20),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear, size: 20),
                  onPressed: () {
                    _searchController.clear();
                    // !!! IMPORTANT !!!
                    // The NewsSearchBloc YOU provided does NOT handle ClearSearchEvent.
                    // Dispatching it WILL cause an error.
                    // Commenting this out to prevent the crash.
                    // If you want this button to clear results, you MUST add
                    // the ClearSearchEvent and its handler to NewsSearchBloc.
                    // blocContext.read<NewsSearchBloc>().add(ClearSearchEvent());
                    log(">>> UI: Clear button pressed, but ClearSearchEvent dispatch is COMMENTED OUT because the provided Bloc does not handle it.");
                    // We can manually trigger a rebuild to clear the suffix icon,
                    // but the Bloc state won't reset without handling the event.
                    setState(() {});
                  },
                )
                    : null,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(30.0), borderSide: BorderSide(color: Colors.grey.shade300)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30.0), borderSide: BorderSide(color: Colors.grey.shade300)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30.0), borderSide: BorderSide(color: Theme.of(context).primaryColor)),
                contentPadding: const EdgeInsets.symmetric(vertical: 10.0),
              ),
              textInputAction: TextInputAction.search,
              onChanged: (value) {
                // Update clear button visibility
                setState(() {});
              },
              onSubmitted: _performSearch,
            ),
          ),



          // _buildRecentSearches(context),

          // --- Body Content ---
          Expanded(
            // Use BlocConsumer for NewsSearchBloc
            child: BlocConsumer<NewsSearchBloc, NewsSearchState>(
              // Listener for pagination error snackbar
              listener: (context, state) {
                // Note: Your NewsSearchError state needs 'currentArticles' for this check
                // Assuming it exists based on previous versions. Adjust if not.
                if (state is NewsSearchError && (state.currentArticles?.isNotEmpty ?? false)) {
                  log(">>> UI LISTENER: Load More Error: ${state.message}");
                  ScaffoldMessenger.of(context).showSnackBar( SnackBar( content: Text("Couldn't load more: ${state.message}"), backgroundColor: Colors.orangeAccent ) );
                }
              },
              builder: (context, state) {
                log(">>> UI BUILDER: Received State -> ${state.runtimeType}");

                // 1. Handle Initial State -> Show Recent Searches
                if (state is NewsSearchInitial) {
                  log(">>> UI BUILDER: State is Initial. Building Recent Searches.");
                  // return _buildRecentSearches(context);
                }

                // 2. Handle Loading (First Fetch) -> Show Shimmer
                // Use the 'isFirstFetch' flag from the state
                if (state is NewsSearchLoading && state.isFirstFetch) {
                  log(">>> UI BUILDER: State is Loading (First Fetch). Building Shimmer.");
                  return _buildLoadingShimmer();
                }

                // 3. Handle Error (First Fetch) -> Show Error Widget
                // Check for error state where there are no previous articles
                // Assuming NewsSearchError has 'currentArticles' field that can be empty/null
                if (state is NewsSearchError && (state.currentArticles?.isEmpty ?? true)) {
                  log(">>> UI BUILDER: State is Error (First Fetch). Building Error Widget.");
                  return _buildErrorWidget(context, state.message, () {
                    _performSearch(state.failedQuery ?? _lastQuery);
                  });
                }

                // --- At this point, we expect states that might display a list ---
                // These are: NewsSearchLoaded, NewsSearchLoading (not first fetch), NewsSearchError (with articles)

                // Extract articles and flags safely, defaulting if state doesn't match expected types
                List<ArticleEntity> articlesToShow = [];
                bool isLoadingMore = false;
                bool isLoadMoreError = false;
                bool isEmptyResult = false;
                String queryForEmpty = _lastQuery;

                if (state is NewsSearchLoaded) {
                  articlesToShow = state.articles;
                  isLoadingMore = false;
                  isLoadMoreError = false;
                  queryForEmpty = state.currentQuery;
                  isEmptyResult = articlesToShow.isEmpty;
                  log(">>> UI BUILDER: Handling Loaded. Articles: ${articlesToShow.length}. Query: '$queryForEmpty'. MaxReached: ${state.hasReachedMax}");
                } else if (state is NewsSearchLoading && !state.isFirstFetch) {
                  // CRITICAL: Your loading state MUST provide the old articles to show
                  articlesToShow = state.oldArticles; // <--- CHECK THIS FIELD NAME IN YOUR STATE
                  isLoadingMore = true;
                  isLoadMoreError = false;
                  queryForEmpty = state.query ?? _lastQuery;
                  log(">>> UI BUILDER: Handling Loading More. Old Articles: ${articlesToShow.length}. Query: '$queryForEmpty'.");
                } else if (state is NewsSearchError && (state.currentArticles?.isNotEmpty ?? false)) {
                  // CRITICAL: Your error state MUST provide current articles for this case
                  articlesToShow = state.currentArticles!; // <--- CHECK THIS FIELD NAME IN YOUR STATE
                  isLoadingMore = false;
                  isLoadMoreError = true;
                  queryForEmpty = state.failedQuery ?? _lastQuery;
                  log(">>> UI BUILDER: Handling Load More Error. Current Articles: ${articlesToShow.length}. Query: '$queryForEmpty'.");
                } else {
                  // If none of the above, something is unexpected. Log and maybe show initial.
                  log(">>> UI BUILDER: Reached unexpected state for list display: ${state.runtimeType}");
                  // Fallback to prevent crashing, might show recent searches briefly
                  // return _buildRecentSearches(context);
                }

                // --- Render based on extracted data ---
                if (isEmptyResult) {
                  log(">>> UI BUILDER: Rendering Empty Widget for query '$queryForEmpty'.");
                  return _buildEmptyResultsWidget(queryForEmpty);
                } else {
                  log(">>> UI BUILDER: Rendering Results List. Articles: ${articlesToShow.length}, LoadingMore: $isLoadingMore, ErrorMore: $isLoadMoreError");
                  return _buildSearchResultsList(
                    context,
                    articlesToShow,
                    isLoadingMore,
                    isLoadMoreError,
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  // --- Helper Widgets ---

  Widget _buildRecentSearches(BuildContext context) {
    log(">>> _buildRecentSearches called");
    return BlocBuilder<CachedSearchBloc, CachedSearchState>(
      builder: (context, cacheState) {
        if (cacheState is CachedSearchLoading) { return const Center(child: CircularProgressIndicator(strokeWidth: 2)); }
        else if (cacheState is CachedSearchLoaded) {
          final terms = cacheState.terms;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Recent Searches', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.grey[800])),
                    if (terms.isNotEmpty)
                      TextButton(
                        onPressed: () => context.read<CachedSearchBloc>().add(ClearCachedTermsEvent()),
                        style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(50, 30), tapTargetSize: MaterialTapTargetSize.shrinkWrap, alignment: Alignment.centerRight),
                        child: const Text("Clear All", style: TextStyle(fontSize: 12)),
                      )
                  ],
                ),
              ),
              if (terms.isEmpty)
                const Expanded(child: Center(child: Text('No recent searches.', style: TextStyle(color: Colors.grey))))
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
                          _searchController.selection = TextSelection.fromPosition(TextPosition(offset: _searchController.text.length));
                          _performSearch(term);
                        },
                        dense: true,
                      );
                    },
                  ),
                ),
            ],
          );
        }
        else if (cacheState is CachedSearchError) { return Center(child: Text('Error loading recent searches: ${cacheState.message}'));}
        return const SizedBox.shrink(); // Initial
      },
    );
  }

  Widget _buildLoadingShimmer() {
    log(">>> _buildLoadingShimmer called");
    return Shimmer.fromColors(baseColor: Colors.grey[300]!, highlightColor: Colors.grey[100]!, child: ListView.builder(itemCount: 8, physics: const NeverScrollableScrollPhysics(), itemBuilder: (context, index) => const NewsListItemShimmer()));
  }

  Widget _buildSearchResultsList(
      BuildContext context,
      List<ArticleEntity> articles,
      bool isLoadingMore,
      bool isLoadMoreError,
      ) {
    log(">>> _buildSearchResultsList: Rendering List. Items: ${articles.length}. LoadingMore: $isLoadingMore, ErrorMore: $isLoadMoreError");
    // Safeguard: If called with empty list and no flags, don't build empty ListView
    if (articles.isEmpty && !isLoadingMore && !isLoadMoreError) {
      log(">>> _buildSearchResultsList: Safeguard hit - articles empty, not loading/error. Returning Empty Box.");
      return const SizedBox.shrink();
    }
    return ListView.separated(
      controller: _scrollController, // Attach controller
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: articles.length + (isLoadingMore || isLoadMoreError ? 1 : 0),
      separatorBuilder: (context, index) => const Divider(height: 1, indent: 16, endIndent: 16),
      itemBuilder: (context, index) {
        if (index >= articles.length) { // Build indicator item
          if (isLoadingMore) return const Center(child: Padding(padding: EdgeInsets.all(16.0), child: CircularProgressIndicator(strokeWidth: 3)));
          if (isLoadMoreError) return const Center(child: Padding(padding: EdgeInsets.all(16.0), child: Icon(Icons.error_outline, color: Colors.orangeAccent, size: 24)));
          return const SizedBox.shrink();
        }
        // Build article item
        final article = articles[index];
        return NewsListItemWidget(
          article: article,
          itemIndex: index,
          onTap: () => context.push(NewsDetailScreen.path, extra: article),
        );
      },
    );
  }

  Widget _buildErrorWidget(BuildContext context, String message, VoidCallback onRetry) {
    log(">>> _buildErrorWidget called");
    return Center( child: Padding( padding: const EdgeInsets.all(20.0), child: Column( mainAxisAlignment: MainAxisAlignment.center, children: [ const Icon(Icons.error_outline, color: Colors.redAccent, size: 40), const SizedBox(height: 10), Text('Error fetching results:\n$message', textAlign: TextAlign.center, style: TextStyle(color: Colors.red[700])), const SizedBox(height: 15), ElevatedButton(onPressed: onRetry, child: const Text('Retry')) ])));
  }

  Widget _buildEmptyResultsWidget(String query) {
    log(">>> _buildEmptyResultsWidget called for query '$query'");
    return Center( child: Padding( padding: const EdgeInsets.all(20.0), child: Column( mainAxisAlignment: MainAxisAlignment.center, children: [ Icon(Icons.search_off, color: Colors.grey[400], size: 50), const SizedBox(height: 10), Text('No results found for "$query".', textAlign: TextAlign.center), const SizedBox(height: 10), Text('Try searching for something else.', style: TextStyle(color: Colors.grey[600]), textAlign: TextAlign.center) ])));
  }
}