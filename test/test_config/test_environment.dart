class TestEnvironment {
  TestEnvironment._();

  static final DateTime fixedNow = DateTime.utc(2026, 1, 15, 12);
  static const String apiBaseUrl = 'https://api.example.invalid';
  static const String mediaBaseUrl = 'https://cdn.example.invalid';
  static const String userEmail = 'user@example.invalid';
  static const String sessionId = 'test-session-id';
}
