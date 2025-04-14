import 'package:dartz/dartz.dart';
import 'package:stack_wealth_news/core/error/failure.dart';
import 'package:stack_wealth_news/core/usecase/usecase.dart';
import 'package:stack_wealth_news/features/news/domain/repositories/news_repository.dart';

class ClearCachedSearchTerms implements UseCase<void, NoParams> {
  final NewsRepository repository;

  ClearCachedSearchTerms({required this.repository});

  @override
  Future<Either<Failure, void>> call(NoParams params) async {
    return await repository.clearCachedSearchTerms();
  }
}