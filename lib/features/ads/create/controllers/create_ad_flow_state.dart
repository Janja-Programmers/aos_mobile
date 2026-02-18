class CreateAdFlowState {
  final int index;
  final bool posting;
  final Set<int> completed;

  const CreateAdFlowState({
    this.index = 0,
    this.posting = false,
    this.completed = const {},
  });

  CreateAdFlowState copyWith({int? index, bool? posting, Set<int>? completed}) {
    return CreateAdFlowState(
      index: index ?? this.index,
      posting: posting ?? this.posting,
      completed: completed ?? this.completed,
    );
  }

  CreateAdFlowState reset() {
    return const CreateAdFlowState();
  }
}
