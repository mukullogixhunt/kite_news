import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:stack_wealth_news/core/error/exceptions.dart';
import 'package:stack_wealth_news/core/error/failure.dart';
import 'package:stack_wealth_news/features/news/domain/entities/article_entity.dart';

import '../../domain/repositories/news_repository.dart';
import '../datasources/local/news_local_datasource.dart';
import '../datasources/remote/news_remote_datasource.dart';

/// Implements the [NewsRepository] interface, coordinating data sources and error handling.
class NewsRepositoryImpl implements NewsRepository {
  final NewsRemoteDataSource remoteDataSource;
  final NewsLocalDataSource localDataSource;

  NewsRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  /// Fetches news, mapping data source exceptions to [Failure] types.
  @override
  Future<Either<Failure, List<ArticleEntity>>> getNews(
      String query,
      int page,
      ) async {
    try {
      final List<ArticleEntity> remoteNews = await remoteDataSource.getNews(
        query,
        page,
      );
      return Right(remoteNews);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      log("Repository Unexpected Error getting news: $e");
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  /// Retrieves cached search terms from local storage.
  @override
  Future<Either<Failure, List<String>>> getCachedSearchTerms() async {
    try {
      final terms = await localDataSource.getLastSearchTerms();
      return Right(terms);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      log("Repository Unexpected Error getting cached terms: $e");
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  /// Caches a search term locally.
  @override
  Future<Either<Failure, void>> cacheSearchTerm(String term) async {
    try {
      await localDataSource.cacheSearchTerm(term);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      log("Repository Unexpected Error caching term: $e");
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  /// Clears cached search terms from local storage.
  @override
  Future<Either<Failure, void>> clearCachedSearchTerms() async {
    try {
      await localDataSource.clearCachedSearchTerms();
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      log("Repository Unexpected Error clearing cached terms: $e");
      return Left(UnexpectedFailure(e.toString()));
    }
  }
}