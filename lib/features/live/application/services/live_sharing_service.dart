import 'package:africaonlinestores/features/live/repository/live_repository_impl.dart';
import 'package:uuid/uuid.dart';

class LiveSharingService {
  const LiveSharingService(this._repository);

  static const Uuid _uuid = Uuid();

  final LiveRepository _repository;

  Future<void> shareToChats({
    required String liveId,
    required Iterable<String> conversationIds,
    String? message,
  }) async {
    final uniqueIds = conversationIds
        .map((id) => id.trim())
        .where((id) => id.isNotEmpty)
        .toSet();

    for (final conversationId in uniqueIds) {
      await _repository.shareLiveToChat(
        liveId: liveId,
        conversationId: conversationId,
        message: message,
        idempotencyKey: _uuid.v4(),
      );
    }
  }
}
