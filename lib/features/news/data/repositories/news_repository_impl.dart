import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:stack_wealth_news/core/error/exceptions.dart';
import 'package:stack_wealth_news/core/error/failure.dart';
import 'package:stack_wealth_news/features/news/domain/entities/article_entity.dart';

import '../../domain/repositories/news_repository.dart';
import '../datasources/local/news_local_datasource.dart';
import '../datasources/remote/news_remote_datasource.dart';

class NewsRepositoryImpl implements NewsRepository {
  final NewsRemoteDataSource remoteDataSource;
  final NewsLocalDataSource localDataSource;

  NewsRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

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
      log("Repository Unexpected Error: $e");
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<String>>> getCachedSearchTerms() async {
    try {
      final terms = await localDataSource.getLastSearchTerms();
      return Right(terms);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      log("Repository Unexpected Error (Cache): $e");
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> cacheSearchTerm(String term) async {
    try {
      await localDataSource.cacheSearchTerm(term);

      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      log("Repository Unexpected Error (Cache): $e");
      return Left(UnexpectedFailure(e.toString()));
    }
  }

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
