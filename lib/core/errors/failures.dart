abstract class Failure {
  final String message;
  const Failure(this.message);

  @override
  String toString() => message;
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Server error']);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'No internet connection.']);
}

class TimeoutFailure extends Failure {
  const TimeoutFailure([super.message = 'Request timed out.']);
}

class ParsingFailure extends Failure {
  const ParsingFailure([super.message = 'Data could not be parsed.']);
}

class UnknownFailure extends Failure {
  const UnknownFailure([super.message = 'Unknown error occurred.']);
}
