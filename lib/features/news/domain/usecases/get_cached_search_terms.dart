import 'package:dartz/dartz.dart';
import 'package:stack_wealth_news/core/error/failure.dart';
import 'package:stack_wealth_news/core/usecase/usecase.dart';

import '../repositories/news_repository.dart';

class GetCachedSearchTerms implements UseCase<List<String>, NoParams> {
  final NewsRepository repository;

  GetCachedSearchTerms({required this.repository});

  @override
  Future<Either<Failure, List<String>>> call(NoParams params) async {
    return await repository.getCachedSearchTerms();
  }
}
