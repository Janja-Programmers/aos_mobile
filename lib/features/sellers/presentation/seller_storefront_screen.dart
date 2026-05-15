import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:africaonlinestores/core/core.dart';
import 'package:africaonlinestores/core/routing/app_nav.dart';
import 'package:africaonlinestores/core/routing/app_nav_config.dart';
import 'package:africaonlinestores/core/theme/app_text_styles.dart';

import 'package:africaonlinestores/features/connect/calls/application/providers/call_providers.dart';
import 'package:africaonlinestores/features/connect/calls/domain/call.dart';
import 'package:africaonlinestores/features/connect/calls/domain/call_participant.dart';
import 'package:africaonlinestores/features/connect/chats/utils/chat_actions.dart';

import 'package:africaonlinestores/features/sellers/application/providers/seller_ads_provider.dart';
import 'package:africaonlinestores/features/sellers/application/providers/seller_state_controller_provider.dart';
import 'package:africaonlinestores/features/sellers/domain/aos_seller.dart';
import 'package:africaonlinestores/features/sellers/presentation/sections/seller_about_section.dart';
import 'package:africaonlinestores/features/sellers/presentation/sections/seller_header_section.dart';
import 'package:africaonlinestores/features/sellers/presentation/sections/seller_products_section.dart';

import 'package:africaonlinestores/shared/components/buttons/ad_detail_action_buttons.dart';

class SellerStorefrontScreen extends ConsumerStatefulWidget {
  const SellerStorefrontScreen({
    super.key,
    required this.sellerId,
    this.initialSeller,
  });

  final String sellerId;
  final AOSSellerProfile? initialSeller;

  @override
  ConsumerState<SellerStorefrontScreen> createState() =>
      _SellerStorefrontScreenState();
}

class _SellerStorefrontScreenState
    extends ConsumerState<SellerStorefrontScreen> {
  bool _isCalling = false;

  Future<void> _handleCall(AOSSellerProfile seller) async {
    if (_isCalling) return;

    _isCalling = true;

    try {
      await AppNavigation.requireAuth(
        context,
        ref,
        onAuthenticated: () async {
          final manager = ref.read(callManagerProvider.notifier);

          if (widget.sellerId.trim().isEmpty) {
            debugPrint('❌ sellerId is empty');
            return;
          }

          await manager.startOutgoingCall(
            userId: widget.sellerId,
            callType: AOSCallType.audio,
            receiver: _buildReceiver(seller),
          );
        },
      );
    } finally {
      _isCalling = false;
    }
  }

  void _handleMessage(AOSSellerProfile seller) {
    AppNavigation.requireAuth(
      context,
      ref,
      onAuthenticated: () {
        ChatActions.startChat(
          context: context,
          ref: ref,
          user: widget.sellerId,
          displayName: seller.displayName,
          initialMessage: 'Hello ${seller.displayName}',
        );
      },
    );
  }

  CallParticipant _buildReceiver(AOSSellerProfile seller) {
    final sellerName = seller.displayName.trim();

    return CallParticipant(
      userId: widget.sellerId,
      displayName: sellerName.isNotEmpty ? sellerName : widget.sellerId,
      avatarUrl: seller.avatar,
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(sellerStateProvider(widget.sellerId));
    final colors = context.appColors;

    final seller = state.seller ?? widget.initialSeller;

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        backgroundColor: colors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leadingWidth: 64,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: _StorefrontIconButton(
            icon: Icons.arrow_back,
            onTap: () => Navigator.of(context).maybePop(),
          ),
        ),
        title: Text(
          'Seller Storefront',
          style: context.h5.copyWith(fontWeight: FontWeight.w800),
        ),
        actions: [
          PopupMenuButton<int>(
            color: colors.surface,
            elevation: 10,
            offset: const Offset(0, 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            icon: const Icon(Icons.more_horiz),
            onSelected: (index) => AppNavigation.goTo(context, ref, index),
            itemBuilder: (context) {
              final items = AppNavConfig.items(context);
              final location = GoRouterState.of(context).matchedLocation;

              return List.generate(items.length, (i) {
                final item = items[i];
                final isActive = location.contains(item.routeName);

                return PopupMenuItem<int>(
                  value: i,
                  child: Row(
                    children: [
                      Icon(
                        item.icon,
                        size: 20,
                        color: isActive ? colors.primary : colors.textPrimary,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        item.label,
                        style: context.p.copyWith(
                          color: isActive ? colors.primary : colors.textPrimary,
                          fontWeight: isActive
                              ? FontWeight.w700
                              : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                );
              });
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Builder(
        builder: (_) {
          if (state.loading && seller == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.error != null && seller == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  state.error!,
                  textAlign: TextAlign.center,
                  style: context.body,
                ),
              ),
            );
          }

          if (seller == null) {
            return Center(child: Text('Seller not found', style: context.body));
          }

          return RefreshIndicator(
            onRefresh: () async {
              await ref
                  .read(sellerStateProvider(widget.sellerId).notifier)
                  .load();

              ref.invalidate(sellerAdsProvider(widget.sellerId));
            },
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
              children: [
                SellerHeaderSection(seller: seller, sellerId: widget.sellerId),
                const SizedBox(height: 14),
                SellerAboutSection(about: seller.aboutBusiness),
                const SizedBox(height: 14),
                SellerProductsSection(sellerId: widget.sellerId),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: seller == null || seller.isSelf
          ? null
          : SafeArea(
              top: false,
              child: AdDetailActionBar(
                onCall: () => _handleCall(seller),
                onMessage: () => _handleMessage(seller),
              ),
            ),
    );
  }
}

class _StorefrontIconButton extends StatelessWidget {
  const _StorefrontIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Material(
      color: colors.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Icon(icon, color: colors.textPrimary, size: 22),
      ),
    );
  }
}
