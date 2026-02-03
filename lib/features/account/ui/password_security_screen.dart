import 'package:africaonlinestores/ui/components/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:africaonlinestores/core/core.dart';
import 'package:africaonlinestores/core/utils/app_snack.dart';

import 'package:africaonlinestores/features/auth/providers/auth_controller.dart';
import 'package:africaonlinestores/ui/components/app_success_sheet.dart';
import 'package:africaonlinestores/ui/components/app_text_fields.dart';
import 'package:africaonlinestores/ui/components/buttons/primary_button.dart';

class PasswordSecurityScreen extends ConsumerStatefulWidget {
  const PasswordSecurityScreen({super.key});

  @override
  ConsumerState<PasswordSecurityScreen> createState() =>
      _PasswordSecurityScreenState();
}

class _PasswordSecurityScreenState
    extends ConsumerState<PasswordSecurityScreen> {
  int _tab = 0;

  final _formKey = GlobalKey<FormState>();
  final _old = TextEditingController();
  final _new = TextEditingController();
  final _confirm = TextEditingController();

  bool _loading = false;

  static const BorderRadius _pill = BorderRadius.all(Radius.circular(999));

  @override
  void dispose() {
    _old.dispose();
    _new.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();
    setState(() => _loading = true);
    try {
      final res = await ref
          .read(authControllerProvider.notifier)
          .changePassword(
            currentPassword: _old.text,
            newPassword: _new.text,
            confirmPassword: _confirm.text,
          );

      if (!mounted) return;

      await res.fold((f) async => ShowSnack(context, f.message).error(), (
        msg,
      ) async {
        _old.clear();
        _new.clear();
        _confirm.clear();

        final parentContext = context;

        await showModalBottomSheet(
          context: parentContext,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => AppSuccessSheet(
            title: 'Password Updated\nSuccessfully',
            message: msg,
            buttonText: 'Done',
            onPressed: () {
              if (!parentContext.mounted) return;
              Navigator.of(parentContext).pop();
              parentContext.go(AppRoutes.account);
            },
          ),
        );
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Widget _segmented() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: context.appColors.surface,
        borderRadius: _pill,
      ),
      child: Row(
        children: [
          Expanded(
            child: _SegmentButton(
              selected: _tab == 0,
              text: 'Change password',
              onTap: () => setState(() => _tab = 0),
            ),
          ),
          Expanded(
            child: _SegmentButton(
              selected: _tab == 1,
              text: 'Security',
              onTap: () => setState(() => _tab = 1),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Change Password', style: context.h4),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(AppRoutes.account);
            }
          },
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 18),
          child: Column(
            children: [
              _segmented(),
              const SizedBox(height: 16),
              Expanded(
                child: _tab == 0
                    ? SingleChildScrollView(
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 6),
                              AppPasswordFormField(
                                controller: _old,
                                label: 'Current Password',
                                validator: Validators.passwordRequired,
                                textInputAction: TextInputAction.next,
                                autofillHints: const [AutofillHints.password],
                              ),
                              const SizedBox(height: 8),

                              AppPasswordFormField(
                                controller: _new,
                                label: 'New Password',
                                validator: Validators.passwordRequired,
                                textInputAction: TextInputAction.next,
                                autofillHints: const [AutofillHints.password],
                              ),
                              const SizedBox(height: 8),

                              AppPasswordFormField(
                                controller: _confirm,
                                label: 'Confirm Password',
                                validator: (v) =>
                                    Validators.confirmPassword(v, _new.text),

                                textInputAction: TextInputAction.done,
                                autofillHints: const [AutofillHints.password],
                              ),
                              const SizedBox(height: 90),
                            ],
                          ),
                        ),
                      )
                    : const _SecurityPlaceholder(),
              ),
              SizedBox(
                height: 56,
                width: double.infinity,
                child: PrimaryButton(
                  text: 'Update',
                  onPressed: (_tab == 0 && !_loading) ? _submit : null,
                  loading: _loading,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SecurityPlaceholder extends StatelessWidget {
  const _SecurityPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Security settings coming soon.',
        style: TextStyle(color: context.appColors.textMuted),
      ),
    );
  }
}

class _SegmentButton extends StatelessWidget {
  const _SegmentButton({
    required this.selected,
    required this.text,
    required this.onTap,
  });

  final bool selected;
  final String text;
  final VoidCallback onTap;

  static const BorderRadius _pill = BorderRadius.all(Radius.circular(999));

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return InkWell(
      borderRadius: _pill,
      onTap: onTap,
      child: Container(
        height: 36,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? scheme.primary : Colors.transparent,
          borderRadius: _pill,
        ),
        child: selected
            ? Text(text, style: context.button)
            : Text(text, style: context.p),
      ),
    );
  }
}
