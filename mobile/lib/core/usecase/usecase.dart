import 'package:dartz/dartz.dart';
import 'package:mobile/core/errors/failures.dart';

/// [UseCase] interface for use cases that require parameters.
abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

/// [NoParams] class to be used when a use case doesn't require any parameters.
class NoParams {}
