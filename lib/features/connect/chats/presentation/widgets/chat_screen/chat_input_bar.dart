import 'dart:async';
import 'dart:io';

import 'package:africaonlinestores/core/theme/app_color_tokens.dart';
import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:africaonlinestores/core/utils/logger.dart';
import 'package:africaonlinestores/features/connect/chats/application/controllers/chat_local_preferences_controller.dart';
import 'package:africaonlinestores/features/connect/chats/domain/helpers/chat_input_controller.dart';
import 'package:africaonlinestores/features/connect/chats/domain/helpers/chat_pending_attachment.dart';
import 'package:africaonlinestores/features/connect/chats/presentation/widgets/chat_screen/chat_input/attachment_preview.dart';
import 'package:africaonlinestores/features/connect/chats/presentation/widgets/chat_screen/chat_input/chat_attachment_sheet.dart';
import 'package:africaonlinestores/features/connect/chats/presentation/widgets/chat_screen/chat_input/chat_emoji_panel.dart';
import 'package:africaonlinestores/features/connect/chats/presentation/widgets/chat_screen/chat_input/chat_input_attachment_helper.dart';
import 'package:africaonlinestores/features/connect/chats/presentation/widgets/chat_screen/chat_input/input_icon_button.dart';
import 'package:africaonlinestores/features/connect/chats/presentation/widgets/chat_screen/chat_input/voice_record_button.dart';
import 'package:africaonlinestores/features/connect/voice/voice_record_overlay.dart';
import 'package:africaonlinestores/features/connect/voice/voice_record_provider.dart';
import 'package:africaonlinestores/features/connect/voice/voice_record_state.dart';
import 'package:africaonlinestores/l10n/gen/app_localizations.dart';
import 'package:africaonlinestores/shared/widgets/app_snack.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
  final Future<bool> Function({
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
  final Map<String, ChatInputAttachment> _uploadedAttachmentsByPath = {};

  late final AppLifecycleListener _voiceLifecycleListener;

  bool _isSending = false;
  bool _isFinalizingVoice = false;
  bool _showAttachmentPanel = false;
  bool _showEmojiPanel = false;

  bool get _hasText => widget.controller.text.trim().isNotEmpty;
  bool get _hasAttachments => _attachments.isNotEmpty;
  bool get _hasAdContext =>
      widget.adId != null && widget.adId!.trim().isNotEmpty;

  bool get _canSend => _hasText || _hasAttachments || _hasAdContext;

  @override
  void initState() {
    super.initState();
    _voiceLifecycleListener = AppLifecycleListener(
      onInactive: _cancelVoiceForLifecycle,
      onPause: _cancelVoiceForLifecycle,
      onDetach: _cancelVoiceForLifecycle,
    );
  }

  void _cancelVoiceForLifecycle() {
    final state = ref.read(voiceRecordControllerProvider);
    if (!state.isActive) return;
    unawaited(
      ref.read(voiceRecordControllerProvider.notifier).cancelRecording(),
    );
  }

  @override
  void dispose() {
    for (final attachment in _attachments) {
      unawaited(_deleteTemporaryAttachment(attachment));
    }
    _uploadedAttachmentsByPath.clear();
    _voiceLifecycleListener.dispose();
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
        final cached = _uploadedAttachmentsByPath[pending.path];
        final uploaded =
            cached ??
            await ChatInputAttachmentHelper.uploadPendingAttachment(
              ref,
              pending,
            );

        if (uploaded == null) {
          throw const ChatAttachmentUploadException(
            'Attachment upload failed.',
          );
        }

        _uploadedAttachmentsByPath[pending.path] = uploaded;
        uploadedAttachments.add(uploaded);
      }

      if (!mounted) return;

      final sent = await widget.onSend(
        text: text.isNotEmpty ? text : null,
        attachments: uploadedAttachments,
      );
      if (!mounted) return;
      if (!sent) {
        setState(() {
          _attachments
            ..clear()
            ..addAll(pendingAttachments);
        });
        return;
      }

      for (final pending in pendingAttachments) {
        _uploadedAttachmentsByPath.remove(pending.path);
        unawaited(_deleteTemporaryAttachment(pending));
      }
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

      ShowSnack(
        context,
        AppLocalizations.of(context).chat_attachment_upload_failed,
      ).error();
      return;
    } finally {
      if (!mounted) {
        for (final pending in pendingAttachments) {
          await _deleteTemporaryAttachment(pending);
        }
      } else {
        setState(() => _isSending = false);
      }
    }
  }

  Future<void> _pickGallery() async {
    final attachments = await ChatInputAttachmentHelper.pickImagesOnly(ref);
    if (attachments.isEmpty) return;
    if (!mounted) {
      for (final attachment in attachments) {
        await _deleteTemporaryAttachment(attachment);
      }
      return;
    }

    setState(() => _attachments.addAll(attachments));
  }

  Future<void> _pickCameraImage() async {
    final attachment = await ChatInputAttachmentHelper.pickCameraImageOnly(
      ref,
      context,
    );
    if (attachment == null) return;
    if (!mounted) {
      await _deleteTemporaryAttachment(attachment);
      return;
    }

    setState(() => _attachments.add(attachment));
  }

  Future<void> _pickDocument() async {
    final attachment = await ChatInputAttachmentHelper.pickDocumentOnly(ref);
    if (attachment == null) return;
    if (!mounted) {
      await _deleteTemporaryAttachment(attachment);
      return;
    }

    setState(() => _attachments.add(attachment));
  }

  Future<void> _pickAudio() async {
    final attachment = await ChatInputAttachmentHelper.pickAudioOnly(ref);
    if (attachment == null) return;
    if (!mounted) {
      await _deleteTemporaryAttachment(attachment);
      return;
    }

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

  Future<void> _handleAudioTap() async {
    _closePanels();
    await _pickAudio();
  }

  String _formatVoiceDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString();
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  Future<void> _startVoiceRecording() async {
    if (_isSending || _isFinalizingVoice) return;
    FocusScope.of(context).unfocus();
    _closePanels();
    await ref.read(voiceRecordControllerProvider.notifier).startRecording();
  }

  Future<void> _toggleVoicePause() async {
    final controller = ref.read(voiceRecordControllerProvider.notifier);
    final state = ref.read(voiceRecordControllerProvider);
    if (state.isPaused) {
      await controller.resumeRecording();
      return;
    }
    await controller.pauseRecording();
  }

  Future<void> _cancelVoiceRecording() async {
    if (_isFinalizingVoice) return;
    await ref.read(voiceRecordControllerProvider.notifier).cancelRecording();
  }

  Future<void> _sendVoiceRecording() async {
    if (_isSending || _isFinalizingVoice) return;

    setState(() => _isFinalizingVoice = true);
    final path = await ref
        .read(voiceRecordControllerProvider.notifier)
        .finishRecording();
    if (!mounted) return;
    setState(() => _isFinalizingVoice = false);
    if (path == null) return;
    await _handleVoiceRecorded(path);
  }

  String _voiceErrorMessage(AppLocalizations l10n, VoiceRecordError error) {
    return switch (error) {
      VoiceRecordError.microphonePermissionDenied =>
        l10n.chat_microphone_permission_denied,
      VoiceRecordError.startFailed => l10n.chat_voice_record_start_failed,
      VoiceRecordError.finishFailed => l10n.chat_voice_record_finish_failed,
    };
  }

  Future<void> _handleVoiceRecorded(String path) async {
    if (_isSending) return;

    final file = File(path);
    final fileExists = file.existsSync();
    if (!fileExists) return;

    if (!mounted) return;

    setState(() {
      _attachments.add(ChatPendingAttachment(file: file, type: 'audio'));
    });

    await _submit();
  }

  Future<void> _deleteTemporaryAttachment(
    ChatPendingAttachment attachment,
  ) async {
    final filename = attachment.file.path.split(Platform.pathSeparator).last;
    final isTemporaryVoice =
        attachment.type == 'audio' && filename.startsWith('voice_');
    if (!attachment.deleteAfterUse && !isTemporaryVoice) return;

    try {
      // ignore: avoid_slow_async_io
      if (await attachment.file.exists()) {
        await attachment.file.delete();
      }
    } catch (error, stackTrace) {
      appLogger.w(
        'Temporary chat attachment cleanup failed.',
        error: error,
        stackTrace: stackTrace,
      );
    }
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
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 6, 10, 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Container(
              constraints: const BoxConstraints(minHeight: 48),
              padding: const EdgeInsets.only(left: 6, right: 4),
              decoration: BoxDecoration(
                color: colors.elevated,
                borderRadius: BorderRadius.circular(24),
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
                        hintText: l10n.chat_message_hint,
                        isDense: true,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 12,
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
          const SizedBox(width: 8),
          if (_canSend)
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _isSending
                  ? null
                  : () {
                      unawaited(_submit());
                    },
              child: Container(
                width: 48,
                height: 48,
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
                      : Icon(Icons.send_rounded, color: colors.white, size: 22),
                ),
              ),
            )
          else
            VoiceRecordButton(
              disabled: _isSending || _isFinalizingVoice,
              onStart: _startVoiceRecording,
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final inputDecorationTheme = Theme.of(context).inputDecorationTheme;
    final voiceState = ref.watch(voiceRecordControllerProvider);

    ref.listen<VoiceRecordError?>(
      voiceRecordControllerProvider.select((value) => value.error),
      (previous, next) {
        if (next == null || next == previous || !mounted) return;
        ShowSnack(
          context,
          _voiceErrorMessage(AppLocalizations.of(context), next),
        ).error();
      },
    );

    return ColoredBox(
      color: colors.surface,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_attachments.isNotEmpty)
            AttachmentPreviewBar(
              attachments: _attachments,
              onRemove: (index) {
                final removed = _attachments[index];
                _uploadedAttachmentsByPath.remove(removed.path);
                setState(() => _attachments.removeAt(index));
                unawaited(_deleteTemporaryAttachment(removed));
              },
            ),
          AnimatedSize(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            alignment: Alignment.bottomCenter,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (voiceState.isActive)
                  VoiceRecordOverlay(
                    durationText: _formatVoiceDuration(voiceState.duration),
                    amplitudes: voiceState.amplitudes,
                    isPaused: voiceState.isPaused,
                    isSending: _isFinalizingVoice,
                    onDelete: () {
                      unawaited(_cancelVoiceRecording());
                    },
                    onTogglePause: () {
                      unawaited(_toggleVoicePause());
                    },
                    onSend: () {
                      unawaited(_sendVoiceRecording());
                    },
                  )
                else ...[
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
                      onAudio: () {
                        unawaited(_handleAudioTap());
                      },
                    ),
                  if (_showEmojiPanel)
                    ChatEmojiPanel(
                      onEmojiSelected: _insertEmoji,
                      onClose: _toggleEmojiPanel,
                    ),
                  _buildInputRow(colors, inputDecorationTheme),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
