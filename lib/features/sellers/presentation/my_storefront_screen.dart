import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';

import 'package:africaonlinestores/features/sellers/application/providers/seller_state_controller_provider.dart';
import 'package:africaonlinestores/features/sellers/application/providers/seller_profile_provider.dart';

import 'package:africaonlinestores/features/sellers/presentation/widgets/my_storefront/analytics_section.dart';
import 'package:africaonlinestores/features/sellers/presentation/widgets/my_storefront/owner_tabs.dart';
import 'package:africaonlinestores/features/sellers/presentation/widgets/my_storefront/post_actions_bottom_sheet.dart';
import 'package:africaonlinestores/features/sellers/presentation/widgets/my_storefront/post_section.dart';
import 'package:africaonlinestores/features/sellers/presentation/widgets/my_storefront/storefront_header_card.dart';
import 'package:africaonlinestores/features/sellers/navigation/seller_routes.dart';
import 'package:africaonlinestores/features/sellers/domain/storefront_post.dart';
import 'package:africaonlinestores/features/shorts/shared/application/providers/shorts_providers.dart';
import 'package:africaonlinestores/shared/widgets/app_snack.dart';

class MyStorefrontScreen extends ConsumerStatefulWidget {
  const MyStorefrontScreen({super.key, required this.sellerId});

  final String sellerId;

  @override
  ConsumerState<MyStorefrontScreen> createState() => _MyStorefrontScreenState();
}

class _MyStorefrontScreenState extends ConsumerState<MyStorefrontScreen> {
  int _selectedTab = 0;

  Future<void> _showPostActions({required StorefrontPost post}) async {
    final postId = post.id;
    final title = post.title;
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return PostActionsBottomSheet(
          postTitle: title,
          onViewAnalytics: () {
            Navigator.pop(context);
            setState(() => _selectedTab = 1);
          },
          onEditPost: () {
            Navigator.pop(context);
            _showEditPostSheet(post);
          },
          onDeletePost: () async {
            Navigator.pop(context);

            final confirmed = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Delete short?'),
                content: const Text(
                  'This will remove the short from your storefront and feeds.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Cancel'),
                  ),
                  FilledButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Delete'),
                  ),
                ],
              ),
            );

            if (confirmed != true) return;

            final error = await ref
                .read(storefrontDashboardControllerProvider.notifier)
                .deletePost(postId);

            if (!mounted) return;

            if (error != null) {
              ShowSnack(context, error).error();
            } else {
              ShowSnack(context, 'Post deleted').success();
            }
          },
        );
      },
    );
  }

  Future<void> _showEditPostSheet(StorefrontPost post) async {
    final short = post.short;
    final captionController = TextEditingController(text: short.caption.value);
    final hashtagsController = TextEditingController(
      text: short.hashtags.join(' '),
    );
    var audience = short.audience;
    var allowComments = short.allowComments;
    var allowDownloads = short.allowDownloads;
    var saving = false;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final colors = context.appColors;
            final bottom = MediaQuery.of(context).viewInsets.bottom;

            Future<void> save() async {
              if (saving) return;
              setSheetState(() => saving = true);

              final tags = hashtagsController.text
                  .split(RegExp(r'\s+'))
                  .map((value) => value.trim())
                  .where((value) => value.isNotEmpty)
                  .toList(growable: false);

              final result = await ref
                  .read(shortsUploadApiProvider)
                  .updateMetadata(
                    shortId: short.id.value,
                    contentMode: short.contentMode,
                    adId: short.ad?.id,
                    caption: captionController.text.trim(),
                    hashtags: tags,
                    audience: audience,
                    allowComments: allowComments,
                    allowDownloads: allowDownloads,
                  );

              if (!mounted) return;

              result.fold(
                (failure) {
                  setSheetState(() => saving = false);
                  ShowSnack(context, failure.message).error();
                },
                (_) {
                  Navigator.pop(sheetContext);
                  ShowSnack(context, 'Short updated').success();
                  ref
                      .read(storefrontDashboardControllerProvider.notifier)
                      .load();
                },
              );
            }

            return Padding(
              padding: EdgeInsets.only(bottom: bottom),
              child: SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text('Edit short', style: context.h5),
                          ),
                          IconButton(
                            onPressed: saving
                                ? null
                                : () => Navigator.pop(context),
                            icon: const Icon(Icons.close_rounded),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: captionController,
                        maxLines: 4,
                        maxLength: 512,
                        decoration: InputDecoration(
                          labelText: 'Caption',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: hashtagsController,
                        decoration: InputDecoration(
                          labelText: 'Hashtags',
                          hintText: '#fashion #deals',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text('Audience', style: context.pStrong),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _EditAudienceChip(
                            label: 'Everyone',
                            value: 'everyone',
                            groupValue: audience,
                            onSelected: (value) =>
                                setSheetState(() => audience = value),
                          ),
                          _EditAudienceChip(
                            label: 'Followers',
                            value: 'followers',
                            groupValue: audience,
                            onSelected: (value) =>
                                setSheetState(() => audience = value),
                          ),
                          _EditAudienceChip(
                            label: 'Friends',
                            value: 'friends',
                            groupValue: audience,
                            onSelected: (value) =>
                                setSheetState(() => audience = value),
                          ),
                          _EditAudienceChip(
                            label: 'Only me',
                            value: 'only_me',
                            groupValue: audience,
                            onSelected: (value) =>
                                setSheetState(() => audience = value),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      SwitchListTile.adaptive(
                        value: allowComments,
                        onChanged: (value) =>
                            setSheetState(() => allowComments = value),
                        contentPadding: EdgeInsets.zero,
                        title: Text('Allow comments', style: context.p),
                      ),
                      SwitchListTile.adaptive(
                        value: allowDownloads,
                        onChanged: (value) =>
                            setSheetState(() => allowDownloads = value),
                        contentPadding: EdgeInsets.zero,
                        title: Text('Allow downloads', style: context.p),
                        subtitle: Text(
                          'Disabled by default. Owner downloads still work.',
                          style: context.small.copyWith(
                            color: colors.textMuted,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: FilledButton(
                          onPressed: saving ? null : save,
                          child: saving
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text('Save changes'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );

    captionController.dispose();
    hashtagsController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sellerState = ref.watch(sellerStateProvider(widget.sellerId));
    final dashboardState = ref.watch(storefrontDashboardControllerProvider);

    final seller = sellerState.seller;
    final colors = context.appColors;

    if (seller == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        backgroundColor: colors.surface,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          'My Storefront',
          style: context.h5.copyWith(fontWeight: FontWeight.w800),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () {
          return ref
              .read(storefrontDashboardControllerProvider.notifier)
              .load();
        },
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          children: [
            MyStorefrontHeaderCard(
              sellerName: seller.displayName,
              avatarUrl: seller.avatar,
              isVerified: seller.isVerified,
              totalAds: seller.totalAds,
              totalFollowers: seller.totalFollowers,
              rating: seller.rating,
              totalReviews: seller.totalReviews,
              onCustomize: () {
                SellerNavigation.toCustomizeStore(context, seller.user);
              },
              onPreview: () {
                SellerNavigation.toSellerStore(context, widget.sellerId);
              },
            ),

            const SizedBox(height: 16),

            OwnerTabs(
              selectedIndex: _selectedTab,
              onChanged: (index) {
                setState(() => _selectedTab = index);
              },
            ),

            const SizedBox(height: 18),

            if (_selectedTab == 0)
              MyPostsSection(
                loading: dashboardState.loading,
                error: dashboardState.error,
                posts: dashboardState.posts,
                onRefresh: () {
                  ref
                      .read(storefrontDashboardControllerProvider.notifier)
                      .load();
                },
                onPostMenuTap: (post) {
                  _showPostActions(post: post);
                },
              )
            else
              AnalyticsSection(analytics: dashboardState.analytics),
          ],
        ),
      ),
    );
  }
}

class _EditAudienceChip extends StatelessWidget {
  final String label;
  final String value;
  final String groupValue;
  final ValueChanged<String> onSelected;

  const _EditAudienceChip({
    required this.label,
    required this.value,
    required this.groupValue,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final selected = value == groupValue;

    return ChoiceChip(
      selected: selected,
      label: Text(label),
      onSelected: (_) => onSelected(value),
      selectedColor: colors.primary.withOpacity(.16),
      side: BorderSide(color: selected ? colors.primary : colors.border),
    );
  }
}
