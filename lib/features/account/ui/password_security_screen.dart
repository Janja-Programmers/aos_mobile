import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:africaonlinestores/core/core.dart';
import 'package:africaonlinestores/features/auth/providers/auth_controller.dart';
import 'package:africaonlinestores/ui/components/app_success_sheet.dart';
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
  bool _ob1 = true;
  bool _ob2 = true;
  bool _ob3 = true;

  static const BorderRadius _pill = BorderRadius.all(Radius.circular(999));

  @override
  void dispose() {
    _old.dispose();
    _new.dispose();
    _confirm.dispose();
    super.dispose();
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
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

      await res.fold((f) async => _snack(f.message), (msg) async {
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
        title: const Text('Change Password'),
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
                              const Text(
                                'Old password',
                                style: TextStyle(fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _old,
                                obscureText: _ob1,
                                decoration:
                                    InputDecoration(
                                      labelText: 'Enter your old password',
                                      suffixIcon: IconButton(
                                        onPressed: () =>
                                            setState(() => _ob1 = !_ob1),
                                        icon: Icon(
                                          _ob1
                                              ? Icons.visibility_off_outlined
                                              : Icons.visibility_outlined,
                                        ),
                                      ),
                                    ).applyDefaults(
                                      Theme.of(context).inputDecorationTheme,
                                    ),
                                validator: Validators.passwordRequired,
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'New password',
                                style: TextStyle(fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _new,
                                obscureText: _ob2,
                                decoration:
                                    InputDecoration(
                                      labelText: 'Enter your new password',
                                      suffixIcon: IconButton(
                                        onPressed: () =>
                                            setState(() => _ob2 = !_ob2),
                                        icon: Icon(
                                          _ob2
                                              ? Icons.visibility_off_outlined
                                              : Icons.visibility_outlined,
                                        ),
                                      ),
                                    ).applyDefaults(
                                      Theme.of(context).inputDecorationTheme,
                                    ),
                                validator: (v) =>
                                    Validators.minLen(v, 8, 'Min 8 characters'),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Confirm password',
                                style: TextStyle(fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _confirm,
                                obscureText: _ob3,
                                decoration:
                                    InputDecoration(
                                      labelText: 'Re enter your new password',
                                      suffixIcon: IconButton(
                                        onPressed: () =>
                                            setState(() => _ob3 = !_ob3),
                                        icon: Icon(
                                          _ob3
                                              ? Icons.visibility_off_outlined
                                              : Icons.visibility_outlined,
                                        ),
                                      ),
                                    ).applyDefaults(
                                      Theme.of(context).inputDecorationTheme,
                                    ),
                                validator: (v) => (v != _new.text)
                                    ? 'Passwords do not match'
                                    : null,
                                onFieldSubmitted: (_) => _submit(),
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
        child: Text(
          text,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: selected ? scheme.onPrimary : context.appColors.textMuted,
          ),
        ),
      ),
    );
  }
}
