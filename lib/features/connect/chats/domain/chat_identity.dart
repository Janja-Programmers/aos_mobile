import 'package:africaonlinestores/features/connect/chats/domain/chat_message.dart';

String normalizeCanonicalUserId(String? value) {
  final clean = value?.trim() ?? '';
  if (clean.isEmpty || clean.toLowerCase() == 'null') return '';
  final normalized = clean.toUpperCase();
  return normalized.startsWith('ACC-') ? normalized : '';
}

bool isMessageOwnedBy({
  required ChatMessage message,
  required String? authenticatedCanonicalId,
}) {
  final senderId = normalizeCanonicalUserId(message.senderCanonicalId);
  final currentId = normalizeCanonicalUserId(authenticatedCanonicalId);
  return senderId.isNotEmpty && currentId.isNotEmpty && senderId == currentId;
}
