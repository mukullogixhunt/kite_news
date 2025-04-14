import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../error/failure.dart';

/// Defines the base abstract class for application use cases and a helper for no parameters.
abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

/// Used when no parameters are needed for a UseCase.
class NoParams extends Equatable {
  @override
  List<Object?> get props => [];
}