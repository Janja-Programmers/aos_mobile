import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/core/utils/json_utils.dart';
import 'package:africaonlinestores/features/account/data/accounts_api.dart';
import 'package:africaonlinestores/features/account/domain/profile_update_request.dart';
import 'package:africaonlinestores/features/account/shared/providers/accounts_provider.dart';
import 'package:africaonlinestores/features/auth/domain/auth_state.dart';
import 'package:africaonlinestores/features/auth/shared/providers/auth_controller_provider.dart';
import 'package:africaonlinestores/shared/components/buttons/primary_button.dart';
import 'package:africaonlinestores/shared/widgets/app_snack.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfileEditSheet extends ConsumerStatefulWidget {
  final String? initialFullName;
  final String? initialBio;

  const ProfileEditSheet({super.key, this.initialFullName, this.initialBio});

  @override
  ConsumerState<ProfileEditSheet> createState() => _ProfileEditSheetState();
}

class _ProfileEditSheetState extends ConsumerState<ProfileEditSheet> {
  final _nameCtrl = TextEditingController();
  final _bioCtrl = TextEditingController();

  bool _saving = false;
  bool _seededControllers = false;
  String _initialName = '';
  String _initialBio = '';

  AccountsApi get _api => ref.read(accountsApiProvider);

  @override
  void initState() {
    super.initState();
    _seedControllers(ref.read(authControllerProvider));
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _bioCtrl.dispose();
    super.dispose();
  }

  void _seedControllers(AuthState auth) {
    if (_seededControllers) return;

    final authenticated = auth is AuthAuthenticated ? auth : null;
    final initialName = _firstNonEmpty([
      widget.initialFullName,
      authenticated?.user.fullName,
    ]);
    // An explicitly supplied empty bio is authoritative. Do not replace it
    // with an older auth-state bio just because it is empty.
    final initialBio = widget.initialBio != null
        ? widget.initialBio!.trim()
        : _firstNonEmpty([authenticated?.user.bio]);

    _nameCtrl.text = initialName;
    _bioCtrl.text = initialBio;
    _initialName = initialName;
    _initialBio = initialBio;
    _seededControllers = true;
  }

  Future<void> _save() async {
    if (_saving) return;

    final fullName = _nameCtrl.text.trim();
    final bio = _bioCtrl.text.trim();

    if (fullName.length < ProfileUpdateRequest.fullNameMinLength) {
      showAppSnack(
        context,
        'Please enter your name.',
        position: SnackPosition.top,
      );
      return;
    }

    if (fullName.length > ProfileUpdateRequest.fullNameMaxLength) {
      showAppSnack(
        context,
        'Name should be ${ProfileUpdateRequest.fullNameMaxLength} characters or less.',
        position: SnackPosition.top,
      );
      return;
    }

    if (bio.length > ProfileUpdateRequest.bioMaxLength) {
      showAppSnack(
        context,
        'Bio should be ${ProfileUpdateRequest.bioMaxLength} characters or less.',
        position: SnackPosition.top,
      );
      return;
    }

    final Map<String, dynamic> initialPayload = ProfileUpdateRequest(
      fullName: _initialName,
      bio: _initialBio,
    ).toJson();
    final Map<String, dynamic> currentPayload = ProfileUpdateRequest(
      fullName: fullName,
      bio: bio,
    ).toJson();

    final String currentName = (currentPayload['full_name'] ?? '').toString();
    final String initialName = (initialPayload['full_name'] ?? '').toString();
    final String currentBio = (currentPayload['bio'] ?? '').toString();
    final String initialBio = (initialPayload['bio'] ?? '').toString();

    final String? changedName = currentName == initialName ? null : currentName;
    final String? changedBio = currentBio == initialBio ? null : currentBio;

    // The backend update_profile contract is a partial update. Avoid sending
    // unchanged fields so editing one value can never overwrite another value
    // with stale form state.
    if (changedName == null && changedBio == null) {
      if (mounted) Navigator.pop(context);
      return;
    }

    setState(() => _saving = true);

    final res = await _api.updateProfile(
      fullName: changedName,
      bio: changedBio,
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

    final payload = res.rightOrNull ?? <String, dynamic>{};
    final message = asJsonMap(payload['message']);
    final data = asJsonMap(payload['data'] ?? message['data'] ?? payload);

    // update_profile returns the complete private profile. Use that backend
    // snapshot as the auth/profile source instead of locally merging fields.
    ref.read(authControllerProvider.notifier).setUserFromMap(data);

    showAppSnack(context, 'Profile updated.');

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    _seedControllers(ref.watch(authControllerProvider));

    final viewInsets = MediaQuery.viewInsetsOf(context);
    final maxHeight = MediaQuery.sizeOf(context).height * 0.92;

    return AnimatedPadding(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      padding: EdgeInsets.only(bottom: viewInsets.bottom),
      child: Container(
        constraints: BoxConstraints(maxHeight: maxHeight),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
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
                  child: Text('Edit profile', style: context.h2),
                ),

                const SizedBox(height: 24),

                TextField(
                  key: const Key('profile_edit_name_field'),
                  controller: _nameCtrl,
                  maxLength: ProfileUpdateRequest.fullNameMaxLength,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),

                const SizedBox(height: 20),

                TextField(
                  key: const Key('profile_edit_bio_field'),
                  controller: _bioCtrl,
                  minLines: 3,
                  maxLines: 5,
                  maxLength: ProfileUpdateRequest.bioMaxLength,
                  textInputAction: TextInputAction.newline,
                  decoration: const InputDecoration(
                    labelText: 'Bio',
                    hintText: 'Tell buyers and sellers a little about you',
                    alignLabelWithHint: true,
                  ),
                ),

                const SizedBox(height: 20),

                PrimaryButton(
                  key: const Key('profile_edit_save_button'),
                  text: 'Save',
                  loading: _saving,
                  onPressed: _save,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static String _firstNonEmpty(List<Object?> values) {
    for (final value in values) {
      final clean = value?.toString().trim();
      if (clean != null && clean.isNotEmpty && clean.toLowerCase() != 'null') {
        return clean;
      }
    }
    return '';
  }
}
