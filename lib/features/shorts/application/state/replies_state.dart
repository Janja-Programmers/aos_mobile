import 'package:africaonlinestores/features/shorts/domain/short_comment.dart';

class RepliesState {
  final List<ShortComment> replies;
  final bool isLoading;

  const RepliesState({required this.replies, required this.isLoading});

  factory RepliesState.initial() {
    return const RepliesState(replies: [], isLoading: false);
  }

  RepliesState copyWith({List<ShortComment>? replies, bool? isLoading}) {
    return RepliesState(
      replies: replies ?? this.replies,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
