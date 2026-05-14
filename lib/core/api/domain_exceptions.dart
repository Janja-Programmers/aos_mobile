// Represents errors that can occur in the domain layer (business logic)
abstract class DomainException implements Exception {
  final String message;
  DomainException(this.message);

  @override
  String toString() => message;
}

/// Thrown when a network operation fails
class NetworkException extends DomainException {
  final int? statusCode;
  NetworkException(String message, {this.statusCode}) : super(message);
}

/// Thrown when authentication fails (401)
class AuthenticationException extends DomainException {
  AuthenticationException(String message) : super(message);
}

/// Thrown when access is forbidden (403)
class ForbiddenException extends DomainException {
  ForbiddenException(String message) : super(message);
}

/// Thrown when a resource is not found (404)
class NotFoundException extends DomainException {
  NotFoundException(String message) : super(message);
}

/// Thrown when server validation fails (422)
class ValidationException extends DomainException {
  final Map<String, dynamic>? errors;
  ValidationException(String message, {this.errors}) : super(message);
}

/// Thrown when server error occurs (5xx)
class ServerException extends DomainException {
  ServerException(String message) : super(message);
}

/// Thrown when timeout occurs
class TimeoutException extends DomainException {
  TimeoutException(String message) : super(message);
}

/// Thrown when no internet connection
class NoInternetException extends DomainException {
  NoInternetException([String message = 'No internet connection']) : super(message);
}

/// Thrown for unexpected/unknown errors
class UnknownException extends DomainException {
  UnknownException([String message = 'An unexpected error occurred']) : super(message);
}
