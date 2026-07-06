import 'package:africaonlinestores/core/config/app_config.dart';
import 'package:africaonlinestores/core/core.dart';
import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/core/theme/theme_controller.dart';
import 'package:africaonlinestores/features/account/presentation/widgets/account_guest_header_card.dart';
import 'package:africaonlinestores/features/account/presentation/widgets/account_sections.dart';
import 'package:africaonlinestores/features/ads/shared/routing/ads_routes.dart';
import 'package:africaonlinestores/features/auth/domain/auth_state.dart';
import 'package:africaonlinestores/features/auth/shared/providers/auth_controller_provider.dart';
import 'package:africaonlinestores/features/sellers/navigation/seller_routes.dart';
import 'package:africaonlinestores/features/verifications/controllers/seller_status_provider.dart';
import 'package:africaonlinestores/features/verifications/domain/verification_status.dart';
import 'package:africaonlinestores/features/verifications/presentation/widgets/base_verification_banner.dart';
import 'package:africaonlinestores/features/verifications/presentation/widgets/seller_verification_banner.dart';
import 'package:africaonlinestores/features/verifications/user_verification/application/user_verification_provider.dart';
// import 'package:africaonlinestores/features/verifications/user_verification/domain/user_verification_models.dart';
// import 'package:africaonlinestores/features/verifications/user_verification/presentation/user_verification_banner.dart';
import 'package:africaonlinestores/l10n/l10n_extension.dart';
import 'package:africaonlinestores/shared/components/account_option_tile.dart';
import 'package:africaonlinestores/shared/components/app_confirm_sheet.dart';
import 'package:africaonlinestores/shared/components/app_switch_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class AccountScreen extends ConsumerWidget {
  const AccountScreen({super.key});

  Widget _buildAccountHeader(BuildContext context, AuthState auth) {
    final l10n = context.l10n;

    if (auth is! AuthAuthenticated) {
      return AccountGuestHeaderCard(
        onLogin: () => context.pushNamed(AppRoutes.nLogin),
        onSignUp: () => context.pushNamed(AppRoutes.nRegister),
        title: l10n.account_guest_title,
        subtitle: l10n.account_guest_description,
      );
    }

    final user = auth.user;

    return AccountHeaderCard(
      fullName: user.fullName.isNotEmpty ? user.fullName : l10n.nav_account,
      email: user.email,
      initials: _initialsFromName(user.fullName),
      baseUrl: AppConfig.normalizedBaseUrl,
      imagePath: user.userImage.isNotEmpty ? user.userImage : null,
      isVerified: user.isVerified,
      onEdit: () => context.pushNamed(AppRoutes.nProfile),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final isDarkMode = themeMode == ThemeMode.dark;

    final auth = ref.watch(authControllerProvider);
    final isAuthenticated = auth is AuthAuthenticated;

    /// ✅ Only watch protected verification status when authenticated.
    final AsyncValue<SellerVerificationStatus>? statusAsync = isAuthenticated
        ? ref.watch(sellerStatusProvider)
        : null;
    // final AsyncValue<UserVerificationStatus>? userVerificationAsync =
    //     isAuthenticated ? ref.watch(userVerificationStatusProvider) : null;

    final scheme = Theme.of(context).colorScheme;
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        title: Text(l10n.nav_account, style: context.h4),
        leading: _CircleIconButton(
          icon: Icons.arrow_back,
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.goNamed(AppRoutes.nHome);
            }
          },
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          if (isAuthenticated) {
            ref.invalidate(sellerStatusProvider);
            ref.invalidate(userVerificationStatusProvider);
            await Future.wait([
              ref
                  .read(sellerStatusProvider.future)
                  .then((_) {}, onError: (Object _, StackTrace _) {}),
              ref
                  .read(userVerificationStatusProvider.future)
                  .then((_) {}, onError: (Object _, StackTrace _) {}),
            ]);
          }
        },
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
          children: [
            _buildAccountHeader(context, auth),
            const SizedBox(height: 14),

            /// Business verification entry/status.
            if (isAuthenticated)
              statusAsync?.when(
                    data: (status) {
                      if (status.isSeller) {
                        return AnimatedSwitcher(
                          duration: const Duration(milliseconds: 240),
                          child: SellerVerificationBanner(
                            key: ValueKey(status.status),
                            state: status,
                          ),
                        );
                      }

                      return BaseVerificationBanner(
                        color: context.appColors.primary,
                        icon: Icons.business_center_outlined,
                        title: 'Verify Your Business',
                        subtitle: 'Get verified as a registered business',
                        onTap: () =>
                            SellerNavigation.toSellerVerification(context),
                      );
                    },
                    loading: () => BaseVerificationBanner(
                      color: context.appColors.primary,
                      icon: Icons.business_center_outlined,
                      title: 'Verify Your Business',
                      subtitle: 'Get verified as a registered business',
                      onTap: () =>
                          SellerNavigation.toSellerVerification(context),
                    ),
                    error: (_, _) => BaseVerificationBanner(
                      color: context.appColors.primary,
                      icon: Icons.business_center_outlined,
                      title: 'Verify Your Business',
                      subtitle: 'Get verified as a registered business',
                      onTap: () =>
                          SellerNavigation.toSellerVerification(context),
                    ),
                  ) ??
                  const SizedBox.shrink(),

            /// User identity verification entry/status.
            // if (userVerificationAsync != null)
            //   userVerificationAsync.when(
            //     data: (status) => UserVerificationBanner(status: status),
            //     loading: () => const SizedBox.shrink(),
            //     error: (_, _) => const UserVerificationBanner(
            //       status: UserVerificationStatus(
            //         isVerified: false,
            //         status: VerificationStatus.notSubmitted,
            //       ),
            //     ),
            //   ),

            /// AUTHENTICATED ACTIONS
            if (isAuthenticated)
              AccountCard(
                child: Column(
                  children: [
                    AccountOptionTile(
                      icon: Icons.list_alt_sharp,
                      title: 'My Listings',
                      onTap: () => AdNavigation.toMyAds(context),
                    ),

                    AccountOptionTile(
                      icon: Icons.store_mall_directory_outlined,
                      title: 'My Storefront',
                      onTap: () {
                        final current = auth;
                        SellerNavigation.toMyStoreFront(
                          context,
                          current.user.email,
                        );
                      },
                    ),

                    AccountOptionTile(
                      icon: Icons.favorite_border,
                      title: 'My Wishlist',
                      onTap: () => AdNavigation.toWishlist(context),
                    ),
                    AccountOptionTile(
                      icon: Icons.place_outlined,
                      title: 'Seller Location',
                      onTap: () => SellerNavigation.toSellerLocation(context),
                    ),
                    AccountOptionTile(
                      icon: Icons.history_rounded,
                      title: 'Activity Center',
                      onTap: () => context.pushNamed(AppRoutes.nActivityCenter),
                    ),
                    const SizedBox(height: 18),
                  ],
                ),
              ),

            AccountCard(
              child: Column(
                children: [
                  AccountOptionTile(
                    icon: Icons.map_outlined,
                    title: 'Explore Sellers Nearby',
                    showDivider: false,
                    onTap: () => context.pushNamed(AppRoutes.nMaps),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            /// SETTINGS
            AccountSectionTitle(l10n.account_settings),
            const SizedBox(height: 8),

            AccountCard(
              child: Column(
                children: [
                  if (isAuthenticated)
                    AccountOptionTile(
                      icon: Icons.lock_outline,
                      title: l10n.account_passwords_security,
                      onTap: () =>
                          context.pushNamed(AppRoutes.nPasswordSecurity),
                    ),
                  AccountOptionTile(
                    icon: Icons.notifications_none,
                    title: l10n.account_notifications_preferences,
                    onTap: () => context.pushNamed(AppRoutes.nNotifications),
                  ),
                  AccountOptionTile(
                    icon: Icons.tune,
                    title: l10n.app_preferences,
                    onTap: () => context.pushNamed(AppRoutes.nPreference),
                  ),
                  if (isAuthenticated) ...[
                    AccountOptionTile(
                      icon: Icons.person_search_outlined,
                      title: 'Find People',
                      onTap: () =>
                          context.pushNamed(AppRoutes.nSocialUserSearch),
                    ),
                    AccountOptionTile(
                      icon: Icons.block_outlined,
                      title: 'Blocked Users',
                      onTap: () => context.pushNamed(AppRoutes.nBlockedUsers),
                    ),
                    AccountOptionTile(
                      icon: Icons.delete_forever_outlined,
                      title: 'Delete Account',
                      onTap: () => context.pushNamed(AppRoutes.nDeleteAccount),
                    ),
                    AccountOptionTile(
                      icon: Icons.settings_backup_restore_sharp,
                      title: 'Restore a deleted account',
                      onTap: () => context.pushNamed(AppRoutes.nRestoreAccount),
                    ),
                  ],
                  AppSwitchTile(
                    icon: Icons.dark_mode_outlined,
                    title: l10n.settings_dark_mode,
                    value: isDarkMode,
                    showDivider: false,
                    onChanged: (val) {
                      ref
                          .read(themeModeProvider.notifier)
                          .setThemeMode(val ? ThemeMode.dark : ThemeMode.light);
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            /// OTHER
            AccountSectionTitle(l10n.common_other),
            const SizedBox(height: 8),

            AccountCard(
              child: Column(
                children: [
                  AccountOptionTile(
                    icon: Icons.privacy_tip_outlined,
                    title: l10n.settings_privacy_policy,
                    onTap: () => context.pushNamed(AppRoutes.nPrivacy),
                  ),
                  AccountOptionTile(
                    icon: Icons.description_outlined,
                    title: l10n.settings_terms_conditions,
                    showDivider: false,
                    onTap: () => context.pushNamed(AppRoutes.nTerms),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            /// LOGOUT
            if (isAuthenticated) ...[
              SizedBox(
                height: 54,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final parentContext = context;

                    await showModalBottomSheet<void>(
                      context: parentContext,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (sheetContext) {
                        return AppConfirmSheet(
                          icon: Icons.warning_rounded,
                          iconBg: scheme.primary,
                          title: 'Logout',
                          message:
                              'Are you sure you want to log out? You will need to sign in again.',
                          primaryText: 'Logout',
                          secondaryText: 'Cancel',
                          onPrimary: () async {
                            Navigator.of(sheetContext).pop();

                            await ref
                                .read(authControllerProvider.notifier)
                                .logout();

                            if (!parentContext.mounted) return;

                            parentContext.go(AppRoutes.home);
                          },
                          onSecondary: () => Navigator.of(sheetContext).pop(),
                        );
                      },
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    shape: const StadiumBorder(),
                    side: BorderSide(color: scheme.error),
                    foregroundColor: scheme.error,
                  ),
                  icon: const Icon(Icons.logout, size: 18),
                  label: const Text(
                    'Logout',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  static String _initialsFromName(String? name) {
    final n = name?.trim() ?? '';
    if (n.isEmpty) return 'U';
    return n.substring(0, 1).toUpperCase();
  }
}

/// Reusable rounded circle icon button
class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onPressed,
        child: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: scheme.surfaceBright,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 20, color: scheme.onSurface),
        ),
      ),
    );
  }
}
