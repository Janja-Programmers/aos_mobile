/// Represents an error returned by the API layer.
///
/// Keep it simple: a user-friendly message + optional status code.
class Failure {
  const Failure(this.message, {this.statusCode, this.type});

  final String message;
  final int? statusCode;
  final FailureType? type;

  @override
  String toString() => 'Failure(message: $message, statusCode: $statusCode, type: $type)';
}

enum FailureType {
  network,
  timeout,
  unauthorized,
  forbidden,
  notFound,
  rateLimited,
  server,
  parse,
  unknown,
}
