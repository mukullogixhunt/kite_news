import 'dart:developer';

import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Holds constant values used throughout the application.
class AppConstants {
  static final String newsApiKey = dotenv.env['NEWS_API_KEY'] ?? '';
  static const String newsApiBaseUrl = 'https://newsapi.org/v2';
  static const int pageSize = 10;
  static const int maxCachedSearches = 5;
  static const String cachedSearchTermsKey = 'CACHED_SEARCH_TERMS';

  static void validateApiKey() {
    if (newsApiKey.isEmpty) {
      log("*****************************************************");
      log("ERROR: NEWS_API_KEY not found in .env file!");
      log("Please ensure you have a .env file in the project root");
      log("with NEWS_API_KEY=YOUR_ACTUAL_API_KEY");
      log("*****************************************************");
    }
  }
}