import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:aos_mobile/core/core.dart';
import 'package:aos_mobile/core/theme/app_colors.dart';
import 'package:aos_mobile/core/theme/app_theme.dart';
import 'package:aos_mobile/features/auth/providers/auth_controller.dart';
import 'package:aos_mobile/shared/widgets/app_success_sheet.dart';

class PasswordSecurityScreen extends ConsumerStatefulWidget {
  const PasswordSecurityScreen({super.key});

  @override
  ConsumerState<PasswordSecurityScreen> createState() =>
      _PasswordSecurityScreenState();
}

class _PasswordSecurityScreenState
    extends ConsumerState<PasswordSecurityScreen> {
  int _tab = 0; // 0=change password, 1=security

  final _formKey = GlobalKey<FormState>();
  final _old = TextEditingController();
  final _new = TextEditingController();
  final _confirm = TextEditingController();

  bool _loading = false;
  bool _ob1 = true;
  bool _ob2 = true;
  bool _ob3 = true;

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

        await showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => AppSuccessSheet(
            title: 'Password Updated\nSuccessfully',
            message: msg,
            buttonText: 'Done',
            onPressed: () {
              context.go(AppRoutes.account);
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
        color: const Color(0xFFF3F3F3),
        borderRadius: BorderRadius.circular(999),
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
      backgroundColor: AppColors.bg,
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
                                decoration: AppTheme.inputDecoration(
                                  label: 'Enter your old password',
                                  suffixIcon: IconButton(
                                    onPressed: () =>
                                        setState(() => _ob1 = !_ob1),
                                    icon: Icon(
                                      _ob1
                                          ? Icons.visibility_off_outlined
                                          : Icons.visibility_outlined,
                                    ),
                                  ),
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
                                decoration: AppTheme.inputDecoration(
                                  label: 'Enter your new password',
                                  suffixIcon: IconButton(
                                    onPressed: () =>
                                        setState(() => _ob2 = !_ob2),
                                    icon: Icon(
                                      _ob2
                                          ? Icons.visibility_off_outlined
                                          : Icons.visibility_outlined,
                                    ),
                                  ),
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
                                decoration: AppTheme.inputDecoration(
                                  label: 'Re enter your new password',
                                  suffixIcon: IconButton(
                                    onPressed: () =>
                                        setState(() => _ob3 = !_ob3),
                                    icon: Icon(
                                      _ob3
                                          ? Icons.visibility_off_outlined
                                          : Icons.visibility_outlined,
                                    ),
                                  ),
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
                    : _SecurityPlaceholder(),
              ),

              SizedBox(
                height: 56,
                width: double.infinity,
                child: AppTheme.primaryButton(
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
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Security settings coming soon.',
        style: TextStyle(color: Colors.black54),
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

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: Container(
        height: 36,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? Colors.black : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : AppColors.muted,
          ),
        ),
      ),
    );
  }
}
