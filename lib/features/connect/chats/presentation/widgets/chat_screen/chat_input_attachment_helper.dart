import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:africaonlinestores/core/files/data/files_api_provider.dart';
import 'package:africaonlinestores/core/files/helpers/media_helper.dart';
import 'package:africaonlinestores/core/files/domain/upload_file.dart';

import 'package:africaonlinestores/features/connect/chats/domain/helpers/chat_input_controller.dart';

class ChatInputAttachmentHelper {
  static Future<ChatInputAttachment?> pickAndUploadImage(
    WidgetRef ref,
    BuildContext context,
  ) async {
    final file = await MediaHelper.pickImageWithChoice(context);
    if (file == null) return null;

    final res = await ref.read(filesApiProvider).uploadMedia(file: file);

    return res.fold((_) => null, (UploadedFile data) {
      if (data.fileId.isEmpty || data.url.isEmpty) return null;

      return ChatInputAttachment(
        fileId: data.fileId,
        type: 'image',
        previewUrl: data.url,
      );
    });
  }

  static Future<ChatInputAttachment?> pickAndUploadVideo(
    WidgetRef ref,
    BuildContext context,
  ) async {
    final file = await MediaHelper.pickVideoWithChoice(context);
    if (file == null) return null;

    final res = await ref.read(filesApiProvider).uploadMedia(file: file);

    return res.fold((_) => null, (data) {
      if (data.fileId.isEmpty || data.url.isEmpty) return null;

      return ChatInputAttachment(
        fileId: data.fileId,
        type: 'video',
        previewUrl: data.url,
      );
    });
  }

  static Future<ChatInputAttachment?> pickAndUploadDocument(
    WidgetRef ref,
  ) async {
    final file = await MediaHelper.pickDocument();
    if (file == null) return null;

    final res = await ref.read(filesApiProvider).uploadMedia(file: file);

    return res.fold((_) => null, (UploadedFile data) {
      if (data.fileId.isEmpty || data.url.isEmpty) return null;

      return ChatInputAttachment(
        fileId: data.fileId,
        type: 'document',
        previewUrl: data.url,
      );
    });
  }
}
