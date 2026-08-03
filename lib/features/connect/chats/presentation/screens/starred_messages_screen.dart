import 'dart:async';

import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:africaonlinestores/features/account/shared/providers/account_user_provider.dart';
import 'package:africaonlinestores/features/connect/chats/domain/chat_identity.dart';
import 'package:africaonlinestores/features/connect/chats/domain/chat_message.dart';
import 'package:africaonlinestores/features/connect/chats/repository/chat_repository_impl.dart';
import 'package:africaonlinestores/l10n/gen/app_localizations.dart';
import 'package:africaonlinestores/shared/utils/format_time.dart';
import 'package:africaonlinestores/shared/widgets/app_snack.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StarredMessagesScreen extends ConsumerStatefulWidget {
  const StarredMessagesScreen({super.key});

  @override
  ConsumerState<StarredMessagesScreen> createState() =>
      _StarredMessagesScreenState();
}

class _StarredMessagesScreenState
    extends ConsumerState<StarredMessagesScreen> {
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = <ChatMessage>[];
  final Set<String> _unstarInFlight = <String>{};
  ProviderSubscription<String?>? _accountSubscription;
  String _activeAccountId = '';
  int _accountGeneration = 0;
  bool _accountInitialized = false;
  bool _loading = true;
  bool _loadingMore = false;
  bool _hasMore = true;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _accountSubscription = ref.listenManual<String?>(
      currentCanonicalAccountIdProvider,
      _handleAccountChanged,
      fireImmediately: true,
    );
  }

  void _handleAccountChanged(String? previous, String? next) {
    final accountId = normalizeCanonicalUserId(next);
    if (_accountInitialized && accountId == _activeAccountId) return;

    _accountInitialized = true;
    _activeAccountId = accountId;
    ++_accountGeneration;
    _messages.clear();
    _unstarInFlight.clear();
    _error = null;
    _hasMore = accountId.isNotEmpty;
    _loadingMore = false;
    _loading = accountId.isNotEmpty;

    if (mounted) setState(() {});
    if (accountId.isNotEmpty) {
      unawaited(_load(reset: true));
    }
  }

  void _onScroll() {
    if (!_scrollController.hasClients || _loadingMore || !_hasMore) return;
    if (_scrollController.position.pixels <
        _scrollController.position.maxScrollExtent - 240) {
      return;
    }
    unawaited(_load(reset: false));
  }

  Future<void> _load({required bool reset}) async {
    final accountId = _activeAccountId;
    final generation = _accountGeneration;
    if (accountId.isEmpty) return;

    if (reset) {
      setState(() {
        _loading = true;
        _error = null;
        _hasMore = true;
      });
    } else {
      if (_loadingMore || !_hasMore) return;
      setState(() => _loadingMore = true);
    }

    final result = await ref.read(chatRepositoryProvider).listStarredMessages(
      before: reset || _messages.isEmpty ? null : _messages.last.id,
    );

    if (!mounted ||
        generation != _accountGeneration ||
        accountId != _activeAccountId) {
      return;
    }
    if (result.isLeft) {
      setState(() {
        _loading = false;
        _loadingMore = false;
        _error = result.leftOrNull;
      });
      return;
    }

    final page = result.rightOrNull ?? const <ChatMessage>[];
    final byId = <String, ChatMessage>{
      if (!reset) for (final message in _messages) message.id: message,
      for (final message in page) message.id: message,
    };

    setState(() {
      _messages
        ..clear()
        ..addAll(byId.values);
      _loading = false;
      _loadingMore = false;
      _hasMore = page.length >= 30;
      _error = null;
    });
  }

  Future<void> _unstar(ChatMessage message) async {
    final accountId = _activeAccountId;
    final generation = _accountGeneration;
    if (accountId.isEmpty || _unstarInFlight.contains(message.id)) return;
    setState(() => _unstarInFlight.add(message.id));

    final result = await ref
        .read(chatRepositoryProvider)
        .toggleMessageStar(message.id);
    if (!mounted ||
        generation != _accountGeneration ||
        accountId != _activeAccountId) {
      return;
    }

    setState(() => _unstarInFlight.remove(message.id));
    final l10n = AppLocalizations.of(context);
    if (result.isLeft || (result.rightOrNull ?? true)) {
      ShowSnack(context, l10n.chat_unstar_failed).error();
      return;
    }

    setState(() => _messages.removeWhere((item) => item.id == message.id));
    ShowSnack(context, l10n.chat_message_unstarred).success();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final l10n = AppLocalizations.of(context);
    final currentUserId = ref.watch(currentCanonicalAccountIdProvider);

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        backgroundColor: colors.surface,
        surfaceTintColor: Colors.transparent,
        title: Text(l10n.chat_starred_messages),
      ),
      body: SafeArea(
        child: Builder(
          builder: (context) {
            if (_loading && _messages.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }
            if (_error != null && _messages.isEmpty) {
              return _StateMessage(
                icon: Icons.cloud_off_rounded,
                title: l10n.chat_starred_load_failed,
                actionLabel: l10n.chat_retry,
                onAction: () => _load(reset: true),
              );
            }
            if (_messages.isEmpty) {
              return _StateMessage(
                icon: Icons.star_border_rounded,
                title: l10n.chat_no_starred_messages,
                message: l10n.chat_no_starred_messages_hint,
              );
            }

            return RefreshIndicator(
              onRefresh: () => _load(reset: true),
              child: ListView.separated(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                itemCount: _messages.length + (_loadingMore ? 1 : 0),
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  if (index >= _messages.length) {
                    return const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  final message = _messages[index];
                  final mine = isMessageOwnedBy(
                    message: message,
                    authenticatedCanonicalId: currentUserId,
                  );
                  final sender = mine
                      ? l10n.chat_you
                      : message.senderDisplayName ?? message.senderCanonicalId;

                  return Semantics(
                    label: l10n.chat_starred_message_from(sender),
                    child: Material(
                      color: colors.elevated,
                      borderRadius: BorderRadius.circular(18),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(sender, style: context.pStrong),
                                  const SizedBox(height: 6),
                                  Text(
                                    message.visibleText.trim().isEmpty
                                        ? l10n.chat_attachment
                                        : message.visibleText,
                                    maxLines: 5,
                                    overflow: TextOverflow.ellipsis,
                                    style: context.p,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    formatDateGroupTitle(message.createdAt),
                                    style: context.small.copyWith(
                                      color: colors.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              tooltip: l10n.chat_unstar_message,
                              onPressed: _unstarInFlight.contains(message.id)
                                  ? null
                                  : () => _unstar(message),
                              icon: Icon(
                                Icons.star_rounded,
                                color: colors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _accountSubscription?.close();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }
}

class _StateMessage extends StatelessWidget {
  const _StateMessage({
    required this.icon,
    required this.title,
    this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String? message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: colors.textMuted),
            const SizedBox(height: 12),
            Text(title, textAlign: TextAlign.center, style: context.h5),
            if (message != null) ...[
              const SizedBox(height: 6),
              Text(
                message!,
                textAlign: TextAlign.center,
                style: context.pMuted,
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 18),
              FilledButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}
