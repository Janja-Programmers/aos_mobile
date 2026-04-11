import 'dart:developer' as developer;

class CallLogger {
  const CallLogger._();

  static void log(String message) {
    developer.log(message, name: 'AOSCall');
  }

  static void state(String message) {
    developer.log(message, name: 'AOSCallState');
  }

  static void socket(String message) {
    developer.log(message, name: 'AOSCallSocket');
  }

  static void room(String message) {
    developer.log(message, name: 'AOSCallRoom');
  }

  static void error(String message, [Object? error, StackTrace? stackTrace]) {
    developer.log(
      message,
      name: 'AOSCallError',
      error: error,
      stackTrace: stackTrace,
    );
  }
}
