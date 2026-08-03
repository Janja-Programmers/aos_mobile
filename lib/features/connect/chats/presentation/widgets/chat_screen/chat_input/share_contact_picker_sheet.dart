import 'dart:async';

import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:africaonlinestores/features/connect/chats/domain/payloads/chat_shared_payload.dart';
import 'package:africaonlinestores/features/social/safety/application/social_safety_controller.dart';
import 'package:africaonlinestores/features/social/safety/data/social_safety_api.dart';
import 'package:africaonlinestores/l10n/gen/app_localizations.dart';
import 'package:africaonlinestores/shared/components/app_circle_avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<ChatContactPayload?> showShareContactPickerSheet({
  required BuildContext context,
}) {
  return showModalBottomSheet<ChatContactPayload>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (context) => const ShareContactPickerSheet(),
  );
}

class ShareContactPickerSheet extends ConsumerStatefulWidget {
  const ShareContactPickerSheet({super.key});

  @override
  ConsumerState<ShareContactPickerSheet> createState() =>
      _ShareContactPickerSheetState();
}

class _ShareContactPickerSheetState
    extends ConsumerState<ShareContactPickerSheet> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    setState(() {});
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      if (!mounted) return;
      unawaited(
        ref.read(socialUserSearchControllerProvider.notifier).search(value),
      );
    });
  }

  void _select(SocialUserSummary user) {
    Navigator.of(context).pop(
      ChatContactPayload(
        displayName: user.displayName,
        user: user.user,
        avatar: user.avatar,
        email: user.user,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final l10n = AppLocalizations.of(context);
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final state = ref.watch(socialUserSearchControllerProvider);
    final query = _searchController.text.trim();

    return AnimatedPadding(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      padding: EdgeInsets.only(bottom: bottomInset),
      child: DraggableScrollableSheet(
        initialChildSize: 0.62,
        minChildSize: 0.42,
        maxChildSize: 0.88,
        expand: false,
        builder: (context, scrollController) {
          return DecoratedBox(
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(28),
              ),
              border: Border(top: BorderSide(color: colors.border)),
            ),
            child: Column(
              children: [
                const SizedBox(height: 10),
                Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: colors.border,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 22, 20, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.chat_share_contact, style: context.h5),
                      const SizedBox(height: 14),
                      TextField(
                        controller: _searchController,
                        onChanged: _onSearchChanged,
                        textInputAction: TextInputAction.search,
                        decoration: InputDecoration(
                          hintText: l10n.chat_search_aos_users,
                          prefixIcon: const Icon(Icons.search_rounded),
                          suffixIcon: state.loading
                              ? const Padding(
                                  padding: EdgeInsets.all(14),
                                  child: SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                )
                              : query.isEmpty
                              ? null
                              : IconButton(
                                  tooltip: l10n.chat_clear_search,
                                  onPressed: () {
                                    _searchController.clear();
                                    _onSearchChanged('');
                                    setState(() {});
                                  },
                                  icon: const Icon(Icons.close_rounded),
                                ),
                          filled: true,
                          fillColor: colors.elevated,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: BorderSide(color: colors.border),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: BorderSide(color: colors.border),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: BorderSide(color: colors.primary),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: _ContactResults(
                    state: state,
                    query: query,
                    controller: scrollController,
                    onSelected: _select,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ContactResults extends StatelessWidget {
  const _ContactResults({
    required this.state,
    required this.query,
    required this.controller,
    required this.onSelected,
  });

  final SocialUserSearchState state;
  final String query;
  final ScrollController controller;
  final ValueChanged<SocialUserSummary> onSelected;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final l10n = AppLocalizations.of(context);

    if (state.error != null) {
      return _SheetStateMessage(
        icon: Icons.error_outline_rounded,
        title: l10n.chat_could_not_load_contacts,
        subtitle: state.error!,
      );
    }

    if (query.length < 2) {
      return _SheetStateMessage(
        icon: Icons.person_search_rounded,
        title: l10n.chat_search_people_on_aos,
        subtitle: l10n.chat_search_people_hint,
      );
    }

    if (state.loading && state.items.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.items.isEmpty) {
      return _SheetStateMessage(
        icon: Icons.search_off_rounded,
        title: l10n.chat_no_contacts_found,
        subtitle: l10n.chat_no_contacts_found_hint,
      );
    }

    return ListView.separated(
      controller: controller,
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
      itemBuilder: (context, index) {
        final user = state.items[index];
        return Material(
          color: Colors.transparent,
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 2,
              vertical: 8,
            ),
            leading: AppCircularAvatar(
              name: user.displayName,
              imageUrl: user.avatar,
              radius: 26,
              backgroundColor: colors.primary.withValues(alpha: 0.20),
              textColor: colors.white,
            ),
            title: Text(
              user.displayName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.pStrong,
            ),
            subtitle: Text(
              user.user,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.small.copyWith(color: colors.textMuted),
            ),
            trailing: Icon(Icons.send_rounded, color: colors.primary),
            onTap: () => onSelected(user),
          ),
        );
      },
      separatorBuilder: (context, index) =>
          Divider(height: 1, color: colors.border.withValues(alpha: 0.70)),
      itemCount: state.items.length,
    );
  }
}

class _SheetStateMessage extends StatelessWidget {
  const _SheetStateMessage({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: colors.textMuted, size: 34),
            const SizedBox(height: 12),
            Text(title, style: context.pStrong, textAlign: TextAlign.center),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: context.small.copyWith(color: colors.textMuted),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
