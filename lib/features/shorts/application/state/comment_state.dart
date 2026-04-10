import 'package:africaonlinestores/features/shorts/domain/short_comment.dart';

class CommentsState {
  final List<ShortComment> comments;
  final bool isLoading;

  const CommentsState({required this.comments, required this.isLoading});

  factory CommentsState.initial() {
    return const CommentsState(comments: [], isLoading: false);
  }

  CommentsState copyWith({List<ShortComment>? comments, bool? isLoading}) {
    return CommentsState(
      comments: comments ?? this.comments,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
