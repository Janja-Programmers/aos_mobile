import 'dart:io';

import 'package:africaonlinestores/core/utils/logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:africaonlinestores/core/routing/helpers/app_routes.dart';
import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:africaonlinestores/shared/widgets/app_snack.dart';

import 'package:africaonlinestores/features/connect/chats/domain/helpers/chat_input_controller.dart';
import 'package:africaonlinestores/features/maps/domain/aos_place.dart';
import 'package:africaonlinestores/features/connect/chats/domain/helpers/chat_pending_attachment.dart';
import 'package:africaonlinestores/features/connect/chats/presentation/widgets/chat_screen/chat_input/chat_attachment_sheet.dart';
import 'package:africaonlinestores/features/connect/chats/presentation/widgets/chat_screen/chat_input/chat_input_attachment_helper.dart';
import 'package:africaonlinestores/features/connect/chats/presentation/widgets/chat_screen/chat_input/attachment_preview.dart';
import 'package:africaonlinestores/features/connect/chats/presentation/widgets/chat_screen/chat_input/input_icon_button.dart';
import 'package:africaonlinestores/features/connect/chats/presentation/widgets/chat_screen/chat_input/voice_record_button.dart';

class ChatAttachmentUploadException implements Exception {
  final String message;

  const ChatAttachmentUploadException(this.message);

  @override
  String toString() => message;
}

class ChatInputBar extends ConsumerStatefulWidget {
  final TextEditingController controller;
  final Future<void> Function({
    String? text,
    List<ChatInputAttachment> attachments,
  })
  onSend;

  final Function(bool isTyping) onTyping;
  final String? adId;

  const ChatInputBar({
    super.key,
    required this.controller,
    required this.onSend,
    required this.onTyping,
    this.adId,
  });

  @override
  ConsumerState<ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends ConsumerState<ChatInputBar> {
  bool _isSending = false;
  bool _showAttachmentPanel = false;

  final List<ChatPendingAttachment> _attachments = [];

  bool get _hasText => widget.controller.text.trim().isNotEmpty;
  bool get _hasAttachments => _attachments.isNotEmpty;
  bool get _hasAdContext =>
      widget.adId != null && widget.adId!.trim().isNotEmpty;

  bool get _canSend => _hasText || _hasAttachments || _hasAdContext;

  Future<void> _submit() async {
    if (_isSending) return;
    if (!_canSend) return;

    final text = widget.controller.text.trim();
    final pendingAttachments = List<ChatPendingAttachment>.of(_attachments);

    setState(() {
      _isSending = true;
      _attachments.clear();
    });

    widget.onTyping(false);

    try {
      final uploadedAttachments = <ChatInputAttachment>[];

      for (final pending in pendingAttachments) {
        final uploaded =
            await ChatInputAttachmentHelper.uploadPendingAttachment(
              ref,
              pending,
            );

        if (uploaded == null) {
          throw const ChatAttachmentUploadException(
            'Attachment upload failed.',
          );
        }

        uploadedAttachments.add(uploaded);
      }

      await widget.onSend(
        text: text.isNotEmpty ? text : null,
        attachments: uploadedAttachments,
      );
    } catch (_) {
      if (mounted) {
        setState(() {
          _attachments
            ..clear()
            ..addAll(pendingAttachments);
        });

        ShowSnack(
          context,
          'Attachment upload failed. Please try again.',
        ).error();
      }

      return;
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }

  Future<void> _pickGallery() async {
    final attachments = await ChatInputAttachmentHelper.pickImagesOnly();

    if (attachments.isEmpty) return;

    setState(() {
      _attachments.addAll(attachments);
    });
  }

  Future<void> _pickCameraImage() async {
    final attachment = await ChatInputAttachmentHelper.pickCameraImageOnly();

    if (attachment == null) return;

    setState(() {
      _attachments.add(attachment);
    });
  }

  Future<void> _pickDocument() async {
    final attachment = await ChatInputAttachmentHelper.pickDocumentOnly();

    if (attachment == null) return;

    setState(() {
      _attachments.add(attachment);
    });
  }

  void _toggleAttachmentPanel() {
    FocusScope.of(context).unfocus();

    setState(() {
      _showAttachmentPanel = !_showAttachmentPanel;
    });
  }

  void _closeAttachmentPanel() {
    if (!_showAttachmentPanel) return;

    setState(() {
      _showAttachmentPanel = false;
    });
  }

  Future<void> _handleGalleryTap() async {
    _closeAttachmentPanel();
    await _pickGallery();
  }

  Future<void> _handleCameraTap() async {
    _closeAttachmentPanel();
    await _pickCameraImage();
  }

  Future<void> _handleDocumentTap() async {
    _closeAttachmentPanel();
    await _pickDocument();
  }

  Future<void> _handleLocationTap() async {
    _closeAttachmentPanel();

    final picked = await context.pushNamed<AOSPlace>(
      AppRoutes.nMapPicker,
      queryParameters: {'title': 'Share location'},
    );

    if (picked == null) return;

    final message =
        '''📍 Shared location
${picked.shortLabel}
${picked.displayAddress}
https://maps.google.com/?q=${picked.latitude},${picked.longitude}''';

    await widget.onSend(text: message, attachments: const []);
  }

  Future<void> _handleFolderTap() async {
    _closeAttachmentPanel();
    await _pickDocument();
  }

  Future<void> _handleVoiceRecorded(String path) async {
    if (_isSending) return;

    final file = File(path);

    if (!await file.exists()) return;

    final filename = file.path.split(Platform.pathSeparator).last;
    final extension = filename.contains('.')
        ? filename.split('.').last.toLowerCase()
        : '';

    appLogger.i('Audio path: ${file.path}');
    appLogger.i('Audio filename: $filename');
    appLogger.i('Audio extension: $extension');
    appLogger.i('Audio size: ${await file.length()} bytes');

    setState(() {
      _attachments.add(ChatPendingAttachment(file: file, type: 'audio'));
    });

    await _submit();
  }

  Widget _buildInputRow(
    dynamic colors,
    InputDecorationThemeData inputDecorationTheme,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Container(
              constraints: const BoxConstraints(minHeight: 42),
              padding: const EdgeInsets.only(left: 14, right: 4),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: colors.border),
                boxShadow: [
                  BoxShadow(
                    color: colors.black.withOpacity(0.06),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextField(
                      controller: widget.controller,
                      minLines: 1,
                      maxLines: 4,
                      textInputAction: TextInputAction.newline,
                      onChanged: (text) {
                        if (_showAttachmentPanel) {
                          setState(() {
                            _showAttachmentPanel = false;
                          });
                        }

                        widget.onTyping(text.trim().isNotEmpty);
                        setState(() {});
                      },
                      decoration: InputDecoration(
                        hintText: 'Message',
                        isDense: true,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 11,
                        ),
                        hintStyle: TextStyle(color: colors.textMuted),
                      ).applyDefaults(inputDecorationTheme),
                    ),
                  ),

                  InputIconButton(
                    icon: _showAttachmentPanel
                        ? Icons.close_rounded
                        : Icons.attach_file_rounded,
                    onTap: _toggleAttachmentPanel,
                  ),

                  InputIconButton(
                    icon: Icons.photo_camera_outlined,
                    onTap: _pickCameraImage,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(width: 6),

          if (_canSend)
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _isSending ? null : _submit,
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: colors.primary,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: colors.black.withOpacity(0.08),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Center(
                  child: _isSending
                      ? SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: colors.textPrimary,
                          ),
                        )
                      : Icon(
                          Icons.send_rounded,
                          color: colors.textPrimary,
                          size: 22,
                        ),
                ),
              ),
            )
          else
            VoiceRecordButton(
              disabled: _isSending,
              onRecorded: _handleVoiceRecorded,
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final inputDecorationTheme = Theme.of(context).inputDecorationTheme;

    return Container(
      color: colors.surface,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_attachments.isNotEmpty)
            AttachmentPreviewBar(
              attachments: _attachments,
              onRemove: (index) {
                setState(() {
                  _attachments.removeAt(index);
                });
              },
            ),

          AnimatedSize(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            alignment: Alignment.bottomCenter,
            child: _showAttachmentPanel
                ? SizedBox(
                    height: 310,
                    child: Stack(
                      alignment: Alignment.bottomCenter,
                      children: [
                        Positioned.fill(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(8, 0, 8, 56),
                            child: ChatAttachmentSheet(
                              onGallery: _handleGalleryTap,
                              onCamera: _handleCameraTap,
                              onDocument: _handleDocumentTap,
                              onLocation: _handleLocationTap,
                              onFolder: _handleFolderTap,
                            ),
                          ),
                        ),

                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 0,
                          child: _buildInputRow(colors, inputDecorationTheme),
                        ),
                      ],
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
                    child: _buildInputRow(colors, inputDecorationTheme),
                  ),
          ),
        ],
      ),
    );
  }
}
