import 'dart:io';

import 'package:africaonlinestores/features/account/ui/widgets/editable_avator.dart';
import 'package:africaonlinestores/ui/components/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import 'package:africaonlinestores/core/config/app_config.dart';
import 'package:africaonlinestores/core/core.dart';
import 'package:africaonlinestores/core/providers.dart';
import 'package:africaonlinestores/core/utils/normalize_image.dart';

import 'package:africaonlinestores/features/account/data/accounts_api.dart';
import 'package:africaonlinestores/features/auth/providers/auth_controller.dart';
import 'package:africaonlinestores/ui/components/buttons/primary_button.dart';

import 'package:africaonlinestores/core/utils/app_snack.dart';

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

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
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

  Future<void> _pickPhoto() async {
    if (_uploadingPhoto || _loading) return;

    // NOTE: Do not store/capture BuildContext across async gaps.
    final source = await _showPhotoSourceSheet(context);
    if (source == null) return;

    final picker = ImagePicker();
    final xfile = await picker.pickImage(
      source: source,
      imageQuality: 85,
      maxWidth: 1200,
    );
    if (xfile == null) return;

    final file = File(xfile.path);
    final fixedFile = await normalizeImageOrientation(file);

    // Optimistic UI: show local file immediately.
    if (!mounted) return;
    setState(() {
      _uploadingPhoto = true;
      _localPhoto = fixedFile;
    });

    final auth = ref.read(authControllerProvider);
    final docname = auth.user?.email ?? '';
    if (docname.isEmpty) {
      if (!mounted) return;
      setState(() {
        _uploadingPhoto = false;
        _localPhoto = null;
      });
      showAppSnack(context, 'You must be logged in to upload a photo.');
      return;
    }

    // 1) Upload file
    final up = await _api.uploadProfilePhoto(file: fixedFile, docname: docname);
    if (!mounted) return;

    if (up.isLeft) {
      setState(() {
        _uploadingPhoto = false;
        _localPhoto = null;
      });
      showAppSnack(
        context,
        up.leftOrNull?.message ?? 'Failed to upload image.',
      );
      return;
    }

    final fileUrl = up.rightOrNull ?? '';
    if (fileUrl.isEmpty) {
      setState(() {
        _uploadingPhoto = false;
        _localPhoto = null;
      });
      showAppSnack(context, 'Failed to upload image.');
      return;
    }

    // 2) Update profile user_image
    final res = await _api.updateProfile(userImage: fileUrl);
    if (!mounted) return;

    if (res.isLeft) {
      setState(() {
        _uploadingPhoto = false;
        _localPhoto = null;
      });
      showAppSnack(
        context,
        res.leftOrNull?.message ?? 'Failed to update profile photo.',
      );
      return;
    }

    final payload = res.rightOrNull ?? <String, dynamic>{};
    final ok = payload['ok'] == true;
    if (!ok) {
      setState(() {
        _uploadingPhoto = false;
        _localPhoto = null;
      });
      showAppSnack(
        context,
        (payload['message'] ?? 'Failed to update profile photo.').toString(),
      );
      return;
    }

    final data = (payload['data'] is Map)
        ? Map<String, dynamic>.from(payload['data'] as Map)
        : <String, dynamic>{};

    setState(() {
      _userImage = (data['user_image'] ?? fileUrl).toString();
      _uploadingPhoto = false;
      _localPhoto = null;
    });

    ref.read(authControllerProvider.notifier).setUserFromMap(data);
    showAppSnack(context, 'Profile photo updated.');
  }

  Future<ImageSource?> _showPhotoSourceSheet(BuildContext context) async {
    final scheme = Theme.of(context).colorScheme;

    return showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: scheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.photo_library_outlined),
                  title: const Text('Choose from gallery'),
                  onTap: () => Navigator.pop(sheetContext, ImageSource.gallery),
                ),
                ListTile(
                  leading: const Icon(Icons.photo_camera_outlined),
                  title: const Text('Take a photo'),
                  onTap: () => Navigator.pop(sheetContext, ImageSource.camera),
                ),
              ],
            ),
          ),
        );
      },
    );
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
                      authFullName: auth.user?.fullName ?? '',
                      authUserImage: auth.user?.userImage ?? '',
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
}
