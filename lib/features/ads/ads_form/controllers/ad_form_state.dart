class AdFormState {
  final int index;
  final bool posting;
  final Set<int> completed;
  final Set<int> attempted;

  const AdFormState({
    this.index = 0,
    this.posting = false,
    this.completed = const {},
    this.attempted = const {},
  });

  AdFormState copyWith({
    int? index,
    bool? posting,
    Set<int>? completed,
    Set<int>? attempted,
  }) {
    return AdFormState(
      index: index ?? this.index,
      posting: posting ?? this.posting,
      completed: completed ?? this.completed,
      attempted: attempted ?? this.attempted,
    );
  }

  AdFormState reset() {
    return const AdFormState();
  }
}
