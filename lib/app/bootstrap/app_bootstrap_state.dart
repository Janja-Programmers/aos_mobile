class AppBootstrapState {
  final bool isReady;
  final bool onboardingCompleted;

  const AppBootstrapState({
    required this.isReady,
    required this.onboardingCompleted,
  });

  /// Initial loading state when app starts
  factory AppBootstrapState.initial() {
    return const AppBootstrapState(isReady: false, onboardingCompleted: false);
  }

  /// Allows updating bootstrap state safely
  AppBootstrapState copyWith({bool? isReady, bool? onboardingCompleted}) {
    return AppBootstrapState(
      isReady: isReady ?? this.isReady,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
    );
  }

  @override
  String toString() {
    return 'AppBootstrapState(isReady: $isReady, onboardingCompleted: $onboardingCompleted)';
  }
}
