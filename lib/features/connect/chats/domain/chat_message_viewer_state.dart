const Object _unset = Object();

class ChatMessageViewerState {
  final bool isStarred;
  final String? myReaction;

  const ChatMessageViewerState({this.isStarred = false, this.myReaction});

  factory ChatMessageViewerState.fromJson(Map<String, dynamic>? json) {
    return ChatMessageViewerState(
      isStarred: _truthy(json?['is_starred']),
      myReaction: _cleanNullableString(json?['my_reaction']),
    );
  }

  ChatMessageViewerState copyWith({
    bool? isStarred,
    Object? myReaction = _unset,
  }) {
    return ChatMessageViewerState(
      isStarred: isStarred ?? this.isStarred,
      myReaction: identical(myReaction, _unset)
          ? this.myReaction
          : myReaction as String?,
    );
  }
}

bool _truthy(dynamic value) {
  if (value == null) return false;
  if (value == true) return true;
  if (value == false) return false;
  if (value is num) return value != 0;

  final text = value.toString().trim().toLowerCase();
  return text == '1' || text == 'true' || text == 'yes';
}

String? _cleanNullableString(dynamic value) {
  if (value == null) return null;

  final text = value.toString().trim();
  if (text.isEmpty || text.toLowerCase() == 'null') return null;

  return text;
}
