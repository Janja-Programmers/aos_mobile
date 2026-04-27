import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';

import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';

import 'package:africaonlinestores/core/utils/logger.dart';

import 'package:africaonlinestores/features/ads/shared/utils/file_url.dart';
import 'package:africaonlinestores/features/connect/chats/domain/helpers/chat_input_controller.dart';
import 'package:africaonlinestores/features/connect/chats/presentation/widgets/chat_screen/chat_attachment_sheet.dart';
import 'package:africaonlinestores/features/connect/chats/presentation/widgets/chat_screen/chat_input_attachment_helper.dart';

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

  final List<ChatInputAttachment> _attachments = [];

  bool get _hasText => widget.controller.text.trim().isNotEmpty;
  bool get _hasAttachments => _attachments.isNotEmpty;
  bool get _hasAdContext =>
      widget.adId != null && widget.adId!.trim().isNotEmpty;

  // -------------------------
  // SEND
  // -------------------------
  Future<void> _submit() async {
    if (_isSending) return;

    final text = widget.controller.text.trim();

    final hasText = text.isNotEmpty;
    final hasAttachments = _attachments.isNotEmpty;
    final hasAdContext = widget.adId != null && widget.adId!.trim().isNotEmpty;

    if (!hasText && !hasAttachments && !hasAdContext) return;

    setState(() => _isSending = true);

    try {
      await widget.onSend(
        text: hasText ? text : null,
        attachments: List.of(_attachments),
      );

      widget.controller.clear();
      _attachments.clear();
      widget.onTyping(false);

      setState(() {});
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }

  // -------------------------
  // PICK Image
  // -------------------------
  Future<void> _pickImage() async {
    final attachment = await ChatInputAttachmentHelper.pickAndUploadImage(
      ref,
      context,
    );

    if (attachment == null) return;

    setState(() {
      _attachments.add(attachment);
    });
  }

  // -------------------------
  // PICK Video
  // -------------------------
  Future<void> _pickVideo() async {
    final attachment = await ChatInputAttachmentHelper.pickAndUploadVideo(
      ref,
      context,
    );

    if (attachment == null) return;

    setState(() {
      _attachments.add(attachment);
    });
  }

  // -------------------------
  // PICK DOCUMENT
  // -------------------------
  Future<void> _pickDocument() async {
    final attachment = await ChatInputAttachmentHelper.pickAndUploadDocument(
      ref,
    );

    if (attachment == null) return;

    setState(() {
      _attachments.add(attachment);
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final inputDecorationTheme = Theme.of(context).inputDecorationTheme;

    return Container(
      color: colors.surface,
      child: Column(
        children: [
          // -------------------------
          // ATTACHMENT PREVIEW
          // -------------------------
          if (_attachments.isNotEmpty)
            SizedBox(
              height: 70,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _attachments.length,
                itemBuilder: (_, i) {
                  final a = _attachments[i];
                  final previewUrl = buildFileUrl(a.previewUrl) ?? '';
                  appLogger.i("Fileid: $previewUrl");

                  return Stack(
                    children: [
                      Container(
                        margin: const EdgeInsets.all(6),
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.grey.shade200,
                        ),
                        child: a.type == 'image'
                            ? Image.network(previewUrl, fit: BoxFit.cover)
                            : const Icon(Icons.insert_drive_file),
                      ),
                      Positioned(
                        right: 0,
                        top: 0,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _attachments.removeAt(i);
                            });
                          },
                          child: const CircleAvatar(
                            radius: 10,
                            child: Icon(Icons.close, size: 12),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

          // -------------------------
          // INPUT ROW
          // -------------------------
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.attach_file),
                  onPressed: () async {
                    await showModalBottomSheet(
                      context: context,
                      backgroundColor: colors.surface,
                      builder: (_) => ChatAttachmentSheet(
                        onImage: () {
                          Navigator.pop(context);
                          _pickImage();
                        },
                        onDocument: () {
                          Navigator.pop(context);
                          _pickDocument();
                        },
                        onVideo: () {
                          Navigator.pop(context);
                          _pickVideo();
                        },
                      ),
                    );
                  },
                ),

                Expanded(
                  child: TextField(
                    controller: widget.controller,
                    minLines: 1,
                    maxLines: 5,
                    onChanged: (text) {
                      widget.onTyping(text.trim().isNotEmpty);
                      setState(() {}); // update send/mic toggle
                    },
                    decoration: const InputDecoration(
                      hintText: "Type a message...",
                      border: InputBorder.none,
                    ).applyDefaults(inputDecorationTheme),
                  ),
                ),

                // SEND / UPLOADING / MIC
                SizedBox(
                  height: 40,
                  width: 40,
                  child: Center(
                    child: _isSending
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : IconButton(
                            icon: Icon(
                              Icons.send,
                              color:
                                  (_hasText || _hasAttachments || _hasAdContext)
                                  ? colors.chatCardColor
                                  : colors.textSecondary.withOpacity(0.4),
                            ),
                            onPressed:
                                (_isSending ||
                                    (!_hasText &&
                                        !_hasAttachments &&
                                        !_hasAdContext))
                                ? null
                                : _submit,
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
