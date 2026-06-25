import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:africaonlinestores/core/api/api_endpoints.dart';
import 'package:africaonlinestores/core/providers.dart';
import 'package:africaonlinestores/core/api/api_response.dart';
import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:africaonlinestores/features/social/safety/data/social_safety_api.dart';
import 'package:africaonlinestores/shared/widgets/app_snack.dart';

class UserSafetySheet extends ConsumerStatefulWidget {
  const UserSafetySheet({
    super.key,
    required this.targetUser,
    this.displayName,
  });

  final String targetUser;
  final String? displayName;

  @override
  ConsumerState<UserSafetySheet> createState() => _UserSafetySheetState();
}

class _UserSafetySheetState extends ConsumerState<UserSafetySheet> {
  bool _loading = false;

  Future<List<String>> _loadReasons() async {
    final res = await ref
        .read(apiClientProvider)
        .get(ApiEndpoints.listReportReasonsEndpoint);
    final unwrapped = unwrapFrappe(res);
    final data = unwrapped.rightOrNull?['data'];
    final reasons = data is Map ? data['reasons'] : null;
    if (reasons is! List) return const ['Spam', 'Harassment', 'Scam', 'Other'];
    return reasons
        .whereType<Map>()
        .map((e) => e['id']?.toString() ?? e['title']?.toString() ?? '')
        .where((e) => e.isNotEmpty)
        .toList();
  }

  Future<void> _block() async {
    setState(() => _loading = true);
    final res = await ref
        .read(socialSafetyApiProvider)
        .blockUser(targetUser: widget.targetUser);
    if (!mounted) return;
    setState(() => _loading = false);
    res.fold((f) => ShowSnack(context, f.message).error(), (_) {
      ShowSnack(context, 'User blocked.').success();
      Navigator.pop(context);
    });
  }

  Future<void> _report() async {
    final reasons = await _loadReasons();
    if (!mounted) return;
    final reason = await showModalBottomSheet<String>(
      context: context,
      useSafeArea: true,
      builder: (_) => _ReasonSheet(reasons: reasons),
    );
    if (reason == null || !mounted) return;

    setState(() => _loading = true);
    final res = await ref
        .read(socialSafetyApiProvider)
        .reportUser(
          targetUser: widget.targetUser,
          reason: reason,
          blockUser: true,
        );
    if (!mounted) return;
    setState(() => _loading = false);
    res.fold((f) => ShowSnack(context, f.message).error(), (msg) {
      ShowSnack(context, msg).success();
      Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: colors.border,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text(widget.displayName ?? widget.targetUser, style: context.h5),
            const SizedBox(height: 6),
            Text('Safety actions for this user.', style: context.pMuted),
            const SizedBox(height: 12),
            ListTile(
              leading: const Icon(Icons.flag_outlined),
              title: const Text('Report user'),
              subtitle: const Text('Report and optionally block this user'),
              enabled: !_loading,
              onTap: _report,
            ),
            ListTile(
              leading: Icon(Icons.block_rounded, color: colors.red),
              title: Text('Block user', style: TextStyle(color: colors.red)),
              subtitle: const Text(
                'They will not be able to interact with you',
              ),
              enabled: !_loading,
              onTap: _block,
            ),
          ],
        ),
      ),
    );
  }
}

class _ReasonSheet extends StatelessWidget {
  const _ReasonSheet({required this.reasons});

  final List<String> reasons;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView.separated(
        shrinkWrap: true,
        padding: const EdgeInsets.all(18),
        itemCount: reasons.length,
        separatorBuilder: (_, _) => const Divider(height: 1),
        itemBuilder: (_, index) {
          final reason = reasons[index];
          return ListTile(
            title: Text(reason),
            onTap: () => Navigator.pop(context, reason),
          );
        },
      ),
    );
  }
}
