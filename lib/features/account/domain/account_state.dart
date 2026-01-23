class AccountState {
  const AccountState({
    this.loading = false,
    this.profile = const {},
    this.errorMessage,
  });

  final bool loading;
  final Map<String, dynamic> profile;
  final String? errorMessage;

  AccountState copyWith({
    bool? loading,
    Map<String, dynamic>? profile,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AccountState(
      loading: loading ?? this.loading,
      profile: profile ?? this.profile,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
