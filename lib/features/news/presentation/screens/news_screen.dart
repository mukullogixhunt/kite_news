import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:stack_wealth_news/core/constants/media_constants.dart';
import 'package:stack_wealth_news/core/constants/text_constants.dart';


import 'package:stack_wealth_news/features/news/domain/usecases/get_news.dart';
import 'package:stack_wealth_news/features/news/presentation/bloc/news_search/news_search_bloc.dart';
import 'package:stack_wealth_news/features/news/presentation/screens/search_screen.dart';

import '../../../../injection_container.dart';
import '../widgets/category_news_list.dart';

class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key});

  static const path = '/news';

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen>
    with SingleTickerProviderStateMixin {
  final List<String> _categories = const [
    'General',
    'Technology',
    'Sports',
    'Health',
    'Business',
    'Entertainment',
  ];

  late final TabController _tabController;
  late final Map<String, NewsSearchBloc> _categoryBlocs;
  late final Map<String, ScrollController> _scrollControllers;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _categories.length, vsync: this);


    _categoryBlocs = {
      for (var category in _categories)
        category: NewsSearchBloc(getNews: sl<GetNews>()),
    };
    _scrollControllers = {
      for (var category in _categories) category: ScrollController(),
    };

    _tabController.addListener(_handleTabSelection);

    final initialCategory = _categories.first;
    _categoryBlocs[initialCategory]?.add(SearchNewsEvent(initialCategory));

    log(
      'NewsScreen initState: Created ${_categories.length} Blocs and Controllers.',
    );
  }

  void _handleTabSelection() {
    if (!_tabController.indexIsChanging && !_tabController.index.isNaN) {
      final selectedCategory = _categories[_tabController.index];
      final bloc = _categoryBlocs[selectedCategory];

      if (bloc != null && bloc.state is NewsSearchInitial) {
        log("Tab selected ($selectedCategory): Triggering initial fetch.");
        bloc.add(SearchNewsEvent(selectedCategory));
      } else {
        log("Tab selected ($selectedCategory): State already exists.");
      }
    }
  }

  @override
  void dispose() {
    log('NewsScreen dispose: Closing Blocs and disposing Controllers.');
    _tabController.dispose();
    _tabController.removeListener(_handleTabSelection);
    for (var controller in _scrollControllers.values) {
      controller.dispose();
    }
    for (var bloc in _categoryBlocs.values) {
      bloc.close();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(MediaConstants.appLogo, height: 30, width: 30),
            const SizedBox(width: 8),
            const Text(TextConstants.appName),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              context.push(SearchScreen.path);
            },
            icon: const Icon(CupertinoIcons.search),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          tabs: _categories.map((category) => Tab(text: category)).toList(),
        ),
      ),

      body: TabBarView(
        controller: _tabController,
        children:
            _categories.map((category) {
              return BlocProvider.value(
                value: _categoryBlocs[category]!,
                child: CategoryNewsList(
                  key: PageStorageKey(category),
                  category: category,
                  scrollController: _scrollControllers[category]!,
                ),
              );
            }).toList(),
      ),
    );
  }
}


