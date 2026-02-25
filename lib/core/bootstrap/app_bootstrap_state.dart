class AppBootstrapState {
  final bool isReady;
  final bool onboardingCompleted;

  const AppBootstrapState({
    required this.isReady,
    required this.onboardingCompleted,
  });

  factory AppBootstrapState.initial() =>
      const AppBootstrapState(isReady: false, onboardingCompleted: false);
}
