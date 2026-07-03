import 'package:africaonlinestores/core/utils/media_url.dart';
import 'package:africaonlinestores/features/connect/calls/application/state/call_state.dart';
import 'package:africaonlinestores/features/connect/calls/domain/call_participant.dart';

class ResolvedCallParticipant {
  final CallParticipant? participant;
  final String displayName;
  final String userId;
  final String? avatarUrl;
  final String initials;

  const ResolvedCallParticipant({
    required this.participant,
    required this.displayName,
    required this.userId,
    required this.avatarUrl,
    required this.initials,
  });

  bool get hasParticipant => participant != null;
}

/// Resolves the human the current user is talking to in a call.
class CallParticipantResolver {
  const CallParticipantResolver._();

  static ResolvedCallParticipant otherParticipant(
    CallState state, {
    String? currentUserId,
    String fallbackName = 'AOS Call',
  }) {
    final caller = state.caller ?? state.activeCall?.caller;
    final receiver = state.receiver ?? state.activeCall?.receiver;
    final current = _normalizeUserId(currentUserId);

    final byDirection = _participantFromDirection(
      direction: state.direction,
      caller: caller,
      receiver: receiver,
      currentUserId: current,
    );

    if (byDirection != null) {
      return _resolved(byDirection, fallbackName: fallbackName);
    }

    if (current != null) {
      for (final participant in <CallParticipant?>[receiver, caller]) {
        if (participant == null) continue;
        if (_normalizeUserId(participant.userId) != current) {
          return _resolved(participant, fallbackName: fallbackName);
        }
      }
    }

    return _fallback(fallbackName);
  }

  static CallParticipant? _participantFromDirection({
    required String? direction,
    required CallParticipant? caller,
    required CallParticipant? receiver,
    required String? currentUserId,
  }) {
    final normalizedDirection = direction?.trim().toLowerCase();

    if (normalizedDirection == 'incoming') {
      return _safePrimary(
        primary: caller,
        secondary: receiver,
        currentUserId: currentUserId,
      );
    }

    if (normalizedDirection == 'outgoing') {
      return _safePrimary(
        primary: receiver,
        secondary: caller,
        currentUserId: currentUserId,
      );
    }

    return null;
  }

  static CallParticipant? _safePrimary({
    required CallParticipant? primary,
    required CallParticipant? secondary,
    required String? currentUserId,
  }) {
    if (!_isCurrentUser(primary, currentUserId)) {
      return primary;
    }

    if (!_isCurrentUser(secondary, currentUserId)) {
      return secondary;
    }

    return null;
  }

  static bool _isCurrentUser(
    CallParticipant? participant,
    String? currentUserId,
  ) {
    if (participant == null || currentUserId == null) return false;
    return _normalizeUserId(participant.userId) == currentUserId;
  }

  static ResolvedCallParticipant _resolved(
    CallParticipant participant, {
    required String fallbackName,
  }) {
    final displayName =
        _cleanDisplayText(participant.displayName) ??
        _cleanDisplayText(participant.userId) ??
        fallbackName;
    final userId = _cleanDisplayText(participant.userId) ?? '';

    return ResolvedCallParticipant(
      participant: participant,
      displayName: displayName,
      userId: userId,
      avatarUrl: normalizeMediaUrl(_cleanDisplayText(participant.avatarUrl)),
      initials: initialsFor(displayName, fallback: 'A'),
    );
  }

  static ResolvedCallParticipant _fallback(String fallbackName) {
    final displayName = _cleanDisplayText(fallbackName) ?? 'AOS Call';

    return ResolvedCallParticipant(
      participant: null,
      displayName: displayName,
      userId: '',
      avatarUrl: null,
      initials: initialsFor(displayName, fallback: 'A'),
    );
  }

  static String initialsFor(String text, {String fallback = '?'}) {
    final cleaned = text.trim();
    if (cleaned.isEmpty) return fallback;

    final parts = cleaned
        .split(RegExp(r'\s+'))
        .where((part) => part.trim().isNotEmpty)
        .toList();

    if (parts.isEmpty) return fallback;

    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }

    return '${parts.first.substring(0, 1)}${parts.last.substring(0, 1)}'
        .toUpperCase();
  }

  static String? _normalizeUserId(String? value) {
    final cleaned = _cleanDisplayText(value);
    return cleaned?.toLowerCase();
  }

  static String? _cleanDisplayText(String? value) {
    final text = value?.trim();
    if (text == null || text.isEmpty || text.toLowerCase() == 'null') {
      return null;
    }
    return text;
  }
}
