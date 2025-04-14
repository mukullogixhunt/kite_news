import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:stack_wealth_news/core/error/failure.dart';
import 'package:stack_wealth_news/core/usecase/usecase.dart';

import '../repositories/news_repository.dart';

class CacheSearchTerm implements UseCase<void, CacheSearchTermParams> {
  final NewsRepository repository;

  CacheSearchTerm({required this.repository});

  @override
  Future<Either<Failure, void>> call(CacheSearchTermParams params) async {
    return await repository.cacheSearchTerm(params.term);
  }
}

class CacheSearchTermParams extends Equatable {
  final String term;

  const CacheSearchTermParams({required this.term});

  @override
  List<Object?> get props => [term];
}
