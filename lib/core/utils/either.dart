import 'package:equatable/equatable.dart';

/// A class representing a value of one of two possible types.
/// Instances of [Either] are either an instance of [Left] or [Right].
abstract class Either<L, R> extends Equatable {
  const Either();

  /// Returns true if this is a [Right], false otherwise.
  bool isRight();

  /// Returns true if this is a [Left], false otherwise.
  bool isLeft();

  /// If this is a [Right], returns the value, otherwise throws an exception.
  R getRight();

  /// If this is a [Left], returns the value, otherwise throws an exception.
  L getLeft();

  /// If this is a [Right], returns the value, otherwise returns the result of [defaultValue].
  R getOrElse(R Function() defaultValue);

  /// Maps the right value to a new value using the given function.
  Either<L, T> map<T>(T Function(R r) fn);

  /// Maps the left value to a new value using the given function.
  Either<T, R> mapLeft<T>(T Function(L l) fn);

  /// Folds both sides of the Either into a single value.
  T fold<T>(T Function(L l) ifLeft, T Function(R r) ifRight);
}

/// Represents the left side of an [Either] value.
class Left<L, R> extends Either<L, R> {
  final L value;

  const Left(this.value);

  @override
  bool isRight() => false;

  @override
  bool isLeft() => true;

  @override
  R getRight() {
    throw Exception('Cannot get Right value from a Left');
  }

  @override
  L getLeft() => value;

  @override
  R getOrElse(R Function() defaultValue) => defaultValue();

  @override
  Either<L, T> map<T>(T Function(R r) fn) => Left<L, T>(value);

  @override
  Either<T, R> mapLeft<T>(T Function(L l) fn) => Left<T, R>(fn(value));

  @override
  T fold<T>(T Function(L l) ifLeft, T Function(R r) ifRight) => ifLeft(value);

  @override
  List<Object?> get props => [value];
}

/// Represents the right side of an [Either] value.
class Right<L, R> extends Either<L, R> {
  final R value;

  const Right(this.value);

  @override
  bool isRight() => true;

  @override
  bool isLeft() => false;

  @override
  R getRight() => value;

  @override
  L getLeft() {
    throw Exception('Cannot get Left value from a Right');
  }

  @override
  R getOrElse(R Function() defaultValue) => value;

  @override
  Either<L, T> map<T>(T Function(R r) fn) => Right<L, T>(fn(value));

  @override
  Either<T, R> mapLeft<T>(T Function(L l) fn) => Right<T, R>(value);

  @override
  T fold<T>(T Function(L l) ifLeft, T Function(R r) ifRight) => ifRight(value);

  @override
  List<Object?> get props => [value];
}
