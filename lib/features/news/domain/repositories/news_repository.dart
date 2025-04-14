import 'package:dartz/dartz.dart';
import 'package:stack_wealth_news/core/error/failure.dart';
import 'package:stack_wealth_news/features/news/domain/entities/article_entity.dart';

/// Abstract contract defining the data operations for the news feature.
abstract class NewsRepository {
  Future<Either<Failure, List<ArticleEntity>>> getNews(String query, int page);

  Future<Either<Failure, List<String>>> getCachedSearchTerms();

  Future<Either<Failure, void>> cacheSearchTerm(String term);

  Future<Either<Failure, void>> clearCachedSearchTerms();
}