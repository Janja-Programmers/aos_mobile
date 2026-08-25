import 'dart:io';

import 'package:africaonlinestores/core/media/application/media_services_provider.dart';
import 'package:africaonlinestores/core/media/domain/media_policy.dart';
import 'package:africaonlinestores/features/connect/chats/domain/helpers/chat_input_controller.dart';
import 'package:africaonlinestores/features/connect/chats/domain/helpers/chat_pending_attachment.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChatInputAttachmentHelper {
  const ChatInputAttachmentHelper._();

  static Future<List<ChatPendingAttachment>> pickImagesOnly(
    WidgetRef ref,
  ) async {
    final media = await ref
        .read(mediaAcquisitionServiceProvider)
        .pickImages(useCase: MediaUseCase.chatImage);

    return media
        .map(
          (item) => ChatPendingAttachment(
            file: item.file,
            type: 'image',
            deleteAfterUse: item.ownedByApp,
          ),
        )
        .toList(growable: false);
  }

  static Future<ChatPendingAttachment?> pickCameraImageOnly(
    WidgetRef ref,
    BuildContext context,
  ) async {
    final media = await ref
        .read(mediaAcquisitionServiceProvider)
        .captureImage(context, useCase: MediaUseCase.chatImage);
    if (media == null) return null;

    return ChatPendingAttachment(
      file: media.file,
      type: 'image',
      deleteAfterUse: media.ownedByApp,
    );
  }

  static Future<ChatPendingAttachment?> pickDocumentOnly(WidgetRef ref) async {
    final media = await ref
        .read(mediaAcquisitionServiceProvider)
        .pickAnyFile(useCase: MediaUseCase.chatFile);
    if (media == null) return null;

    return ChatPendingAttachment(
      file: media.file,
      type: _inferType(media.path),
      deleteAfterUse: media.ownedByApp,
    );
  }

  static Future<ChatPendingAttachment?> pickAudioOnly(WidgetRef ref) async {
    final media = await ref
        .read(mediaAcquisitionServiceProvider)
        .pickAudio(useCase: MediaUseCase.chatAudio);
    if (media == null) return null;

    return ChatPendingAttachment(
      file: media.file,
      type: 'audio',
      deleteAfterUse: media.ownedByApp,
    );
  }

  static Future<ChatInputAttachment?> uploadPendingAttachment(
    WidgetRef ref,
    ChatPendingAttachment pending,
  ) async {
    final useCase = switch (pending.type) {
      'image' => MediaUseCase.chatImage,
      'video' => MediaUseCase.chatVideo,
      'audio' || 'voice' || 'voice_note' => MediaUseCase.chatAudio,
      _ => MediaUseCase.chatFile,
    };
    final result = await ref
        .read(mediaUploadCoordinatorProvider)
        .uploadFile(file: pending.file, useCase: useCase);

    return result.fold((_) => null, (data) {
      if (data.mediaId.isEmpty) return null;
      return ChatInputAttachment(
        fileId: data.mediaId,
        type: pending.type,
        previewUrl: data.url.isNotEmpty ? data.url : pending.file.path,
      );
    });
  }

  static String _inferType(String path) {
    final lower = path.toLowerCase();
    if (lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.png') ||
        lower.endsWith('.webp') ||
        lower.endsWith('.heic') ||
        lower.endsWith('.heif')) {
      return 'image';
    }
    if (lower.endsWith('.mp4') ||
        lower.endsWith('.mov') ||
        lower.endsWith('.m4v')) {
      return 'video';
    }
    if (lower.endsWith('.mp3') ||
        lower.endsWith('.m4a') ||
        lower.endsWith('.aac') ||
        lower.endsWith('.wav') ||
        lower.endsWith('.ogg')) {
      return 'audio';
    }
    return 'document';
  }

  static Future<ChatInputAttachment?> uploadAudio(
    WidgetRef ref,
    String path,
  ) async {
    final file = File(path);
    // ignore: avoid_slow_async_io
    if (!await file.exists()) return null;
    return uploadPendingAttachment(
      ref,
      ChatPendingAttachment(file: file, type: 'audio'),
    );
  }
}
