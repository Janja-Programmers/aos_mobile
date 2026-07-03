import 'dart:async';
import 'dart:io';

import 'package:africaonlinestores/core/routing/helpers/app_routes.dart';
import 'package:africaonlinestores/core/theme/app_color_tokens.dart';
import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:africaonlinestores/core/utils/logger.dart';
import 'package:africaonlinestores/features/connect/chats/application/controllers/chat_local_preferences_controller.dart';
import 'package:africaonlinestores/features/connect/chats/domain/helpers/chat_input_controller.dart';
import 'package:africaonlinestores/features/connect/chats/domain/helpers/chat_pending_attachment.dart';
import 'package:africaonlinestores/features/connect/chats/domain/payloads/chat_shared_payload.dart';
import 'package:africaonlinestores/features/connect/chats/presentation/widgets/chat_screen/chat_input/attachment_preview.dart';
import 'package:africaonlinestores/features/connect/chats/presentation/widgets/chat_screen/chat_input/chat_attachment_sheet.dart';
import 'package:africaonlinestores/features/connect/chats/presentation/widgets/chat_screen/chat_input/chat_emoji_panel.dart';
import 'package:africaonlinestores/features/connect/chats/presentation/widgets/chat_screen/chat_input/chat_input_attachment_helper.dart';
import 'package:africaonlinestores/features/connect/chats/presentation/widgets/chat_screen/chat_input/input_icon_button.dart';
import 'package:africaonlinestores/features/connect/chats/presentation/widgets/chat_screen/chat_input/share_contact_picker_sheet.dart';
import 'package:africaonlinestores/features/connect/chats/presentation/widgets/chat_screen/chat_input/voice_record_button.dart';
import 'package:africaonlinestores/features/maps/domain/aos_place.dart';
import 'package:africaonlinestores/shared/widgets/app_snack.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ChatAttachmentUploadException implements Exception {
  const ChatAttachmentUploadException(this.message);

  final String message;

  @override
  String toString() => message;
}

class ChatInputBar extends ConsumerStatefulWidget {
  const ChatInputBar({
    super.key,
    required this.controller,
    required this.onSend,
    required this.onTyping,
    required this.preferences,
    this.adId,
  });

  final TextEditingController controller;
  final Future<void> Function({
    String? text,
    List<ChatInputAttachment> attachments,
  })
  onSend;

  final ValueChanged<bool> onTyping;
  final ChatLocalPreferencesState preferences;
  final String? adId;

  @override
  ConsumerState<ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends ConsumerState<ChatInputBar> {
  final FocusNode _inputFocusNode = FocusNode();
  final List<ChatPendingAttachment> _attachments = [];

  bool _isSending = false;
  bool _showAttachmentPanel = false;
  bool _showEmojiPanel = false;

  bool get _hasText => widget.controller.text.trim().isNotEmpty;
  bool get _hasAttachments => _attachments.isNotEmpty;
  bool get _hasAdContext =>
      widget.adId != null && widget.adId!.trim().isNotEmpty;

  bool get _canSend => _hasText || _hasAttachments || _hasAdContext;

  @override
  void dispose() {
    _inputFocusNode.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isSending || !_canSend) return;

    final text = widget.controller.text.trim();
    final pendingAttachments = List<ChatPendingAttachment>.of(_attachments);

    setState(() {
      _isSending = true;
      _attachments.clear();
      _showAttachmentPanel = false;
      _showEmojiPanel = false;
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

      if (!mounted) return;

      await widget.onSend(
        text: text.isNotEmpty ? text : null,
        attachments: uploadedAttachments,
      );
    } catch (error, stackTrace) {
      appLogger.w(
        'Failed to send chat attachment.',
        error: error,
        stackTrace: stackTrace,
      );
      if (!mounted) return;

      setState(() {
        _attachments
          ..clear()
          ..addAll(pendingAttachments);
      });

      ShowSnack(context, 'Attachment upload failed. Please try again.').error();
      return;
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }

  Future<void> _pickGallery() async {
    final attachments = await ChatInputAttachmentHelper.pickImagesOnly();
    if (!mounted || attachments.isEmpty) return;

    setState(() => _attachments.addAll(attachments));
  }

  Future<void> _pickCameraImage() async {
    final attachment = await ChatInputAttachmentHelper.pickCameraImageOnly();
    if (!mounted || attachment == null) return;

    setState(() => _attachments.add(attachment));
  }

  Future<void> _pickDocument() async {
    final attachment = await ChatInputAttachmentHelper.pickDocumentOnly();
    if (!mounted || attachment == null) return;

    setState(() => _attachments.add(attachment));
  }

  void _toggleAttachmentPanel() {
    FocusScope.of(context).unfocus();

    setState(() {
      _showAttachmentPanel = !_showAttachmentPanel;
      if (_showAttachmentPanel) _showEmojiPanel = false;
    });
  }

  void _toggleEmojiPanel() {
    FocusScope.of(context).unfocus();

    setState(() {
      _showEmojiPanel = !_showEmojiPanel;
      if (_showEmojiPanel) _showAttachmentPanel = false;
    });
  }

  void _closePanels() {
    if (!_showAttachmentPanel && !_showEmojiPanel) return;

    setState(() {
      _showAttachmentPanel = false;
      _showEmojiPanel = false;
    });
  }

  Future<void> _handleGalleryTap() async {
    _closePanels();
    await _pickGallery();
  }

  Future<void> _handleCameraTap() async {
    _closePanels();
    await _pickCameraImage();
  }

  Future<void> _handleDocumentTap() async {
    _closePanels();
    await _pickDocument();
  }

  Future<void> _handleContactTap() async {
    _closePanels();

    final contact = await showShareContactPickerSheet(context: context);
    if (!mounted || contact == null) return;

    await widget.onSend(
      text: contact.toMessageContent(),
      attachments: const [],
    );
  }

  Future<void> _handleLocationTap() async {
    _closePanels();

    final picked = await context.pushNamed<AOSPlace>(
      AppRoutes.nMapPicker,
      queryParameters: {'title': 'Share location'},
    );

    if (!mounted || picked == null) return;

    final payload = ChatLocationPayload(
      name: picked.shortLabel,
      address: picked.displayAddress,
      latitude: picked.latitude,
      longitude: picked.longitude,
    );

    await widget.onSend(
      text: payload.toMessageContent(),
      attachments: const [],
    );
  }

  Future<void> _handleVoiceRecorded(String path) async {
    if (_isSending) return;

    final file = File(path);
    final fileExists = file.existsSync();
    if (!fileExists) return;

    final filename = file.path.split(Platform.pathSeparator).last;
    final extension = filename.contains('.')
        ? filename.split('.').last.toLowerCase()
        : '';

    appLogger.i('Audio path: ${file.path}');
    appLogger.i('Audio filename: $filename');
    appLogger.i('Audio extension: $extension');

    final fileSize = file.lengthSync();
    appLogger.i('Audio size: $fileSize bytes');

    if (!mounted) return;

    setState(() {
      _attachments.add(ChatPendingAttachment(file: file, type: 'audio'));
    });

    await _submit();
  }

  void _insertEmoji(String emoji) {
    final text = widget.controller.text;
    final selection = widget.controller.selection;
    final start = selection.start < 0 ? text.length : selection.start;
    final end = selection.end < 0 ? text.length : selection.end;
    final updated = text.replaceRange(start, end, emoji);
    final cursor = start + emoji.length;

    widget.controller.value = TextEditingValue(
      text: updated,
      selection: TextSelection.collapsed(offset: cursor),
    );

    widget.onTyping(updated.trim().isNotEmpty);
    setState(() {});
  }

  Future<void> _handleSubmitted(String value) async {
    if (!widget.preferences.enterToSend) return;
    if (value.trim().isEmpty && !_canSend) return;
    await _submit();
  }

  Widget _buildInputRow(
    AppColorTokens colors,
    InputDecorationThemeData inputDecorationTheme,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Container(
              constraints: const BoxConstraints(minHeight: 54),
              padding: const EdgeInsets.only(left: 8, right: 6),
              decoration: BoxDecoration(
                color: colors.elevated,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: colors.border),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  InputIconButton(
                    icon: _showEmojiPanel
                        ? Icons.keyboard_rounded
                        : Icons.emoji_emotions_outlined,
                    onTap: _toggleEmojiPanel,
                  ),
                  Expanded(
                    child: TextField(
                      focusNode: _inputFocusNode,
                      controller: widget.controller,
                      minLines: 1,
                      maxLines: 4,
                      keyboardType: TextInputType.multiline,
                      textInputAction: widget.preferences.enterToSend
                          ? TextInputAction.send
                          : TextInputAction.newline,
                      onSubmitted: (value) {
                        unawaited(_handleSubmitted(value));
                      },
                      onTap: _closePanels,
                      onChanged: (text) {
                        if (_showAttachmentPanel || _showEmojiPanel) {
                          setState(() {
                            _showAttachmentPanel = false;
                            _showEmojiPanel = false;
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
                          vertical: 15,
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
                    onTap: () {
                      unawaited(_pickCameraImage());
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          if (_canSend)
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _isSending
                  ? null
                  : () {
                      unawaited(_submit());
                    },
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: colors.primary,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: _isSending
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: colors.white,
                          ),
                        )
                      : Icon(Icons.send_rounded, color: colors.white, size: 24),
                ),
              ),
            )
          else
            VoiceRecordButton(
              disabled: _isSending,
              size: 56,
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

    return ColoredBox(
      color: colors.surface,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_attachments.isNotEmpty)
            AttachmentPreviewBar(
              attachments: _attachments,
              onRemove: (index) {
                setState(() => _attachments.removeAt(index));
              },
            ),
          AnimatedSize(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            alignment: Alignment.bottomCenter,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_showAttachmentPanel)
                  ChatAttachmentSheet(
                    onGallery: () {
                      unawaited(_handleGalleryTap());
                    },
                    onCamera: () {
                      unawaited(_handleCameraTap());
                    },
                    onDocument: () {
                      unawaited(_handleDocumentTap());
                    },
                    onLocation: () {
                      unawaited(_handleLocationTap());
                    },
                    onContact: () {
                      unawaited(_handleContactTap());
                    },
                  ),
                if (_showEmojiPanel)
                  ChatEmojiPanel(
                    onEmojiSelected: _insertEmoji,
                    onClose: _toggleEmojiPanel,
                  ),
                _buildInputRow(colors, inputDecorationTheme),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
