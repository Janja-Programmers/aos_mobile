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

class MyStorefrontScreen extends ConsumerStatefulWidget {
  const MyStorefrontScreen({super.key, required this.sellerId});

  final String sellerId;

  @override
  ConsumerState<MyStorefrontScreen> createState() => _MyStorefrontScreenState();
}

class _MyStorefrontScreenState extends ConsumerState<MyStorefrontScreen> {
  int _selectedTab = 0;

  Future<void> _showPostActions({
    required String postId,
    required String title,
  }) async {
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
          },
          onDeletePost: () {
            Navigator.pop(context);

            // final error = await ref
            //     .read(storefrontDashboardControllerProvider.notifier)
            //     .deletePost(postId);

            // if (!mounted) return;

            // if (error != null) {
            //   ShowSnack(context, error).error();
            // } else {
            //   ShowSnack(context, 'Post deleted').success();
            // }
          },
        );
      },
    );
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
                  _showPostActions(postId: post.id, title: post.title);
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
