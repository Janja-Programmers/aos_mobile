import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:africaonlinestores/core/config/app_config.dart';
import 'package:africaonlinestores/core/core.dart';
import 'package:africaonlinestores/core/files/data/files_api_provider.dart';
import 'package:africaonlinestores/core/files/helpers/media_helper.dart';
import 'package:africaonlinestores/core/utils/normalize_image.dart';
import 'package:africaonlinestores/core/theme/app_text_styles.dart';

import 'package:africaonlinestores/features/account/presentation/widgets/editable_avator.dart';
import 'package:africaonlinestores/features/account/data/accounts_api.dart';
import 'package:africaonlinestores/features/account/shared/providers/accounts_provider.dart';

import 'package:africaonlinestores/features/auth/domain/auth_state.dart';
import 'package:africaonlinestores/features/auth/shared/providers/auth_controller_provider.dart';

import 'package:africaonlinestores/shared/components/buttons/primary_button.dart';

import 'package:africaonlinestores/shared/widgets/app_snack.dart';

class UpdateProfileScreen extends ConsumerStatefulWidget {
  const UpdateProfileScreen({super.key});

  @override
  ConsumerState<UpdateProfileScreen> createState() =>
      _UpdateProfileScreenState();
}

class _UpdateProfileScreenState extends ConsumerState<UpdateProfileScreen> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();

  bool _loading = true;
  bool _saving = false;
  bool _uploadingPhoto = false;

  String _userImage = '';
  File? _localPhoto;

  AccountsApi get _api => ref.read(accountsApiProvider);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    setState(() => _loading = true);

    final res = await _api.getProfile();
    if (!mounted) return;

    if (res.isLeft) {
      setState(() => _loading = false);
      showAppSnack(
        context,
        res.leftOrNull?.message ?? 'Failed to load profile.',
      );
      return;
    }

    final payload = res.rightOrNull ?? <String, dynamic>{};
    final ok = payload['ok'] == true;
    if (!ok) {
      setState(() => _loading = false);
      showAppSnack(
        context,
        (payload['message'] ?? 'Failed to load profile.').toString(),
      );
      return;
    }

    final data = (payload['data'] is Map)
        ? Map<String, dynamic>.from(payload['data'] as Map)
        : <String, dynamic>{};

    _nameCtrl.text = (data['full_name'] ?? '').toString();
    _emailCtrl.text = (data['email'] ?? '').toString();
    _userImage = (data['user_image'] ?? '').toString();

    setState(() => _loading = false);
  }

  Future<void> _save() async {
    if (_saving || _loading) return;

    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      showAppSnack(context, 'Full Name is required.');
      return;
    }

    setState(() => _saving = true);

    final res = await _api.updateProfile(fullName: name);
    if (!mounted) return;

    setState(() => _saving = false);

    if (res.isLeft) {
      showAppSnack(
        context,
        res.leftOrNull?.message ?? 'Failed to update profile.',
      );
      return;
    }

    final payload = res.rightOrNull ?? <String, dynamic>{};
    final ok = payload['ok'] == true;
    if (!ok) {
      showAppSnack(
        context,
        (payload['message'] ?? 'Failed to update profile.').toString(),
      );
      return;
    }

    final data = (payload['data'] is Map)
        ? Map<String, dynamic>.from(payload['data'] as Map)
        : <String, dynamic>{};

    // Keep auth user in sync for Account header.
    ref.read(authControllerProvider.notifier).setUserFromMap(data);

    showAppSnack(context, 'Profile updated.');

    if (mounted) context.goNamed(AppRoutes.nAccount);
  }

  void _resetUploadState() {
    if (!mounted) return;
    setState(() {
      _uploadingPhoto = false;
      _localPhoto = null;
    });
  }

  Future<void> _pickPhoto() async {
    if (_uploadingPhoto || _loading) return;

    final file = await MediaHelper.pickImageWithChoice(context);
    if (file == null) return;

    final fixedFile = await normalizeImageOrientation(file);

    if (!mounted) return;
    setState(() {
      _uploadingPhoto = true;
      _localPhoto = fixedFile;
    });

    final auth = ref.read(authControllerProvider);

    if (auth is! AuthAuthenticated) {
      _resetUploadState();
      showAppSnack(context, 'You must be logged in.');
      return;
    }

    final uploaded = await MediaHelper.uploadSingle(
      ref: ref,
      file: fixedFile,
      uploadFn: (f) => ref.read(filesApiProvider).uploadMedia(file: f),
    );

    if (!mounted) return;

    if (uploaded == null) {
      _resetUploadState();
      showAppSnack(context, 'Failed to upload image.');
      return;
    }

    showAppSnack(context, 'Profile photo updated.');

    final url = uploaded.url;

    if (url.isEmpty) {
      _resetUploadState();
      showAppSnack(context, 'Failed to upload image.');
      return;
    }

    if (url.isEmpty) {
      _resetUploadState();
      showAppSnack(context, 'Failed to upload image.');
      return;
    }

    final res = await _api.updateProfile(userImage: url);

    if (!mounted) return;

    if (res.isLeft) {
      _resetUploadState();
      showAppSnack(
        context,
        res.leftOrNull?.message ?? 'Failed to update profile photo.',
      );
      return;
    }

    final payload = res.rightOrNull ?? {};
    final data = Map<String, dynamic>.from(payload['data'] ?? {});

    setState(() {
      _userImage = (data['user_image'] ?? url).toString();
      _uploadingPhoto = false;
      _localPhoto = null;
    });

    ref.read(authControllerProvider.notifier).setUserFromMap(data);

    showAppSnack(context, 'Profile photo updated.');
  }

  InputDecoration _decor(
    BuildContext context, {
    required String label,
    Widget? suffix,
  }) {
    return InputDecoration(
      labelText: label,
      suffixIcon: suffix,
    ).applyDefaults(Theme.of(context).inputDecorationTheme);
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider);
    final authenticated = auth is AuthAuthenticated ? auth : null;

    final baseUrl = AppConfig.normalizedBaseUrl;

    final colors = context.appColors;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Update Profile', style: context.h3),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
                children: [
                  const SizedBox(height: 8),

                  Center(
                    child: EditableAvatar(
                      baseUrl: baseUrl,
                      authFullName: authenticated?.user.fullName ?? '',
                      authUserImage: authenticated?.user.userImage ?? '',
                      apiUserImage: _userImage,
                      localPhoto: _localPhoto,
                      uploading: _uploadingPhoto,
                      onTapCamera: _pickPhoto,
                    ),
                  ),

                  const SizedBox(height: 24),
                  TextField(
                    controller: _nameCtrl,
                    textInputAction: TextInputAction.next,
                    decoration: _decor(context, label: 'Full name'),
                  ),

                  const SizedBox(height: 24),
                  TextField(
                    controller: _emailCtrl,
                    readOnly: true,
                    decoration: _decor(
                      context,
                      label: 'Email',
                      suffix: Icon(
                        Icons.lock_outline,
                        color: colors.primary,
                        size: 18,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                  PrimaryButton(
                    text: 'Save Changes',
                    onPressed: (_saving || _uploadingPhoto) ? null : _save,
                    loading: _saving,
                  ),
                ],
              ),
            ),
    );
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }
}
