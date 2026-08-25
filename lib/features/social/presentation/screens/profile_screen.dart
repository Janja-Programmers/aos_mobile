import 'dart:async';

import 'package:africaonlinestores/core/api/api_response.dart';
import 'package:africaonlinestores/core/api/failure.dart';
import 'package:africaonlinestores/core/core.dart';
import 'package:africaonlinestores/core/media/application/media_services_provider.dart';
import 'package:africaonlinestores/core/media/data/media_upload_api_provider.dart';
import 'package:africaonlinestores/core/media/domain/media_policy.dart';
import 'package:africaonlinestores/core/providers.dart';
import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/core/utils/either.dart';
import 'package:africaonlinestores/core/utils/json_utils.dart';
import 'package:africaonlinestores/features/account/presentation/widgets/profile_edit_sheet.dart';
import 'package:africaonlinestores/features/account/shared/providers/accounts_controller.dart';
import 'package:africaonlinestores/features/account/shared/providers/accounts_provider.dart';
import 'package:africaonlinestores/features/activity/navigation/activity_navigation.dart';
import 'package:africaonlinestores/features/ads/shared/utils/file_url.dart';
import 'package:africaonlinestores/features/auth/domain/auth_state.dart';
import 'package:africaonlinestores/features/auth/shared/providers/auth_controller_provider.dart';
import 'package:africaonlinestores/features/connect/chats/utils/chat_actions.dart';
import 'package:africaonlinestores/features/live/navigation/live_routes.dart';
import 'package:africaonlinestores/features/sellers/application/providers/seller_state_controller_provider.dart';
import 'package:africaonlinestores/features/sellers/navigation/seller_routes.dart';
import 'package:africaonlinestores/features/shorts/shared/data/mappers/short_mapper.dart';
import 'package:africaonlinestores/features/shorts/shared/data/models/short_model.dart';
import 'package:africaonlinestores/features/shorts/shared/domain/entities/short.dart';
import 'package:africaonlinestores/features/shorts/shared/navigation/shorts_routes.dart';
import 'package:africaonlinestores/features/social/application/providers/social_providers.dart';
import 'package:africaonlinestores/features/social/application/state/social_connections_state.dart';
import 'package:africaonlinestores/features/social/navigation/social_navigation.dart';
import 'package:africaonlinestores/features/social/safety/presentation/widgets/user_safety_sheet.dart';
import 'package:africaonlinestores/l10n/l10n_extension.dart';
import 'package:africaonlinestores/shared/components/verified_badge.dart';
import 'package:africaonlinestores/shared/widgets/app_snack.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

part 'profile_screen_grid.dart';
part 'profile_screen_header.dart';
part 'profile_screen_loader.dart';
part 'profile_screen_models.dart';
part 'profile_screen_scaffold.dart';
part 'profile_screen_tabs.dart';

class ProfileScreen extends ConsumerWidget {
  final String? user;
  final String? fallbackDisplayName;
  final String? fallbackAvatar;

  const ProfileScreen({
    super.key,
    this.user,
    this.fallbackDisplayName,
    this.fallbackAvatar,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authControllerProvider);

    if (auth is! AuthAuthenticated) {
      return const Scaffold(body: Center(child: Text('Not logged in')));
    }

    final currentUser = auth.user;
    final targetUser = _cleanUser(user).isNotEmpty
        ? _cleanUser(user)
        : _firstNonEmptyIdentity(<String>[
            currentUser.accountId,
            currentUser.email,
          ]);
    final isOwnProfile = _isCurrentIdentity(
      targetUser,
      accountId: currentUser.accountId,
      email: currentUser.email,
    );
    final colors = context.appColors;

    final request = _ProfileRequest(
      targetUser: targetUser,
      currentUserEmail: currentUser.email,
      currentAccountId: currentUser.accountId,
      currentDisplayName: currentUser.fullName,
      currentAvatar: currentUser.userImage,
      currentBio: currentUser.bio,
      currentIsVerified: currentUser.isVerified,
      fallbackDisplayName: fallbackDisplayName,
      fallbackAvatar: fallbackAvatar,
    );

    final profileAsync = ref.watch(_profileViewDataProvider(request));

    return profileAsync.when(
      loading: () {
        final fallback = _ProfileViewData.fallback(
          targetUser: targetUser,
          isOwnProfile: isOwnProfile,
          currentDisplayName: currentUser.fullName,
          currentAvatar: currentUser.userImage,
          currentBio: currentUser.bio,
          currentIsVerified: currentUser.isVerified,
          fallbackDisplayName: fallbackDisplayName,
          fallbackAvatar: fallbackAvatar,
        );

        return _ProfileScaffold(
          data: fallback,
          contentUser: request.targetUser,
          isLoading: true,
          onRefresh: () async {
            ref.invalidate(_profileViewDataProvider(request));
            ref.invalidate(accountsControllerProvider);
            await ref.read(_profileViewDataProvider(request).future);
          },
          onActivityTap: () => ActivityNavigation.toActivityCenter(context),
          onAvatarTap: () => _handleAvatarTap(context, ref, fallback, request),
          onEditTap: () => _showEditSheet(context, ref, fallback, request),
          onSellerStoreTap: null,
          onMessageTap: null,
          onFollowTap: null,
        );
      },
      error: (error, _) {
        final Failure? failure = error is Failure ? error : null;
        final bool profileUnavailable =
            failure?.error?.trim().toUpperCase() == 'PROFILE_UNAVAILABLE';
        final fallback = _ProfileViewData.fallback(
          targetUser: targetUser,
          isOwnProfile: isOwnProfile,
          currentDisplayName: currentUser.fullName,
          currentAvatar: currentUser.userImage,
          currentBio: currentUser.bio,
          currentIsVerified: currentUser.isVerified,
          fallbackDisplayName: fallbackDisplayName,
          fallbackAvatar: fallbackAvatar,
        );

        return Scaffold(
          backgroundColor: colors.surface,
          appBar: _ProfileAppBar(
            title: profileUnavailable ? 'Profile' : fallback.displayName,
            onActivityTap: () => ActivityNavigation.toActivityCenter(context),
            onMoreTap: fallback.isOwnProfile
                ? null
                : () => _showSafetySheet(context, fallback),
          ),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.person_search_rounded,
                    size: 40,
                    color: colors.textMuted,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    profileUnavailable
                        ? 'Profile unavailable'
                        : 'Failed to load profile.',
                    style: context.pStrong.copyWith(color: colors.textPrimary),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    failure?.message ?? 'Please try again.',
                    textAlign: TextAlign.center,
                    style: context.pMuted,
                  ),
                  if (!profileUnavailable) ...[
                    const SizedBox(height: 18),
                    TextButton(
                      onPressed: () =>
                          ref.invalidate(_profileViewDataProvider(request)),
                      child: const Text('Try again'),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
      data: (data) {
        return _ProfileScaffold(
          data: data,
          contentUser: request.targetUser,
          onRefresh: () async {
            ref.invalidate(_profileViewDataProvider(request));
            ref.invalidate(accountsControllerProvider);
            await ref.read(_profileViewDataProvider(request).future);
          },
          onActivityTap: () => ActivityNavigation.toActivityCenter(context),
          onAvatarTap: () => _handleAvatarTap(context, ref, data, request),
          onEditTap: () => _showEditSheet(context, ref, data, request),
          onSellerStoreTap: data.canVisitSellerStore
              ? () => SellerNavigation.toSellerStore(context, data.sellerId!)
              : null,
          onMessageTap: data.canInteract
              ? (tapContext) => ChatActions.startChat(
                  context: tapContext,
                  ref: ref,
                  user: data.user,
                  displayName: data.displayName,
                  avatar: data.avatarUrl,
                )
              : null,
          onFollowTap: data.canInteract
              ? (tapContext) async {
                  final res = await ref
                      .read(socialRepositoryProvider)
                      .toggleFollow(targetUser: data.user);

                  if (!tapContext.mounted) return;

                  if (res.isLeft) {
                    ShowSnack(
                      tapContext,
                      res.leftOrNull?.message ?? 'Failed to update follow.',
                    ).error();
                    return;
                  }

                  ref.invalidate(_profileViewDataProvider(request));
                  ref.invalidate(accountsControllerProvider);
                  await ref.read(_profileViewDataProvider(request).future);
                }
              : null,
        );
      },
    );
  }

  static String _cleanUser(String? value) => value?.trim() ?? '';

  static String _firstNonEmptyIdentity(Iterable<String> values) {
    for (final value in values) {
      final clean = value.trim();
      if (clean.isNotEmpty) return clean;
    }
    return '';
  }

  static bool _isCurrentIdentity(
    String target, {
    required String accountId,
    required String email,
  }) {
    final normalizedTarget = target.trim().toLowerCase();
    if (normalizedTarget.isEmpty) return false;

    return <String>[accountId, email]
        .map((value) => value.trim().toLowerCase())
        .where((value) => value.isNotEmpty)
        .contains(normalizedTarget);
  }

  static void _showEditSheet(
    BuildContext context,
    WidgetRef ref,
    _ProfileViewData data,
    _ProfileRequest request,
  ) {
    unawaited(
      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => ProfileEditSheet(
          initialFullName: data.displayName,
          initialBio: data.bio,
        ),
      ).then((_) {
        if (context.mounted) {
          ref.invalidate(_profileViewDataProvider(request));
          ref.invalidate(accountsControllerProvider);
        }
      }),
    );
  }

  static Future<void> _handleAvatarTap(
    BuildContext context,
    WidgetRef ref,
    _ProfileViewData data,
    _ProfileRequest request,
  ) async {
    if (data.isOwnProfile) {
      await _showAvatarPhotoPicker(
        context,
        ref,
        request,
        hasAvatar: data.avatarUrl?.trim().isNotEmpty ?? false,
        sellerId: data.sellerId,
      );
      return;
    }

    final liveId = data.liveId?.trim() ?? '';
    if (data.isLive && liveId.isNotEmpty) {
      LiveNavigation.toLiveRoom(context, liveId: liveId);
    }
  }

  static Future<void> _showAvatarPhotoPicker(
    BuildContext context,
    WidgetRef ref,
    _ProfileRequest request, {
    required bool hasAvatar,
    String? sellerId,
  }) async {
    final action = await showModalBottomSheet<_AvatarPhotoAction>(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        final colors = sheetContext.appColors;
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 42,
                  height: 5,
                  decoration: BoxDecoration(
                    color: colors.border,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                const SizedBox(height: 12),
                ListTile(
                  leading: Icon(
                    Icons.photo_library_outlined,
                    color: colors.primary,
                  ),
                  title: const Text('Upload photo'),
                  onTap: () =>
                      Navigator.pop(sheetContext, _AvatarPhotoAction.gallery),
                ),
                ListTile(
                  leading: Icon(
                    Icons.photo_camera_outlined,
                    color: colors.primary,
                  ),
                  title: const Text('Take photo'),
                  onTap: () =>
                      Navigator.pop(sheetContext, _AvatarPhotoAction.camera),
                ),
                if (hasAvatar)
                  ListTile(
                    leading: Icon(
                      Icons.delete_outline_rounded,
                      color: colors.primary,
                    ),
                    title: Text(sheetContext.l10n.profilePhotoRemoveAction),
                    onTap: () =>
                        Navigator.pop(sheetContext, _AvatarPhotoAction.remove),
                  ),
              ],
            ),
          ),
        );
      },
    );

    if (action == null || !context.mounted) return;

    if (action == _AvatarPhotoAction.remove) {
      await _removeAvatar(context, ref, request, sellerId: sellerId);
      return;
    }

    final acquisition = ref.read(mediaAcquisitionServiceProvider);
    final picked = switch (action) {
      _AvatarPhotoAction.camera => await acquisition.captureImage(
        context,
        useCase: MediaUseCase.profileImage,
      ),
      _AvatarPhotoAction.gallery => await acquisition.pickImage(
        useCase: MediaUseCase.profileImage,
      ),
      _AvatarPhotoAction.remove => null,
    };

    if (picked == null) return;
    if (!context.mounted) {
      await picked.discard();
      return;
    }

    ShowSnack(context, 'Uploading profile photo…').info();

    final uploadCoordinator = ref.read(mediaUploadCoordinatorProvider);
    final accountsApi = ref.read(accountsApiProvider);
    final mediaUploadApi = ref.read(mediaUploadApiProvider);

    try {
      final uploaded = await uploadCoordinator.upload(
        media: picked,
        useCase: MediaUseCase.profileImage,
      );

      if (!context.mounted) return;

      if (uploaded.isLeft) {
        ShowSnack(
          context,
          uploaded.leftOrNull?.message ?? 'Failed to upload profile photo.',
        ).error();
        return;
      }

      final media = uploaded.rightOrNull;
      if (media == null || media.mediaId.trim().isEmpty) {
        ShowSnack(context, 'Failed to upload profile photo.').error();
        return;
      }

      final update = await accountsApi.updateProfile(
        userImageMedia: media.mediaId,
      );

      if (update.isLeft) {
        unawaited(mediaUploadApi.deleteMedia(mediaId: media.mediaId));
        if (!context.mounted) return;
        ShowSnack(
          context,
          update.leftOrNull?.message ?? 'Failed to update profile photo.',
        ).error();
        return;
      }

      if (!context.mounted) return;

      final payload = update.rightOrNull ?? <String, dynamic>{};
      final message = asJsonMap(payload['message']);
      final data = asJsonMap(payload['data'] ?? message['data'] ?? payload);

      ref.read(authControllerProvider.notifier).setUserFromMap(data);
      ref.invalidate(_profileViewDataProvider(request));
      ref.invalidate(accountsControllerProvider);
      final cleanSellerId = sellerId?.trim() ?? '';
      if (cleanSellerId.isNotEmpty) {
        ref.invalidate(sellerStateProvider(cleanSellerId));
      }

      ShowSnack(context, 'Profile photo updated.').success();
    } catch (_) {
      if (!context.mounted) return;
      ShowSnack(context, 'Failed to update profile photo.').error();
    } finally {
      await picked.discard();
    }
  }

  static Future<void> _removeAvatar(
    BuildContext context,
    WidgetRef ref,
    _ProfileRequest request, {
    String? sellerId,
  }) async {
    final update = await ref
        .read(accountsApiProvider)
        .updateProfile(userImage: '');
    if (!context.mounted) return;

    if (update.isLeft) {
      ShowSnack(
        context,
        update.leftOrNull?.message ?? 'Failed to remove profile photo.',
      ).error();
      return;
    }

    final payload = update.rightOrNull ?? <String, dynamic>{};
    final message = asJsonMap(payload['message']);
    final data = asJsonMap(payload['data'] ?? message['data'] ?? payload);

    ref.read(authControllerProvider.notifier).setUserFromMap(data);
    ref.invalidate(_profileViewDataProvider(request));
    ref.invalidate(accountsControllerProvider);
    final cleanSellerId = sellerId?.trim() ?? '';
    if (cleanSellerId.isNotEmpty) {
      ref.invalidate(sellerStateProvider(cleanSellerId));
    }

    ShowSnack(context, context.l10n.profilePhotoRemoved).success();
  }

  static void _showSafetySheet(BuildContext context, _ProfileViewData data) {
    unawaited(
      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        builder: (_) => UserSafetySheet(
          targetUser: data.user,
          displayName: data.displayName,
        ),
      ),
    );
  }
}
