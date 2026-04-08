class FeedWindow {
  final int activeIndex;
  final Set<int> keepAlive;
  final Set<int> preload;
  final Set<int> dispose;

  const FeedWindow({
    required this.activeIndex,
    required this.keepAlive,
    required this.preload,
    required this.dispose,
  });
}
