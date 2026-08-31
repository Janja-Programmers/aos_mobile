import 'dart:async';

import 'package:africaonlinestores/core/api/failure.dart';
import 'package:africaonlinestores/core/config/app_config.dart';
import 'package:africaonlinestores/core/core.dart';
import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/core/theme/theme_controller.dart';
import 'package:africaonlinestores/features/account/domain/account_state.dart';
import 'package:africaonlinestores/features/account/presentation/widgets/account_guest_header_card.dart';
import 'package:africaonlinestores/features/account/presentation/widgets/account_sections.dart';
import 'package:africaonlinestores/features/account/shared/providers/accounts_controller.dart';
import 'package:africaonlinestores/features/account/shared/routing/account_routes.dart';
import 'package:africaonlinestores/features/activity/navigation/activity_navigation.dart';
import 'package:africaonlinestores/features/ads/shared/routing/ads_routes.dart';
import 'package:africaonlinestores/features/auth/domain/auth_state.dart';
import 'package:africaonlinestores/features/auth/shared/providers/auth_controller_provider.dart';
import 'package:africaonlinestores/features/sellers/domain/seller_identity.dart';
import 'package:africaonlinestores/features/sellers/navigation/seller_routes.dart';
import 'package:africaonlinestores/features/verifications/controllers/get_my_verification_provider.dart';
import 'package:africaonlinestores/features/verifications/controllers/seller_status_provider.dart';
import 'package:africaonlinestores/features/verifications/controllers/verification_controller_provider.dart';
import 'package:africaonlinestores/features/verifications/domain/verification_status.dart';
import 'package:africaonlinestores/features/verifications/presentation/widgets/account_verification_banner.dart';
import 'package:africaonlinestores/features/verifications/presentation/widgets/verification_choice_bottom_sheet.dart';
import 'package:africaonlinestores/features/verifications/user_verification/application/user_verification_provider.dart';
import 'package:africaonlinestores/features/verifications/user_verification/domain/user_verification_models.dart';
import 'package:africaonlinestores/l10n/l10n_extension.dart';
import 'package:africaonlinestores/shared/components/account_option_tile.dart';
import 'package:africaonlinestores/shared/components/app_confirm_sheet.dart';
import 'package:africaonlinestores/shared/components/app_switch_tile.dart';
import 'package:africaonlinestores/shared/widgets/app_snack.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class AccountScreen extends ConsumerStatefulWidget {
  const AccountScreen({super.key});

  @override
  ConsumerState<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends ConsumerState<AccountScreen> {
  bool _isVerificationFlowActive = false;
  bool _isResolvingVerificationStatus = false;

  Widget _buildAccountHeader(
    BuildContext context,
    AuthState auth,
    AccountState accountState,
    bool verificationConfirmed,
  ) {
    final l10n = context.l10n;

    if (auth is! AuthAuthenticated) {
      return AccountGuestHeaderCard(
        onLogin: () => context.goNamed(AppRoutes.nLogin),
        onSignUp: () => context.goNamed(AppRoutes.nRegister),
        title: l10n.account_guest_title,
        subtitle: l10n.account_guest_description,
      );
    }

    final user = auth.user;
    final fetched = accountState.profile;

    final fetchedName = _firstNonEmpty(<Object?>[
      fetched['display_name'],
      fetched['full_name'],
    ]);
    final fetchedEmail = fetched['email']?.toString().trim() ?? '';
    final fetchedImage = _firstNonEmpty([
      fetched['user_image'],
      fetched['avatar'],
      fetched['profile_image'],
    ]);

    final fullName = fetchedName.isNotEmpty
        ? fetchedName
        : user.fullName.isNotEmpty
        ? user.fullName
        : l10n.nav_account;
    final email = fetchedEmail.isNotEmpty ? fetchedEmail : user.email;
    final userImage = fetchedImage.isNotEmpty ? fetchedImage : user.userImage;

    return AccountHeaderCard(
      key: const Key('account_header_card'),
      fullName: fullName,
      email: email,
      initials: _initialsFromName(fullName),
      baseUrl: AppConfig.normalizedBaseUrl,
      imagePath: userImage.isNotEmpty ? userImage : null,
      isVerified:
          verificationConfirmed ||
          user.isVerified ||
          _isProfileVerified(fetched),
      onEdit: () => context.pushNamed(AppRoutes.nProfile),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    final isDarkMode = themeMode == ThemeMode.dark;

    final auth = ref.watch(authControllerProvider);
    final isAuthenticated = auth is AuthAuthenticated;
    final accountState = isAuthenticated
        ? ref.watch(accountsControllerProvider)
        : const AccountState();

    final AsyncValue<SellerVerificationStatus>? sellerStatusAsync =
        isAuthenticated ? ref.watch(sellerStatusProvider) : null;
    final AsyncValue<UserVerificationStatus>? userVerificationAsync =
        isAuthenticated ? ref.watch(userVerificationStatusProvider) : null;
    final sellerStatus = _dataOrNull(sellerStatusAsync);
    final authenticated = auth.asAuthenticated;
    final isSeller =
        sellerStatus?.isSeller ?? authenticated?.seller.isSeller ?? false;
    final sellerId = firstPublicSellerId(<Object?>[
      sellerStatus?.sellerId,
      authenticated?.seller.sellerId,
    ]);
    final userVerificationStatus = _dataOrNull(userVerificationAsync);
    final accountVerified =
        isAuthenticated &&
        _isAccountVerified(
          auth: auth,
          profile: accountState.profile,
          userStatus: userVerificationStatus,
          sellerStatus: sellerStatus,
        );
    final bannerPresentation = _bannerPresentation(
      userStatus: userVerificationStatus,
      sellerStatus: sellerStatus,
      statusUnavailable:
          _hasError(userVerificationAsync) && _hasError(sellerStatusAsync),
    );

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
        onRefresh: isAuthenticated
            ? _refreshAccountAndVerificationState
            : () async {},
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
          children: [
            _buildAccountHeader(context, auth, accountState, accountVerified),
            if (isAuthenticated && !accountVerified) ...[
              const SizedBox(height: 14),
              AccountVerificationBanner(
                key: const Key('account_verification_banner'),
                title: bannerPresentation.title,
                subtitle: bannerPresentation.subtitle,
                tone: bannerPresentation.tone,
                busy: _isResolvingVerificationStatus,
                onTap: () {
                  unawaited(
                    _openVerificationFlow(
                      userStatusAsync: userVerificationAsync,
                      sellerStatusAsync: sellerStatusAsync,
                    ),
                  );
                },
              ),
            ],
            if (isAuthenticated) const SizedBox(height: 14),

            /// AUTHENTICATED ACTIONS
            if (isAuthenticated)
              AccountCard(
                child: Column(
                  children: [
                    if (isSeller) ...[
                      AccountOptionTile(
                        icon: Icons.list_alt_sharp,
                        title: 'My Listings',
                        onTap: () => AdNavigation.toMyAds(context),
                      ),
                      if (sellerId != null)
                        AccountOptionTile(
                          icon: Icons.store_mall_directory_outlined,
                          title: 'My Storefront',
                          onTap: () => SellerNavigation.toMyStoreFront(
                            context,
                            sellerId,
                          ),
                        ),
                    ],
                    AccountOptionTile(
                      icon: Icons.favorite_border,
                      title: 'My Wishlist',
                      onTap: () => AdNavigation.toWishlist(context),
                    ),
                    AccountOptionTile(
                      icon: Icons.notifications_active_outlined,
                      title: 'Activity Center',
                      showDivider: false,
                      onTap: () => ActivityNavigation.toActivityCenter(context),
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
                    icon: Icons.tune,
                    title: l10n.app_preferences,
                    onTap: () => context.pushNamed(AppRoutes.nPreference),
                  ),
                  AppSwitchTile(
                    icon: Icons.dark_mode_outlined,
                    title: l10n.settings_dark_mode,
                    value: isDarkMode,
                    showDivider: isAuthenticated,
                    onChanged: (val) {
                      ref
                          .read(themeModeProvider.notifier)
                          .setThemeMode(val ? ThemeMode.dark : ThemeMode.light);
                    },
                  ),

                  if (!isAuthenticated)
                    AccountOptionTile(
                      icon: Icons.settings_backup_restore_sharp,
                      title: 'Restore account',
                      showDivider: false,
                      onTap: () => context.pushNamed(AppRoutes.nRestoreAccount),
                    ),
                  if (isAuthenticated) ...[
                    AccountOptionTile(
                      icon: Icons.delete_forever_outlined,
                      title: 'Delete Account',
                      foregroundColor: scheme.primary,
                      iconBackgroundColor: scheme.primary.withValues(
                        alpha: 0.12,
                      ),
                      onTap: () => context.pushNamed(AppRoutes.nDeleteAccount),
                    ),
                  ],
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
                    final authController = ref.read(
                      authControllerProvider.notifier,
                    );
                    final confirmed = await showModalBottomSheet<bool>(
                      context: context,
                      useRootNavigator: true,
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
                          onPrimary: () => Navigator.of(sheetContext).pop(true),
                          onSecondary: () =>
                              Navigator.of(sheetContext).pop(false),
                        );
                      },
                    );

                    if (confirmed != true || !context.mounted) return;

                    await authController.logout();

                    if (!context.mounted) return;

                    context.goNamed(AppRoutes.nLogin);
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

  Future<void> _openVerificationFlow({
    required AsyncValue<UserVerificationStatus>? userStatusAsync,
    required AsyncValue<SellerVerificationStatus>? sellerStatusAsync,
  }) async {
    if (_isVerificationFlowActive) return;

    setState(() {
      _isVerificationFlowActive = true;
      _isResolvingVerificationStatus = true;
    });

    try {
      if (_hasError(userStatusAsync)) {
        ref.invalidate(userVerificationStatusProvider);
      }
      if (_hasError(sellerStatusAsync)) {
        ref.invalidate(sellerStatusProvider);
      }

      final individualResolutionFuture = _resolveStatus(
        current: userStatusAsync,
        load: () => ref.read(userVerificationStatusProvider.future),
      );
      final businessResolutionFuture = _resolveStatus(
        current: sellerStatusAsync,
        load: () => ref.read(sellerStatusProvider.future),
      );
      final individualResolution = await individualResolutionFuture;
      final businessResolution = await businessResolutionFuture;

      if (!mounted) return;

      setState(() => _isResolvingVerificationStatus = false);

      final userStatus = individualResolution.data;
      final sellerStatus = businessResolution.data;
      final choice = await showVerificationChoiceBottomSheet(
        context: context,
        individualStatus: userStatus?.status,
        businessStatus: sellerStatus?.status,
        individualUnavailable: individualResolution.unavailable,
        businessUnavailable: businessResolution.unavailable,
        individualRejectionReason: userStatus?.rejectionReason,
        businessRejectionReason: sellerStatus?.rejectionReason,
      );

      if (!mounted || choice == null) return;

      final bool? submitted;
      switch (choice) {
        case VerificationChoice.individual:
          if (userStatus?.status == VerificationStatus.pending ||
              userStatus?.status == VerificationStatus.approved) {
            return;
          }

          ref
              .read(userVerificationControllerProvider.notifier)
              .reset(
                status: userStatus,
                verificationType: choice.verificationType,
              );
          submitted = await AccountNavigation.toUserVerification(
            context,
            verificationType: choice.verificationType,
          );
          break;

        case VerificationChoice.business:
          if (sellerStatus?.status == VerificationStatus.pending ||
              sellerStatus?.status == VerificationStatus.approved) {
            return;
          }

          final controller = ref.read(
            sellerVerificationControllerProvider.notifier,
          );

          if (sellerStatus?.status == VerificationStatus.rejected) {
            ref.invalidate(myBusinessVerificationProvider);

            try {
              final verification = await ref.read(
                myBusinessVerificationProvider.future,
              );
              if (!mounted) return;
              controller.hydrateFromVerification(verification);
              controller.updateBasic(verificationType: choice.verificationType);
            } on Failure catch (failure) {
              if (mounted) {
                ShowSnack(context, failure.message).error();
              }
              return;
            } on Exception {
              if (mounted) {
                ShowSnack(
                  context,
                  'Unable to load your business verification details.',
                ).error();
              }
              return;
            }
          } else {
            controller.reset(verificationType: choice.verificationType);
          }

          if (!mounted) return;
          submitted = await SellerNavigation.openSellerVerification(context);
          break;
      }

      if (!mounted || submitted != true) return;
      await _refreshAccountAndVerificationState();
    } finally {
      if (mounted) {
        setState(() {
          _isVerificationFlowActive = false;
          _isResolvingVerificationStatus = false;
        });
      }
    }
  }

  Future<void> _refreshAccountAndVerificationState() async {
    ref.invalidate(sellerStatusProvider);
    ref.invalidate(userVerificationStatusProvider);
    ref.invalidate(myBusinessVerificationProvider);

    final sellerRefresh = _ignoreFailure(ref.read(sellerStatusProvider.future));
    final userRefresh = _ignoreFailure(
      ref.read(userVerificationStatusProvider.future),
    );
    final profileResult = await ref
        .read(accountsControllerProvider.notifier)
        .loadProfile();

    if (!mounted) return;

    final profile = profileResult.rightOrNull;
    final currentAuth = ref.read(authControllerProvider);
    if (profile != null && currentAuth is AuthAuthenticated) {
      final mergedUser = <String, dynamic>{
        'email': currentAuth.user.email,
        'full_name': currentAuth.user.fullName,
        'user_image': currentAuth.user.userImage,
        'is_verified': currentAuth.user.isVerified,
        ...profile,
      };
      ref.read(authControllerProvider.notifier).setUserFromMap(mergedUser);
    }

    await Future.wait<void>([sellerRefresh, userRefresh]);
  }

  static Future<void> _ignoreFailure<T>(Future<T> future) async {
    try {
      await future;
    } on Exception {
      return;
    }
  }

  static T? _dataOrNull<T>(AsyncValue<T>? value) {
    return value?.maybeWhen(data: (data) => data, orElse: () => null);
  }

  static bool _hasError<T>(AsyncValue<T>? value) {
    return value?.maybeWhen(error: (_, _) => true, orElse: () => false) ??
        false;
  }

  static Future<_StatusResolution<T>> _resolveStatus<T>({
    required AsyncValue<T>? current,
    required Future<T> Function() load,
  }) async {
    final currentData = _dataOrNull(current);
    if (currentData != null) {
      return _StatusResolution<T>.available(currentData);
    }

    try {
      final data = await load();
      return _StatusResolution<T>.available(data);
    } on Exception {
      return _StatusResolution<T>.unavailable();
    }
  }

  static bool _isAccountVerified({
    required AuthState auth,
    required Map<String, dynamic> profile,
    required UserVerificationStatus? userStatus,
    required SellerVerificationStatus? sellerStatus,
  }) {
    final authVerified = auth is AuthAuthenticated && auth.user.isVerified;
    final userVerified =
        (userStatus?.isVerified ?? false) ||
        userStatus?.status == VerificationStatus.approved;
    final businessVerified =
        (sellerStatus?.isVerified ?? false) ||
        sellerStatus?.status == VerificationStatus.approved;

    return authVerified ||
        _isProfileVerified(profile) ||
        userVerified ||
        businessVerified;
  }

  static _VerificationBannerPresentation _bannerPresentation({
    required UserVerificationStatus? userStatus,
    required SellerVerificationStatus? sellerStatus,
    required bool statusUnavailable,
  }) {
    if (statusUnavailable) {
      return const _VerificationBannerPresentation(
        title: 'Verification Unavailable',
        subtitle: 'Pull down to refresh your verification status',
        tone: AccountVerificationBannerTone.unavailable,
      );
    }

    final userRejected = userStatus?.status == VerificationStatus.rejected;
    final businessRejected =
        sellerStatus?.status == VerificationStatus.rejected;

    if (userRejected || businessRejected) {
      final reason = userRejected
          ? userStatus?.rejectionReason
          : sellerStatus?.rejectionReason;
      final cleanedReason = reason?.trim() ?? '';

      return _VerificationBannerPresentation(
        title: 'Verification Needs Update',
        subtitle: cleanedReason.isEmpty
            ? 'Review your details and submit your verification again'
            : cleanedReason,
        tone: AccountVerificationBannerTone.rejected,
      );
    }

    final isPending =
        userStatus?.status == VerificationStatus.pending ||
        sellerStatus?.status == VerificationStatus.pending;

    if (isPending) {
      return const _VerificationBannerPresentation(
        title: 'Verification in Review',
        subtitle: 'Your verification request is currently being reviewed',
        tone: AccountVerificationBannerTone.pending,
      );
    }

    return const _VerificationBannerPresentation(
      title: 'Get Verified',
      subtitle: 'Verify as an individual or a business',
      tone: AccountVerificationBannerTone.available,
    );
  }

  static bool _isProfileVerified(Map<String, dynamic> profile) {
    return _truthy(profile['is_verified']) ||
        _truthy(profile['identity_verified']) ||
        _truthy(profile['is_identity_verified']) ||
        _approvedStatus(profile['verification_status']) ||
        _approvedStatus(profile['identity_verification_status']) ||
        _approvedStatus(profile['user_verification_status']);
  }

  static bool _approvedStatus(Object? value) {
    final normalized = value?.toString().trim().toLowerCase() ?? '';
    return normalized == 'approved' || normalized == 'verified';
  }

  static String _initialsFromName(String? name) {
    final n = name?.trim() ?? '';
    if (n.isEmpty) return 'U';
    return n.substring(0, 1).toUpperCase();
  }

  static String _firstNonEmpty(List<Object?> values) {
    for (final value in values) {
      final clean = value?.toString().trim() ?? '';
      if (clean.isNotEmpty) return clean;
    }

    return '';
  }

  static bool _truthy(Object? value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is num) return value == 1;

    final clean = value.toString().trim().toLowerCase();
    return clean == '1' ||
        clean == 'true' ||
        clean == 'yes' ||
        clean == 'approved' ||
        clean == 'verified';
  }
}

class _StatusResolution<T> {
  const _StatusResolution.available(this.data) : unavailable = false;

  const _StatusResolution.unavailable() : data = null, unavailable = true;

  final T? data;
  final bool unavailable;
}

class _VerificationBannerPresentation {
  const _VerificationBannerPresentation({
    required this.title,
    required this.subtitle,
    required this.tone,
  });

  final String title;
  final String subtitle;
  final AccountVerificationBannerTone tone;
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
