import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import 'package:stack_wealth_news/features/news/domain/entities/article_entity.dart';
import 'package:stack_wealth_news/features/news/presentation/bloc/news_search/news_search_bloc.dart';
import 'package:stack_wealth_news/features/news/presentation/screens/news_detail_screen.dart';
import 'package:stack_wealth_news/features/news/presentation/widgets/news_list_item_shimmer.dart';
import '../widgets/news_list_item_widget.dart';

class CategoryNewsList extends StatefulWidget {
  final String category;
  final ScrollController scrollController;

  const CategoryNewsList({
    super.key,
    required this.category,
    required this.scrollController,
  });

  @override
  State<CategoryNewsList> createState() => _CategoryNewsListState();
}

class _CategoryNewsListState extends State<CategoryNewsList>
    with AutomaticKeepAliveClientMixin {
  @override
  void initState() {
    super.initState();
    widget.scrollController.addListener(_onScroll);

    final bloc = context.read<NewsSearchBloc>();
    if (bloc.state is NewsSearchInitial) {
      bloc.add(SearchNewsEvent(widget.category));
    }
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_onScroll);
    super.dispose();
  }

  /// Checks if the user has scrolled to the bottom of the list
  void _onScroll() {
    if (_isBottom) {
      context.read<NewsSearchBloc>().add(LoadMoreNewsEvent());
    }
  }

  bool get _isBottom {
    if (!widget.scrollController.hasClients) return false;
    final maxScroll = widget.scrollController.position.maxScrollExtent;
    final currentScroll = widget.scrollController.offset;
    return currentScroll >= (maxScroll * 0.95);
  }

  /// Handles pull-to-refresh action
  Future<void> _handleRefresh() async {
    context.read<NewsSearchBloc>().add(SearchNewsEvent(widget.category));
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return BlocConsumer<NewsSearchBloc, NewsSearchState>(
      listener: (context, state) {
        if (state is NewsSearchError && state.currentArticles.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "[${widget.category}] Couldn't load more: ${state.message}",
              ),
              backgroundColor: Colors.orangeAccent,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      },
      builder: (context, state) {
        // Loading state
        if (state is NewsSearchInitial || (state is NewsSearchLoading && state.isFirstFetch)) {
          return _buildLoadingShimmer(context);
        }

        // Error state with no articles
        if (state is NewsSearchError && state.currentArticles.isEmpty) {
          return _buildErrorWidget(context, state.message);
        }

        List<ArticleEntity> articles = [];
        bool hasReachedMax = false;
        bool isLoadingMore = false;
        bool isLoadMoreError = false;

        if (state is NewsSearchLoaded) {
          articles = state.articles;
          hasReachedMax = state.hasReachedMax;
        } else if (state is NewsSearchLoading && !state.isFirstFetch) {
          articles = state.oldArticles;
          hasReachedMax = false;
          isLoadingMore = true;
        } else if (state is NewsSearchError && state.currentArticles.isNotEmpty) {
          articles = state.currentArticles;
          hasReachedMax = true;
          isLoadMoreError = true;
        }

        // If no articles and it's not loading more, show empty widget
        if (articles.isEmpty && !isLoadingMore && state is NewsSearchLoaded) {
          return _buildEmptyListWidget(context, widget.category);
        }

        return RefreshIndicator(
          onRefresh: _handleRefresh,
          child: ListView.separated(
            controller: widget.scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: articles.length + (isLoadingMore ? 1 : 0),
            separatorBuilder: (context, index) {
              if (index < articles.length - 1) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  child: const Divider(thickness: 1.5, height: 1.5),
                );
              } else {
                return const SizedBox.shrink();
              }
            },
            itemBuilder: (context, index) {
              // Loading more item
              if (index >= articles.length) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    child: CircularProgressIndicator(strokeWidth: 3.0),
                  ),
                );
              }

              final article = articles[index];
              return NewsListItemWidget(
                article: article,
                itemIndex: index,
                onTap: () {
                  context.push(NewsDetailScreen.path, extra: article);
                },
              );
            },
          ),
        );
      },
    );
  }

  // Displays shimmer effect for loading
  Widget _buildLoadingShimmer(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.separated(
        itemCount: 8,
        physics: const NeverScrollableScrollPhysics(),
        separatorBuilder: (context, index) => Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: const Divider(thickness: 1.5, height: 1.5),
        ),
        itemBuilder: (context, index) {
          return const NewsListItemShimmer();
        },
      ),
    );
  }

  // Displays an error widget when fetching news fails
  Widget _buildErrorWidget(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.redAccent, size: 40),
            const SizedBox(height: 10),
            Text(
              'Error fetching news for ${widget.category}:\n$message',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.red[700]),
            ),
            const SizedBox(height: 15),
            ElevatedButton(
              onPressed: _handleRefresh,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  // Displays a message when no articles are found
  Widget _buildEmptyListWidget(BuildContext context, String query) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.article_outlined, color: Colors.grey[400], size: 50),
            const SizedBox(height: 10),
            Text(
              'No articles found for "$query".',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 15),
            ElevatedButton(
              onPressed: _handleRefresh,
              child: const Text('Check Again'),
            ),
          ],
        ),
      ),
    );
  }
}
