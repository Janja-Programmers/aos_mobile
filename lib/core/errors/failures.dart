abstract class Failure {
  final String message;
  const Failure(this.message);

  @override
  String toString() => message;
}

class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

class NetworkFailure extends Failure {
  const NetworkFailure() : super('No internet connection.');
}

class TimeoutFailure extends Failure {
  const TimeoutFailure() : super('Request timed out.');
}

class ParsingFailure extends Failure {
  const ParsingFailure() : super('Data could not be parsed.');
}

class UnknownFailure extends Failure {
  const UnknownFailure() : super('Unknown error occurred.');
}
