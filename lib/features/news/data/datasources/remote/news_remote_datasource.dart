import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:stack_wealth_news/core/constants/app_constants.dart';
import 'package:stack_wealth_news/core/error/exceptions.dart';

import '../../models/article_model.dart';

abstract class NewsRemoteDataSource {
  Future<List<ArticleModel>> getNews(String query, int page);
}

class NewsRemoteDataSourceImpl implements NewsRemoteDataSource {
  final http.Client client;

  NewsRemoteDataSourceImpl({required this.client});

  @override
  Future<List<ArticleModel>> getNews(String query, int page) async {
    if (AppConstants.newsApiKey.isEmpty) {
      throw ServerException(
        "API Key is missing. Please check your .env configuration.",
      );
    }

    final encodedQuery = Uri.encodeComponent(query);
    final uri = Uri.parse(
      '${AppConstants.newsApiBaseUrl}/everything?q=$encodedQuery&apiKey=${AppConstants.newsApiKey}&pageSize=${AppConstants.pageSize}&page=$page&sortBy=publishedAt',
    );

    log("Fetching news from: $uri");

    try {
      final response = await client
          .get(uri, headers: {'Content-Type': 'application/json'})
          .timeout(const Duration(seconds: 20));

      log("API Response Status Code: ${response.statusCode}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        if (jsonResponse['status'] == 'ok') {
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
          final errorMessage =
              jsonResponse['message'] ??
              'API returned status: ${jsonResponse['status']}, code: ${jsonResponse['code']}';
          log("API Error Message: $errorMessage");
          throw ServerException(errorMessage);
        }
      } else {
        String errorMessage =
            'Server Error: ${response.statusCode} ${response.reasonPhrase}';
        try {
          final errorBody = json.decode(response.body);
          errorMessage +=
              ' - ${errorBody['message'] ?? 'No specific message.'}';
        } catch (_) {}
        log("HTTP Error: $errorMessage");
        throw ServerException(errorMessage);
      }
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
      rethrow;
    } catch (e) {
      log("Unexpected Error fetching news: $e");
      throw ServerException('Failed to process news data. ${e.toString()}');
    }
  }
}
