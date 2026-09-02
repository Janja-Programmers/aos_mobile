import 'dart:async';

import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:africaonlinestores/features/connect/chats/domain/chat_conversation.dart';
import 'package:africaonlinestores/features/connect/conversations/application/providers/conversation_provider.dart';
import 'package:africaonlinestores/features/shorts/feeds/presentation/widgets/overlays/report_short_sheet.dart';
import 'package:africaonlinestores/features/shorts/shared/application/providers/shorts_providers.dart';
import 'package:africaonlinestores/features/shorts/shared/domain/entities/short.dart';
import 'package:africaonlinestores/shared/components/verified_badge.dart';
import 'package:africaonlinestores/shared/images/app_image_decode.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';

/// AOS-owned Short sharing surface.
///
/// This intentionally does not invoke SharePlus. The current Short remains
/// visible behind the route barrier while the user chooses an AOS chat or an
/// explicit external destination.
Future<void> showShortShareSheet({
  required BuildContext context,
  required Short short,
  required Future<void> Function() onRepost,
  required Future<void> Function() onDownload,
  required Future<String?> Function({
    required String shortId,
    required String reason,
    required String details,
  })
  onReport,
}) {
  return showModalBottomSheet<void>(
    context: context,
    useRootNavigator: true,
    useSafeArea: true,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: .46),
    builder: (sheetContext) => _ShortShareSheet(
      short: short,
      onRepost: onRepost,
      onDownload: onDownload,
      onReport: onReport,
    ),
  );
}

class _ShortShareSheet extends ConsumerStatefulWidget {
  const _ShortShareSheet({
    required this.short,
    required this.onRepost,
    required this.onDownload,
    required this.onReport,
  });

  final Short short;
  final Future<void> Function() onRepost;
  final Future<void> Function() onDownload;
  final Future<String?> Function({
    required String shortId,
    required String reason,
    required String details,
  })
  onReport;

  @override
  ConsumerState<_ShortShareSheet> createState() => _ShortShareSheetState();
}

class _ShortShareSheetState extends ConsumerState<_ShortShareSheet> {
  final TextEditingController _messageController = TextEditingController();
  final Set<String> _selectedConversationIds = <String>{};
  late final String _shareSessionId;

  bool _isSending = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _shareSessionId = 'short_share_${const Uuid().v4()}';
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final conversations = ref.watch(conversationsControllerProvider);
    final size = MediaQuery.sizeOf(context);
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 620,
            maxHeight: size.height * .84,
          ),
          child: Material(
            color: colors.surface,
            elevation: 18,
            shadowColor: Colors.black54,
            borderRadius: BorderRadius.circular(26),
            clipBehavior: Clip.antiAlias,
            child: SafeArea(
              top: false,
              child: SingleChildScrollView(
                padding: EdgeInsets.only(bottom: bottomInset),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
                      child: Text('Share to', style: context.h6),
                    ),
                    Divider(height: 1, color: colors.border),
                    _shortPreview(context),
                    Divider(height: 1, color: colors.border),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(18, 14, 18, 8),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              'Send to chats',
                              style: context.pStrong,
                            ),
                          ),
                          if (_selectedConversationIds.isNotEmpty)
                            Text(
                              '${_selectedConversationIds.length} selected',
                              style: context.small.copyWith(
                                color: colors.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                        ],
                      ),
                    ),
                    _conversationPicker(conversations),
                    if (_selectedConversationIds.isNotEmpty) ...<Widget>[
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
                        child: TextField(
                          controller: _messageController,
                          enabled: !_isSending,
                          minLines: 1,
                          maxLines: 3,
                          maxLength: 500,
                          decoration: InputDecoration(
                            hintText: 'Add a message (optional)',
                            counterText: '',
                            isDense: true,
                            filled: true,
                            fillColor: colors.elevated,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide(color: colors.border),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide(color: colors.border),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
                        child: SizedBox(
                          height: 44,
                          child: FilledButton.icon(
                            onPressed: _isSending ? null : _sendToChats,
                            icon: _isSending
                                ? const SizedBox.square(
                                    dimension: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(Icons.send_rounded, size: 18),
                            label: Text(
                              _isSending ? 'Sending…' : 'Send',
                              style: AppTextStylesX(
                                context,
                              ).button.copyWith(color: colors.white),
                            ),
                          ),
                        ),
                      ),
                    ],
                    if (_errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(18, 0, 18, 10),
                        child: Semantics(
                          liveRegion: true,
                          child: Text(
                            _errorMessage!,
                            style: context.small.copyWith(color: colors.error),
                          ),
                        ),
                      ),
                    Divider(height: 1, color: colors.border),
                    IgnorePointer(
                      ignoring: _isSending,
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 160),
                        opacity: _isSending ? .55 : 1,
                        child: SizedBox(
                          height: 106,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                            children: <Widget>[
                              if (widget.short.canRepost ||
                                  widget.short.isReposted)
                                _ShareAction(
                                  icon: Icons.repeat_rounded,
                                  label: widget.short.isReposted
                                      ? 'Reposted'
                                      : 'Repost',
                                  backgroundColor: const Color(0xFFFFB300),
                                  iconColor: Colors.white,
                                  onTap: _runRepost,
                                ),
                              if (widget.short.canReport)
                                _ShareAction(
                                  icon: Icons.flag_outlined,
                                  label: 'Report',
                                  iconColor: colors.error,
                                  onTap: _openReport,
                                ),
                              if (widget.short.allowDownloads ||
                                  widget.short.isOwner)
                                _ShareAction(
                                  icon: Icons.download_rounded,
                                  label: 'Save video',
                                  onTap: _runDownload,
                                ),
                              _ShareAction(
                                brandIcon: const FaIcon(
                                  FontAwesomeIcons.whatsapp,
                                  size: 22,
                                  color: Colors.white,
                                ),
                                label: 'WhatsApp',
                                backgroundColor: const Color(0xFF25D366),
                                onTap: () =>
                                    _shareExternal(_ExternalTarget.whatsapp),
                              ),
                              _ShareAction(
                                brandIcon: const FaIcon(
                                  FontAwesomeIcons.facebookF,
                                  size: 21,
                                  color: Colors.white,
                                ),
                                label: 'Facebook',
                                backgroundColor: const Color(0xFF1877F2),
                                onTap: () =>
                                    _shareExternal(_ExternalTarget.facebook),
                              ),
                              _ShareAction(
                                brandIcon: const FaIcon(
                                  FontAwesomeIcons.xTwitter,
                                  size: 20,
                                  color: Colors.white,
                                ),
                                label: 'X',
                                backgroundColor: Colors.black,
                                borderColor: const Color(0xFF4A4A4A),
                                onTap: () => _shareExternal(_ExternalTarget.x),
                              ),
                              _ShareAction(
                                brandIcon: const _GmailBrandMark(),
                                label: 'Gmail',
                                backgroundColor: Colors.white,
                                borderColor: const Color(0xFFE2E2E2),
                                onTap: () =>
                                    _shareExternal(_ExternalTarget.email),
                              ),
                              _ShareAction(
                                icon: Icons.link_rounded,
                                label: 'Copy link',
                                onTap: () =>
                                    _shareExternal(_ExternalTarget.copyLink),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(14, 2, 14, 14),
                      child: SizedBox(
                        height: 44,
                        child: FilledButton.tonal(
                          onPressed: _isSending
                              ? null
                              : () => Navigator.pop(context),
                          child: Text(
                            'Cancel',
                            style: AppTextStylesX(
                              context,
                            ).button.copyWith(color: colors.white),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _shortPreview(BuildContext context) {
    final colors = context.appColors;
    final thumbnail = widget.short.thumbnailUrl?.trim();
    final creator = widget.short.creator.displayName.trim().isNotEmpty
        ? widget.short.creator.displayName.trim()
        : widget.short.creator.user.trim();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: <Widget>[
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              width: 48,
              height: 64,
              child: thumbnail != null && thumbnail.isNotEmpty
                  ? Image(
                      image: AppImageDecode.networkProvider(
                        context,
                        thumbnail,
                        logicalWidth: 48,
                        logicalHeight: 64,
                      ),
                      fit: BoxFit.cover,
                      errorBuilder: (imageContext, error, stackTrace) =>
                          _previewFallback(imageContext),
                    )
                  : _previewFallback(context),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('AOS Short', style: context.pStrong),
                const SizedBox(height: 4),
                Row(
                  children: <Widget>[
                    Flexible(
                      child: Text(
                        creator.isEmpty ? 'AOS creator' : creator,
                        style: context.small.copyWith(color: colors.textMuted),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (widget.short.isCreatorVerified) ...<Widget>[
                      const SizedBox(width: 4),
                      const VerifiedBadge(size: 14),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _previewFallback(BuildContext context) {
    final colors = context.appColors;
    return ColoredBox(
      color: colors.elevated,
      child: Icon(
        Icons.play_arrow_rounded,
        color: colors.textSecondary,
        size: 26,
      ),
    );
  }

  Widget _conversationPicker(AsyncValue<List<ChatConversation>> state) {
    return state.when(
      loading: () => const SizedBox(
        height: 88,
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      ),
      error: (error, stackTrace) => Padding(
        padding: const EdgeInsets.fromLTRB(18, 4, 18, 12),
        child: Row(
          children: <Widget>[
            const Expanded(child: Text('Chats could not be loaded.')),
            TextButton(
              onPressed: () => unawaited(
                ref.read(conversationsControllerProvider.notifier).load(),
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
      data: (items) {
        final recent = items
            .where((conversation) => conversation.id.trim().isNotEmpty)
            .take(12)
            .toList(growable: false);

        if (recent.isEmpty) {
          return const Padding(
            padding: EdgeInsets.fromLTRB(18, 4, 18, 14),
            child: Text('No recent chats yet.'),
          );
        }

        return SizedBox(
          height: 90,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            itemCount: recent.length,
            separatorBuilder: (context, index) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final conversation = recent[index];
              final selected = _selectedConversationIds.contains(
                conversation.id,
              );
              return _ConversationChoice(
                conversation: conversation,
                selected: selected,
                onTap: _isSending
                    ? null
                    : () {
                        setState(() {
                          if (selected) {
                            _selectedConversationIds.remove(conversation.id);
                          } else {
                            _selectedConversationIds.add(conversation.id);
                          }
                          _errorMessage = null;
                        });
                      },
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _sendToChats() async {
    if (_selectedConversationIds.isEmpty || _isSending) return;

    setState(() {
      _isSending = true;
      _errorMessage = null;
    });

    final api = ref.read(shortsShareApiProvider);
    final note = _messageController.text.trim();
    final failed = <String>[];

    for (final conversationId in _selectedConversationIds) {
      final result = await api.shareToChat(
        shortId: widget.short.id.value,
        conversationId: conversationId,
        message: note,
        eventId: const Uuid().v4(),
      );
      if (result.isLeft) failed.add(conversationId);
    }

    if (!mounted) return;

    if (failed.isEmpty) {
      final messenger = ScaffoldMessenger.of(context);
      Navigator.pop(context);
      messenger.showSnackBar(const SnackBar(content: Text('Short sent.')));
      return;
    }

    setState(() {
      _isSending = false;
      _errorMessage = failed.length == _selectedConversationIds.length
          ? 'The Short could not be sent. Try again.'
          : 'Sent to some chats. Retry the remaining chats.';
      _selectedConversationIds
        ..clear()
        ..addAll(failed);
    });
  }

  Future<void> _shareExternal(_ExternalTarget target) async {
    if (_isSending) return;

    setState(() {
      _isSending = true;
      _errorMessage = null;
    });

    final api = ref.read(shortsShareApiProvider);
    final result = await api.createShareLink(
      shortId: widget.short.id.value,
      channel: target.backendChannel,
      sessionId: _shareSessionId,
    );

    if (!mounted) return;

    if (result.isLeft) {
      setState(() {
        _isSending = false;
        _errorMessage =
            result.leftOrNull?.message ?? 'Unable to share this Short.';
      });
      return;
    }

    final url = result.rightOrNull!.shareUrl.trim();
    final text = _shareText(url);

    if (target == _ExternalTarget.copyLink) {
      await Clipboard.setData(ClipboardData(text: url));
      if (!mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      Navigator.pop(context);
      messenger.showSnackBar(const SnackBar(content: Text('Link copied.')));
      return;
    }

    final uri = target.uri(url: url, text: text);
    try {
      final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!mounted) return;
      if (!opened) {
        setState(() {
          _isSending = false;
          _errorMessage = 'No compatible app could be opened.';
        });
        return;
      }
      Navigator.pop(context);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isSending = false;
        _errorMessage = 'No compatible app could be opened.';
      });
    }
  }

  String _shareText(String url) {
    final caption = widget.short.caption.value.trim();
    if (caption.isEmpty) return 'Check out this AOS Short: $url';
    return '$caption\n$url';
  }

  Future<void> _runRepost() async {
    Navigator.pop(context);
    await widget.onRepost();
  }

  Future<void> _runDownload() async {
    Navigator.pop(context);
    await widget.onDownload();
  }

  void _openReport() {
    final navigator = Navigator.of(context);
    final hostContext = navigator.context;
    navigator.pop();
    Future<void>.microtask(() {
      if (!hostContext.mounted) return;
      unawaited(
        showReportShortSheet(
          context: hostContext,
          shortId: widget.short.id.value,
          onSubmit: widget.onReport,
        ),
      );
    });
  }
}

class _ConversationChoice extends StatelessWidget {
  const _ConversationChoice({
    required this.conversation,
    required this.selected,
    required this.onTap,
  });

  final ChatConversation conversation;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final avatar = conversation.avatar?.trim();
    final name = conversation.displayName.trim().isNotEmpty
        ? conversation.displayName.trim()
        : conversation.user.trim();

    return SizedBox(
      width: 62,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          children: <Widget>[
            Stack(
              children: <Widget>[
                CircleAvatar(
                  radius: 24,
                  backgroundColor: colors.elevated,
                  backgroundImage: avatar != null && avatar.isNotEmpty
                      ? AppImageDecode.networkProvider(
                          context,
                          avatar,
                          logicalWidth: 48,
                          logicalHeight: 48,
                        )
                      : null,
                  child: avatar == null || avatar.isEmpty
                      ? Text(
                          name.isEmpty
                              ? '?'
                              : name.characters.first.toUpperCase(),
                          style: context.pStrong,
                        )
                      : null,
                ),
                if (selected)
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: colors.primary.withValues(alpha: .76),
                      ),
                      child: Icon(Icons.check_rounded, color: colors.white),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 5),
            Text(
              name.isEmpty ? 'Chat' : name,
              style: context.small.copyWith(fontSize: 10.5),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ShareAction extends StatelessWidget {
  const _ShareAction({
    required this.label,
    required this.onTap,
    this.icon,
    this.brandIcon,
    this.backgroundColor,
    this.iconColor,
    this.borderColor,
    // ignore: prefer_asserts_with_message
  }) : assert(icon != null || brandIcon != null);

  final IconData? icon;
  final Widget? brandIcon;
  final String label;
  final VoidCallback onTap;
  final Color? backgroundColor;
  final Color? iconColor;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final actionBorderColor = borderColor;

    return SizedBox(
      width: 70,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          children: <Widget>[
            DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: backgroundColor ?? colors.elevated,
                border: actionBorderColor == null
                    ? null
                    : Border.all(color: actionBorderColor),
              ),
              child: SizedBox.square(
                dimension: 44,
                child: Center(
                  child:
                      brandIcon ??
                      Icon(
                        icon,
                        size: 21,
                        color: iconColor ?? colors.textPrimary,
                      ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: context.small.copyWith(
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 2,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _GmailBrandMark extends StatelessWidget {
  const _GmailBrandMark();

  @override
  Widget build(BuildContext context) {
    return SvgPicture.string(
      _gmailBrandSvg,
      width: 27,
      height: 20,
      semanticsLabel: 'Gmail',
    );
  }
}

const String _gmailBrandSvg = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 28 21">
  <path fill="#4285F4" d="M2 4.6v13.1c0 .9.7 1.6 1.6 1.6H6V8.2L2 5.1z"/>
  <path fill="#34A853" d="M22 8.2v11.1h2.4c.9 0 1.6-.7 1.6-1.6V4.6l-4 3.6z"/>
  <path fill="#EA4335" d="M2.9 3.1A1.6 1.6 0 0 1 5 2.9L14 9.5l9-6.6a1.6 1.6 0 0 1 2.1.2l.9 1.1L14 13 2 4.2z"/>
  <path fill="#C5221F" d="M2 4.6 6 7.5v3.6L2 8.2z"/>
  <path fill="#FBBC04" d="M22 7.5 26 4.6v3.6l-4 2.9z"/>
</svg>
''';

enum _ExternalTarget { whatsapp, facebook, x, email, copyLink }

extension on _ExternalTarget {
  String get backendChannel {
    switch (this) {
      case _ExternalTarget.whatsapp:
        return 'whatsapp';
      case _ExternalTarget.facebook:
        return 'facebook';
      case _ExternalTarget.x:
      case _ExternalTarget.email:
        return 'system_share';
      case _ExternalTarget.copyLink:
        return 'copy_link';
    }
  }

  Uri uri({required String url, required String text}) {
    switch (this) {
      case _ExternalTarget.whatsapp:
        return Uri.https('wa.me', '/', <String, String>{'text': text});
      case _ExternalTarget.facebook:
        return Uri.https(
          'www.facebook.com',
          '/sharer/sharer.php',
          <String, String>{'u': url},
        );
      case _ExternalTarget.x:
        return Uri.https('x.com', '/intent/post', <String, String>{
          'text': text,
        });
      case _ExternalTarget.email:
        return Uri(
          scheme: 'mailto',
          queryParameters: <String, String>{
            'subject': 'AOS Short',
            'body': text,
          },
        );
      case _ExternalTarget.copyLink:
        return Uri.parse(url);
    }
  }
}
