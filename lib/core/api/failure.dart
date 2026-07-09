import 'package:africaonlinestores/core/utils/json_utils.dart';

/// Represents an error returned by the API layer.
///
/// [error] is the backend machine-readable error token, for example
class Failure implements Exception {
  const Failure(
    this.message, {
    this.statusCode,
    this.type,
    this.error,
    this.data,
  });

  final String message;
  final int? statusCode;
  final FailureType? type;
  final String? error;
  final Map<String, dynamic>? data;

  bool get isAuthRequired {
    final normalized = (error ?? '').trim().toUpperCase();
    return type == FailureType.unauthorized ||
        normalized == 'AUTH_REQUIRED' ||
        normalized == 'SESSION_INVALID' ||
        normalized == 'UNAUTHORIZED' ||
        normalized == 'UNAUTHENTICATED' ||
        normalized == 'LOGIN_REQUIRED';
  }

  Failure copyWith({
    String? message,
    int? statusCode,
    FailureType? type,
    String? error,
    Map<String, dynamic>? data,
  }) {
    return Failure(
      message ?? this.message,
      statusCode: statusCode ?? this.statusCode,
      type: type ?? this.type,
      error: error ?? this.error,
      data: data ?? this.data,
    );
  }

  factory Failure.fromServerPayload(
    Map<String, dynamic> payload, {
    int? statusCode,
    FailureType? type,
    String fallbackMessage = 'Something went wrong. Please try again.',
  }) {
    final rawError = asString(payload['error']).trim().toUpperCase();
    final rawMessage = asString(payload['message']).trim();
    final data = asJsonMap(payload['data']);

    return Failure(
      authFriendlyMessage(rawError, fallback: rawMessage.ifEmpty(fallbackMessage)),
      statusCode: statusCode,
      type: type ?? failureTypeForAuthError(rawError, statusCode: statusCode),
      error: rawError.isEmpty ? null : rawError,
      data: data.isEmpty ? null : data,
    );
  }

  @override
  String toString() =>
      'Failure(message: $message, statusCode: $statusCode, type: $type, error: $error)';
}

extension _EmptyStringFallback on String {
  String ifEmpty(String fallback) => isEmpty ? fallback : this;
}

enum FailureType {
  network,
  timeout,
  unauthorized,
  forbidden,
  notFound,
  rateLimited,
  validation,
  server,
  parse,
  unknown,
}

FailureType failureTypeForAuthError(String? error, {int? statusCode}) {
  final normalized = (error ?? '').trim().toUpperCase();

  switch (normalized) {
    case 'AUTH_REQUIRED':
    case 'SESSION_INVALID':
    case 'UNAUTHORIZED':
    case 'UNAUTHENTICATED':
    case 'LOGIN_REQUIRED':
    case 'INVALID_CREDENTIALS':
      return FailureType.unauthorized;
    case 'ACCOUNT_DISABLED':
    case 'ACCOUNT_DELETED':
    case 'ACCOUNT_DELETED_RESTORABLE':
    case 'ACCOUNT_SUSPENDED':
    case 'EMAIL_NOT_VERIFIED':
      return FailureType.forbidden;
    case 'RATE_LIMITED':
    case 'RATE_LIMIT':
      return FailureType.rateLimited;
    case 'VALIDATION_ERROR':
      return FailureType.validation;
  }

  if (statusCode == 401) return FailureType.unauthorized;
  if (statusCode == 403) return FailureType.forbidden;
  if (statusCode == 404) return FailureType.notFound;
  if (statusCode == 429) return FailureType.rateLimited;
  if (statusCode != null && statusCode >= 500) return FailureType.server;

  return FailureType.unknown;
}

String authFriendlyMessage(String? error, {String? fallback}) {
  final normalized = (error ?? '').trim().toUpperCase();

  switch (normalized) {
    case 'INVALID_CREDENTIALS':
      return 'Invalid email, phone, or password.';
    case 'AUTH_REQUIRED':
    case 'SESSION_INVALID':
    case 'UNAUTHORIZED':
    case 'UNAUTHENTICATED':
    case 'LOGIN_REQUIRED':
      return 'Please log in to continue.';
    case 'ACCOUNT_DISABLED':
      return 'This account is disabled. Please contact support.';
    case 'ACCOUNT_DELETED':
      return 'This account has been deleted or is no longer available.';
    case 'ACCOUNT_DELETED_RESTORABLE':
      return 'This account has been deleted. Please restore it to continue.';
    case 'ACCOUNT_SUSPENDED':
      return 'This account is suspended. Please contact support.';
    case 'RATE_LIMITED':
    case 'RATE_LIMIT':
      return 'Too many attempts. Please try again later.';
    case 'VALIDATION_ERROR':
      return (fallback == null || fallback.trim().isEmpty)
          ? 'Please check the information and try again.'
          : fallback.trim();
    case 'EMAIL_NOT_VERIFIED':
      return 'Please verify your email to continue.';
  }

  return (fallback == null || fallback.trim().isEmpty)
      ? 'Something went wrong. Please try again.'
      : fallback.trim();
}
