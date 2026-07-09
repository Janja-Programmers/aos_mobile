import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/core/utils/json_utils.dart';
import 'package:africaonlinestores/features/account/data/accounts_api.dart';
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

  const ProfileEditSheet({
    super.key,
    this.initialFullName,
    this.initialBio,
  });

  @override
  ConsumerState<ProfileEditSheet> createState() => _ProfileEditSheetState();
}

class _ProfileEditSheetState extends ConsumerState<ProfileEditSheet> {
  final _nameCtrl = TextEditingController();
  final _bioCtrl = TextEditingController();

  bool _saving = false;
  bool _seededControllers = false;

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
    final initialBio = _firstNonEmpty([
      widget.initialBio,
      authenticated?.user.bio,
    ]);

    _nameCtrl.text = initialName;
    _bioCtrl.text = initialBio;
    _seededControllers = true;
  }

  Future<void> _save() async {
    if (_saving) return;

    final fullName = _nameCtrl.text.trim();
    final bio = _bioCtrl.text.trim();

    if (fullName.length < 2) {
      showAppSnack(context, 'Please enter your name.');
      return;
    }

    if (bio.length > 160) {
      showAppSnack(context, 'Bio should be 160 characters or less.');
      return;
    }

    setState(() => _saving = true);

    final res = await _api.updateProfile(fullName: fullName, bio: bio);

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
                  controller: _nameCtrl,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),

                const SizedBox(height: 20),

                TextField(
                  controller: _bioCtrl,
                  minLines: 3,
                  maxLines: 5,
                  maxLength: 160,
                  textInputAction: TextInputAction.newline,
                  decoration: const InputDecoration(
                    labelText: 'Bio',
                    hintText: 'Tell buyers and sellers a little about you',
                    alignLabelWithHint: true,
                  ),
                ),

                const SizedBox(height: 20),

                PrimaryButton(text: 'Save', loading: _saving, onPressed: _save),
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
