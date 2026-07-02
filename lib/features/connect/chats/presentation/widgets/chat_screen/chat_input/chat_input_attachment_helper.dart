import 'dart:io';

import 'package:africaonlinestores/core/files/data/files_api_provider.dart';
import 'package:africaonlinestores/core/files/domain/upload_file.dart';
import 'package:africaonlinestores/core/files/helpers/media_helper.dart';
import 'package:africaonlinestores/features/connect/chats/domain/helpers/chat_input_controller.dart';
import 'package:africaonlinestores/features/connect/chats/domain/helpers/chat_pending_attachment.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChatInputAttachmentHelper {
  const ChatInputAttachmentHelper._();

  static Future<List<ChatPendingAttachment>> pickImagesOnly() async {
    final files = await MediaHelper.pickImagesFromGallery();

    return files
        .map((file) => ChatPendingAttachment(file: file, type: 'image'))
        .toList();
  }

  static Future<ChatPendingAttachment?> pickCameraImageOnly() async {
    final file = await MediaHelper.pickImageFromCamera();
    if (file == null) return null;

    return ChatPendingAttachment(file: file, type: 'image');
  }

  static Future<ChatPendingAttachment?> pickDocumentOnly() async {
    final file = await MediaHelper.pickAnyFile();
    if (file == null) return null;

    return ChatPendingAttachment(file: file, type: _inferType(file.path));
  }

  static Future<ChatInputAttachment?> uploadPendingAttachment(
    WidgetRef ref,
    ChatPendingAttachment pending,
  ) async {
    return _upload(ref, pending.file, fallbackType: pending.type);
  }

  static Future<ChatInputAttachment?> pickAndUploadImage(
    WidgetRef ref,
    BuildContext context,
  ) async {
    final file = await MediaHelper.pickImageFromGallery();
    if (file == null) return null;

    return _upload(ref, file, fallbackType: 'image');
  }

  static Future<List<ChatInputAttachment>> pickAndUploadImages(
    WidgetRef ref,
  ) async {
    final files = await MediaHelper.pickImagesFromGallery();
    if (files.isEmpty) return [];

    final attachments = <ChatInputAttachment>[];

    for (final file in files) {
      final uploaded = await _upload(ref, file, fallbackType: 'image');
      if (uploaded != null) attachments.add(uploaded);
    }

    return attachments;
  }

  static Future<ChatInputAttachment?> pickAndUploadCameraImage(
    WidgetRef ref,
  ) async {
    final file = await MediaHelper.pickImageFromCamera();
    if (file == null) return null;

    return _upload(ref, file, fallbackType: 'image');
  }

  static Future<ChatInputAttachment?> pickAndUploadVideo(WidgetRef ref) async {
    final file = await MediaHelper.pickVideoFromGallery();
    if (file == null) return null;

    return _upload(ref, file, fallbackType: 'video');
  }

  static Future<ChatInputAttachment?> recordAndUploadVideo(
    WidgetRef ref,
  ) async {
    final file = await MediaHelper.recordVideoFromCamera();
    if (file == null) return null;

    return _upload(ref, file, fallbackType: 'video');
  }

  static Future<ChatInputAttachment?> pickAndUploadDocument(
    WidgetRef ref,
  ) async {
    final file = await MediaHelper.pickAnyFile();
    if (file == null) return null;

    return _upload(ref, file, fallbackType: _inferType(file.path));
  }

  static Future<ChatInputAttachment?> uploadAudio(
    WidgetRef ref,
    String path,
  ) async {
    final file = File(path);

    if (!file.existsSync()) return null;

    return _upload(ref, file, fallbackType: 'audio');
  }

  static Future<ChatInputAttachment?> _upload(
    WidgetRef ref,
    File file, {
    required String fallbackType,
  }) async {
    final res = await ref.read(filesApiProvider).uploadMedia(file: file);

    return res.fold((_) => null, (UploadedFile data) {
      if (data.fileId.isEmpty || data.url.isEmpty) return null;

      return ChatInputAttachment(
        fileId: data.fileId,
        type: fallbackType,
        previewUrl: data.url,
      );
    });
  }

  static String _inferType(String path) {
    final ext = path.split('.').last.toLowerCase();

    const imageExts = {'jpg', 'jpeg', 'png', 'webp', 'gif', 'heic'};
    const videoExts = {'mp4', 'mov', 'avi', 'mkv', 'webm'};
    const audioExts = {'mp3', 'm4a', 'aac', 'wav', 'ogg', 'opus'};

    if (imageExts.contains(ext)) return 'image';
    if (videoExts.contains(ext)) return 'video';
    if (audioExts.contains(ext)) return 'audio';

    return 'document';
  }
}
