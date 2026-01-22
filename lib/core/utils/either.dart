/// A tiny Either implementation to avoid pulling in a dependency.
///
/// Usage:
/// - return Either.left(Failure(...))
/// - return Either.right(value)
sealed class Either<L, R> {
  const Either();

  T fold<T>(T Function(L l) onLeft, T Function(R r) onRight);

  bool get isLeft => this is Left<L, R>;
  bool get isRight => this is Right<L, R>;

  L? get leftOrNull => fold((l) => l, (_) => null);
  R? get rightOrNull => fold((_) => null, (r) => r);

  factory Either.left(L value) => Left<L, R>(value);
  factory Either.right(R value) => Right<L, R>(value);
}

final class Left<L, R> extends Either<L, R> {
  const Left(this.value);
  final L value;

  @override
  T fold<T>(T Function(L l) onLeft, T Function(R r) onRight) => onLeft(value);
}

final class Right<L, R> extends Either<L, R> {
  const Right(this.value);
  final R value;

  @override
  T fold<T>(T Function(L l) onLeft, T Function(R r) onRight) => onRight(value);
}
