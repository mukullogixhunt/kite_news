import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:stack_wealth_news/core/constants/app_constants.dart';
import 'package:stack_wealth_news/core/error/exceptions.dart';

import '../../models/article_model.dart'; // For ArticleModel

/// Defines the contract for fetching news data from a remote source (API).
abstract class NewsRemoteDataSource {
  /// Fetches news articles based on a query and page number.
  Future<List<ArticleModel>> getNews(String query, int page);
}

/// Implements the [NewsRemoteDataSource] using the NewsAPI and http client.
class NewsRemoteDataSourceImpl implements NewsRemoteDataSource {
  final http.Client client;

  NewsRemoteDataSourceImpl({required this.client});

  @override
  Future<List<ArticleModel>> getNews(String query, int page) async {
    // Check if API key is configured before proceeding.
    if (AppConstants.newsApiKey.isEmpty) {
      throw ServerException(
        "API Key is missing. Please check your .env configuration.",
      );
    }

    // Construct the NewsAPI request URL.
    final encodedQuery = Uri.encodeComponent(query);
    final uri = Uri.parse(
      '${AppConstants.newsApiBaseUrl}/everything?q=$encodedQuery&apiKey=${AppConstants.newsApiKey}&pageSize=${AppConstants.pageSize}&page=$page&sortBy=publishedAt',
    );

    log("Fetching news from: $uri");

    try {
      // Make the HTTP GET request with a timeout.
      final response = await client
          .get(uri, headers: {'Content-Type': 'application/json'})
          .timeout(const Duration(seconds: 20));

      log("API Response Status Code: ${response.statusCode}");

      // Handle successful response (HTTP 200).
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        // Check the 'status' field within the API response.
        if (jsonResponse['status'] == 'ok') {
          // Parse the articles, filter out invalid ones, and return the list.
          final articles =
              (jsonResponse['articles'] as List)
                  .map(
                    (articleJson) => ArticleModel.fromJson(
                      articleJson as Map<String, dynamic>,
                    ),
                  )
                  .where(
                    (article) =>
                        article.title.isNotEmpty && article.url.isNotEmpty,
                  )
                  .toList();
          return articles;
        } else {
          // Throw ServerException if API status is not 'ok'.
          final errorMessage =
              jsonResponse['message'] ??
              'API returned status: ${jsonResponse['status']}, code: ${jsonResponse['code']}';
          log("API Error Message: $errorMessage");
          throw ServerException(errorMessage);
        }
      } else {
        // Throw ServerException for non-200 HTTP status codes.
        String errorMessage =
            'Server Error: ${response.statusCode} ${response.reasonPhrase}';
        try {
          // Attempt to include message from error body if possible.
          final errorBody = json.decode(response.body);
          errorMessage +=
              ' - ${errorBody['message'] ?? 'No specific message.'}';
        } catch (_) {}
        log("HTTP Error: $errorMessage");
        throw ServerException(errorMessage);
      }
      // Handle specific network and timeout errors.
    } on TimeoutException catch (_) {
      log("Network Error: Request timed out.");
      throw NetworkException('The request timed out. Please try again.');
    } on SocketException catch (e) {
      log("Network Error: SocketException - ${e.message}");
      throw NetworkException(
        'Network error: Could not reach the server. Please check your connection.',
      );
    } on http.ClientException catch (e) {
      log("Network Error: ClientException - ${e.message}");
      throw NetworkException('Network Error: ${e.message}');
    } on ServerException {
      rethrow; // Re-throw known server exceptions.
    } catch (e) {
      // Catch any other unexpected errors.
      log("Unexpected Error fetching news: $e");
      throw ServerException('Failed to process news data. ${e.toString()}');
    }
  }
}
