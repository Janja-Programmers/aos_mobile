import 'dart:async';

import 'package:africaonlinestores/core/api/api_response.dart';
import 'package:africaonlinestores/core/api/failure.dart';
import 'package:africaonlinestores/core/utils/either.dart';
import 'package:africaonlinestores/core/core.dart';
import 'package:africaonlinestores/core/media/data/media_upload_api_provider.dart';
import 'package:africaonlinestores/core/media/domain/media_upload_purpose.dart';
import 'package:africaonlinestores/core/media/helpers/media_helper.dart';
import 'package:africaonlinestores/core/providers.dart';
import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/core/utils/json_utils.dart';
import 'package:africaonlinestores/core/utils/normalize_image.dart';
import 'package:africaonlinestores/features/account/domain/account_profile_snapshot.dart';
import 'package:africaonlinestores/features/account/presentation/widgets/profile_edit_sheet.dart';
import 'package:africaonlinestores/features/account/shared/providers/accounts_controller.dart';
import 'package:africaonlinestores/features/account/shared/providers/accounts_provider.dart';
import 'package:africaonlinestores/features/activity/navigation/activity_navigation.dart';
import 'package:africaonlinestores/features/ads/shared/utils/file_url.dart';
import 'package:africaonlinestores/features/auth/domain/auth_state.dart';
import 'package:africaonlinestores/features/auth/shared/providers/auth_controller_provider.dart';
import 'package:africaonlinestores/features/connect/chats/utils/chat_actions.dart';
import 'package:africaonlinestores/features/live/navigation/live_routes.dart';
import 'package:africaonlinestores/features/sellers/navigation/seller_routes.dart';
import 'package:africaonlinestores/features/shorts/shared/data/mappers/short_mapper.dart';
import 'package:africaonlinestores/features/shorts/shared/data/models/short_model.dart';
import 'package:africaonlinestores/features/shorts/shared/domain/entities/short.dart';
import 'package:africaonlinestores/features/shorts/shared/navigation/shorts_routes.dart';
import 'package:africaonlinestores/features/social/application/providers/social_providers.dart';
import 'package:africaonlinestores/features/social/application/state/social_connections_state.dart';
import 'package:africaonlinestores/features/social/navigation/social_navigation.dart';
import 'package:africaonlinestores/features/social/safety/presentation/widgets/user_safety_sheet.dart';
import 'package:africaonlinestores/shared/components/verified_badge.dart';
import 'package:africaonlinestores/shared/utils/helpers.dart';
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
        : currentUser.email.trim();
    final isOwnProfile = _sameUser(targetUser, currentUser.email);
    final colors = context.appColors;

    final request = _ProfileRequest(
      targetUser: targetUser,
      currentUserEmail: currentUser.email,
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
        final String errorMessage = error is Failure
            ? error.message
            : 'Please try again.';
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
            title: fallback.displayName,
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
                    'Failed to load profile.',
                    style: context.pStrong.copyWith(color: colors.textPrimary),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    errorMessage,
                    textAlign: TextAlign.center,
                    style: context.pMuted,
                  ),
                  const SizedBox(height: 18),
                  TextButton(
                    onPressed: () =>
                        ref.invalidate(_profileViewDataProvider(request)),
                    child: const Text('Try again'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      data: (data) {
        return _ProfileScaffold(
          data: data,
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
          onMessageTap: data.canMessage
              ? (tapContext) => ChatActions.startChat(
                  context: tapContext,
                  ref: ref,
                  user: data.user,
                  displayName: data.displayName,
                  avatar: data.avatarUrl,
                )
              : null,
          onFollowTap: data.canToggleFollow
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

  static bool _sameUser(String a, String b) {
    return a.trim().toLowerCase() == b.trim().toLowerCase();
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
    final liveId = data.liveId?.trim() ?? '';
    if (data.isLive && liveId.isNotEmpty) {
      LiveNavigation.toLiveRoom(context, liveId: liveId);
      return;
    }

    if (!data.isOwnProfile) return;

    await _showAvatarPhotoPicker(context, ref, request);
  }

  static Future<void> _showAvatarPhotoPicker(
    BuildContext context,
    WidgetRef ref,
    _ProfileRequest request,
  ) async {
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
              ],
            ),
          ),
        );
      },
    );

    if (action == null || !context.mounted) return;

    final picked = action == _AvatarPhotoAction.camera
        ? await MediaHelper.pickImageFromCamera()
        : await MediaHelper.pickImageFromGallery();

    if (picked == null || !context.mounted) return;

    ShowSnack(context, 'Uploading profile photo…').info();

    try {
      final fixed = await normalizeImageOrientation(picked);
      final uploaded = await ref
          .read(mediaUploadApiProvider)
          .uploadMedia(file: fixed, purpose: MediaUploadPurpose.profileImage);

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

      final update = await ref
          .read(accountsApiProvider)
          .updateProfile(userImageMedia: media.mediaId);

      if (!context.mounted) return;

      if (update.isLeft) {
        ShowSnack(
          context,
          update.leftOrNull?.message ?? 'Failed to update profile photo.',
        ).error();
        return;
      }

      final payload = update.rightOrNull ?? <String, dynamic>{};
      final message = asJsonMap(payload['message']);
      final data = asJsonMap(payload['data'] ?? message['data'] ?? payload);

      ref.read(authControllerProvider.notifier).setUserFromMap(data);
      ref.invalidate(_profileViewDataProvider(request));
      ref.invalidate(accountsControllerProvider);

      ShowSnack(context, 'Profile photo updated.').success();
    } catch (_) {
      if (!context.mounted) return;
      ShowSnack(context, 'Failed to update profile photo.').error();
    }
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
