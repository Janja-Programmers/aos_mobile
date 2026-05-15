import 'package:equatable/equatable.dart';

class ToggleCommentLikeResult extends Equatable {
  final String commentId;
  final bool liked;
  final int? likeCount;

  const ToggleCommentLikeResult({
    required this.commentId,
    required this.liked,
    this.likeCount,
  });

  @override
  List<Object?> get props => [commentId, liked, likeCount];
}
