import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:africaonlinestores/core/config/app_config.dart';
import 'package:africaonlinestores/core/files/data/files_api_provider.dart';
import 'package:africaonlinestores/core/files/helpers/media_helper.dart';
import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/core/utils/normalize_image.dart';

import 'package:africaonlinestores/features/account/data/accounts_api.dart';
import 'package:africaonlinestores/features/account/presentation/widgets/editable_avator.dart';
import 'package:africaonlinestores/features/account/shared/providers/accounts_provider.dart';

import 'package:africaonlinestores/features/auth/domain/auth_state.dart';
import 'package:africaonlinestores/features/auth/shared/providers/auth_controller_provider.dart';

import 'package:africaonlinestores/shared/components/buttons/primary_button.dart';
import 'package:africaonlinestores/shared/widgets/app_snack.dart';

class ProfileEditSheet extends ConsumerStatefulWidget {
  const ProfileEditSheet({super.key});

  @override
  ConsumerState<ProfileEditSheet> createState() =>
      _ProfileEditSheetState();
}

class _ProfileEditSheetState
    extends ConsumerState<ProfileEditSheet> {
  final _nameCtrl = TextEditingController();
  final _bioCtrl = TextEditingController();

  bool _saving = false;
  bool _uploadingPhoto = false;

  String _userImage = '';
  File? _localPhoto;

  AccountsApi get _api => ref.read(accountsApiProvider);

  @override
  void initState() {
    super.initState();

    final auth = ref.read(authControllerProvider);

    if (auth is AuthAuthenticated) {
      _nameCtrl.text = auth.user.fullName;
      _bioCtrl.text = auth.user.bio ?? '';
      _userImage = auth.user.userImage;
    }
  }

  Future<void> _save() async {
    if (_saving) return;

    setState(() => _saving = true);

    final res = await _api.updateProfile(
      fullName: _nameCtrl.text.trim(),
      bio: _bioCtrl.text.trim(),
    );

    if (!mounted) return;

    setState(() => _saving = false);

    if (res.isLeft) {
      showAppSnack(
        context,
        res.leftOrNull?.message ?? 'Failed to update profile.',
      );
      return;
    }

    final payload = res.rightOrNull ?? {};
    final data = Map<String, dynamic>.from(payload['data'] ?? {});

    ref
        .read(authControllerProvider.notifier)
        .setUserFromMap(data);

    showAppSnack(context, 'Profile updated.');

    Navigator.pop(context);
  }

  Future<void> _pickPhoto() async {
    final file =
        await MediaHelper.pickImageWithChoice(context);

    if (file == null) return;

    final fixedFile =
        await normalizeImageOrientation(file);

    setState(() {
      _uploadingPhoto = true;
      _localPhoto = fixedFile;
    });

    final uploaded = await MediaHelper.uploadSingle(
      ref: ref,
      file: fixedFile,
      uploadFn: (f) =>
          ref.read(filesApiProvider).uploadMedia(file: f),
    );

    if (uploaded == null) {
      setState(() => _uploadingPhoto = false);

      if(mounted) showAppSnack(context, 'Upload failed');

      return;
    }

    final res = await _api.updateProfile(
      userImage: uploaded.url,
    );

    if (res.isLeft) {
      setState(() => _uploadingPhoto = false);

      if(mounted) showAppSnack(context, 'Failed to update image');

      return;
    }

    final payload = res.rightOrNull ?? {};
    final data = Map<String, dynamic>.from(payload['data']);

    ref
        .read(authControllerProvider.notifier)
        .setUserFromMap(data);

    setState(() {
      _uploadingPhoto = false;
      _userImage = uploaded.url;
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider);
    final authenticated =
        auth is AuthAuthenticated ? auth : null;

    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 14,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(28),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 42,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(20),
              ),
            ),

            const SizedBox(height: 22),

            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Edit profile',
                style: context.h2,
              ),
            ),

            const SizedBox(height: 24),

            EditableAvatar(
              baseUrl: AppConfig.normalizedBaseUrl,
              authFullName:
                  authenticated?.user.fullName ?? '',
              authUserImage:
                  authenticated?.user.userImage ?? '',
              apiUserImage: _userImage,
              localPhoto: _localPhoto,
              uploading: _uploadingPhoto,
              onTapCamera: _pickPhoto,
            ),

            const SizedBox(height: 24),

            TextField(
              controller: _nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Name',
              ),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: _bioCtrl,
              minLines: 3,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Bio',
                alignLabelWithHint: true,
              ),
            ),

            const SizedBox(height: 28),

            PrimaryButton(
              text: 'Save',
              loading: _saving,
              onPressed: _save,
            ),
          ],
        ),
      ),
    );
  }
}