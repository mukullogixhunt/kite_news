import 'dart:developer';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:stack_wealth_news/core/constants/app_constants.dart';
import 'package:stack_wealth_news/core/error/exceptions.dart';

abstract class NewsLocalDataSource {
  Future<List<String>> getLastSearchTerms();

  Future<void> cacheSearchTerm(String term);

  Future<void> clearCachedSearchTerms();
}

class NewsLocalDataSourceImpl implements NewsLocalDataSource {
  final SharedPreferences sharedPreferences;

  NewsLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<List<String>> getLastSearchTerms() async {
    final jsonStringList = sharedPreferences.getStringList(
      AppConstants.cachedSearchTermsKey,
    );
    if (jsonStringList != null) {
      return Future.value(jsonStringList);
    } else {
      return Future.value([]);
    }
  }

  @override
  Future<void> cacheSearchTerm(String term) async {
    final trimmedTerm = term.trim();
    if (trimmedTerm.isEmpty) return;

    try {
      final currentTerms = await getLastSearchTerms();

      currentTerms.removeWhere(
        (t) => t.toLowerCase() == trimmedTerm.toLowerCase(),
      );

      currentTerms.insert(0, trimmedTerm);

      final termsToCache =
          currentTerms.take(AppConstants.maxCachedSearches).toList();

      await sharedPreferences.setStringList(
        AppConstants.cachedSearchTermsKey,
        termsToCache,
      );
    } catch (e) {
      log("SharedPreferences Error: $e");
      throw CacheException("Could not cache search term: ${e.toString()}");
    }
  }

  @override
  Future<void> clearCachedSearchTerms() async {
    try {
      final success = await sharedPreferences.remove(
        AppConstants.cachedSearchTermsKey,
      );
      if (!success) {
        log(
          "SharedPreferences remove operation returned false for key: ${AppConstants.cachedSearchTermsKey}",
        );
      }
      log("Cleared cached search terms.");
    } catch (e) {
      log("SharedPreferences Error clearing terms: $e");
      throw CacheException("Could not clear search terms: ${e.toString()}");
    }
  }
}
