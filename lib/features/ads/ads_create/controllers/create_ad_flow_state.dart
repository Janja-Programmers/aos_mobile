class CreateAdFlowState {
  final int index;
  final bool posting;
  final Set<int> completed;
  final Set<int> attempted;

  const CreateAdFlowState({
    this.index = 0,
    this.posting = false,
    this.completed = const {},
    this.attempted = const {},
  });

  CreateAdFlowState copyWith({
    int? index,
    bool? posting,
    Set<int>? completed,
    Set<int>? attempted,
  }) {
    return CreateAdFlowState(
      index: index ?? this.index,
      posting: posting ?? this.posting,
      completed: completed ?? this.completed,
      attempted: attempted ?? this.attempted,
    );
  }

  CreateAdFlowState reset() {
    return const CreateAdFlowState();
  }
}
