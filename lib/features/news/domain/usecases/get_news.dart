import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:stack_wealth_news/core/error/failure.dart';
import 'package:stack_wealth_news/core/usecase/usecase.dart';
import 'package:stack_wealth_news/features/news/domain/entities/article_entity.dart';

import '../repositories/news_repository.dart';

class GetNews implements UseCase<List<ArticleEntity>, GetNewsParams> {
  final NewsRepository repository;

  GetNews({required this.repository});

  @override
  Future<Either<Failure, List<ArticleEntity>>> call(
    GetNewsParams params,
  ) async {
    if (params.query.trim().isEmpty) {
      return Left(UnexpectedFailure("Search query cannot be empty."));
    }
    if (params.page < 1) {
      return Left(UnexpectedFailure("Page number cannot be less than 1."));
    }
    return await repository.getNews(params.query, params.page);
  }
}

class GetNewsParams extends Equatable {
  final String query;
  final int page;

  const GetNewsParams({required this.query, required this.page});

  @override
  List<Object?> get props => [query, page];
}
