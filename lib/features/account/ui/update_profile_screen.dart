import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import 'package:aos_mobile/core/config/app_config.dart';
import 'package:aos_mobile/core/core.dart';
import 'package:aos_mobile/core/providers.dart';
import 'package:aos_mobile/features/account/data/accounts_api.dart';
import 'package:aos_mobile/features/auth/providers/auth_controller.dart';

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

  AccountsApi get _api => ref.read(accountsApiProvider);

  Future<void> _load() async {
    setState(() => _loading = true);
    final res = await _api.getProfile();
    if (!mounted) return;

    if (res.isLeft) {
      setState(() => _loading = false);
      _snack(res.leftOrNull?.message ?? 'Failed to load profile.');
      return;
    }

    final payload = res.rightOrNull ?? <String, dynamic>{};
    final ok = payload['ok'] == true;
    if (!ok) {
      setState(() => _loading = false);
      _snack((payload['message'] ?? 'Failed to load profile.').toString());
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
      _snack('Full Name is required.');
      return;
    }

    setState(() => _saving = true);
    final res = await _api.updateProfile(fullName: name);
    if (!mounted) return;
    setState(() => _saving = false);

    if (res.isLeft) {
      _snack(res.leftOrNull?.message ?? 'Failed to update profile.');
      return;
    }

    final payload = res.rightOrNull ?? <String, dynamic>{};
    final ok = payload['ok'] == true;
    if (!ok) {
      _snack((payload['message'] ?? 'Failed to update profile.').toString());
      return;
    }

    final data = (payload['data'] is Map)
        ? Map<String, dynamic>.from(payload['data'] as Map)
        : <String, dynamic>{};

    // Keep auth user in sync for Account header.
    ref.read(authControllerProvider.notifier).setUserFromMap(data);

    _snack('Profile updated.');

    if (mounted) {
      context.go(AppRoutes.account);
    }
  }

  Future<void> _pickPhoto() async {
    if (_uploadingPhoto || _loading) return;

    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.photo_library_outlined),
                  title: const Text('Choose from gallery'),
                  onTap: () => Navigator.pop(ctx, ImageSource.gallery),
                ),
                ListTile(
                  leading: const Icon(Icons.photo_camera_outlined),
                  title: const Text('Take a photo'),
                  onTap: () => Navigator.pop(ctx, ImageSource.camera),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (source == null) return;

    final picker = ImagePicker();
    final xfile = await picker.pickImage(
      source: source,
      imageQuality: 85,
      maxWidth: 1200,
    );

    if (xfile == null) return;
    final file = File(xfile.path);

    // Optimistic UI: show local file immediately.
    setState(() {
      _uploadingPhoto = true;
      _localPhoto = file;
    });

    // 1) Upload file
    final auth = ref.read(authControllerProvider);
    final docname = auth.user?.email ?? '';
    if (docname.isEmpty) {
      if (mounted) {
        setState(() => _uploadingPhoto = false);
        _snack('You must be logged in to upload a photo.');
      }
      return;
    }

    final up = await _api.uploadProfilePhoto(file: file, docname: docname);
    if (!mounted) return;
    if (up.isLeft) {
      setState(() => _uploadingPhoto = false);
      setState(() => _localPhoto = null);
      _snack(up.leftOrNull?.message ?? 'Failed to upload image.');
      return;
    }

    final fileUrl = up.rightOrNull ?? '';
    if (fileUrl.isEmpty) {
      setState(() => _uploadingPhoto = false);
      setState(() => _localPhoto = null);
      _snack('Failed to upload image.');
      return;
    }

    // 2) Update profile user_image
    final res = await _api.updateProfile(userImage: fileUrl);
    if (!mounted) return;

    if (res.isLeft) {
      setState(() => _uploadingPhoto = false);
      setState(() => _localPhoto = null);
      _snack(res.leftOrNull?.message ?? 'Failed to update profile photo.');
      return;
    }

    final payload = res.rightOrNull ?? <String, dynamic>{};
    final ok = payload['ok'] == true;
    if (!ok) {
      setState(() => _uploadingPhoto = false);
      setState(() => _localPhoto = null);
      _snack(
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
    _snack('Profile photo updated.');
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider);
    final baseUrl = AppConfig.normalizedBaseUrl;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Update Profile'),
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
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CircleAvatar(
                          radius: 46,
                          backgroundColor: const Color(0xFFEDEDED),
                          backgroundImage: _localPhoto != null
                              ? FileImage(_localPhoto!)
                              : (_userImage.isNotEmpty
                                        ? NetworkImage('$baseUrl$_userImage')
                                        : (auth.user?.userImage.isNotEmpty ==
                                                  true
                                              ? NetworkImage(
                                                  '$baseUrl${auth.user!.userImage}',
                                                )
                                              : null))
                                    as ImageProvider<Object>?,
                          child:
                              (_localPhoto != null ||
                                  _userImage.isNotEmpty ||
                                  auth.user?.userImage.isNotEmpty == true)
                              ? null
                              : Text(
                                  (auth.user?.fullName.isNotEmpty == true)
                                      ? auth.user!.fullName
                                            .trim()
                                            .substring(0, 1)
                                            .toUpperCase()
                                      : 'U',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black,
                                  ),
                                ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: InkWell(
                            onTap: _pickPhoto,
                            borderRadius: BorderRadius.circular(99),
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(99),
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                              ),
                              child: _uploadingPhoto
                                  ? const Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Colors.white,
                                            ),
                                      ),
                                    )
                                  : const Icon(
                                      Icons.camera_alt_outlined,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  const Text(
                    'Full Name',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _nameCtrl,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 14,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: Color(0xFFE5E5E5)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: Color(0xFFE5E5E5)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: Colors.black),
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),
                  const Text(
                    'Email',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _emailCtrl,
                    readOnly: true,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFFF7F7F7),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 14,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: Color(0xFFE5E5E5)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: Color(0xFFE5E5E5)),
                      ),
                    ),
                  ),

                  const SizedBox(height: 34),
                  SizedBox(
                    height: 54,
                    child: ElevatedButton(
                      onPressed: (_saving || _uploadingPhoto) ? null : _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                      child: _saving
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : const Text(
                              'Update',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
