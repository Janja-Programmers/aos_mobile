import 'package:africaonlinestores/core/routing/helpers/app_routes.dart';
import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:africaonlinestores/features/account/data/account_lifecycle_api.dart';
import 'package:africaonlinestores/features/auth/shared/providers/auth_controller_provider.dart';
import 'package:africaonlinestores/shared/widgets/app_snack.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class DeleteAccountScreen extends ConsumerStatefulWidget {
  const DeleteAccountScreen({super.key});

  @override
  ConsumerState<DeleteAccountScreen> createState() =>
      _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends ConsumerState<DeleteAccountScreen> {
  final _confirmationController = TextEditingController();
  final _reasonController = TextEditingController();
  bool _loading = false;

  bool get _canDelete => _confirmationController.text.trim() == 'DELETE';

  @override
  void initState() {
    super.initState();
    _confirmationController.addListener(_onConfirmationChanged);
  }

  @override
  void dispose() {
    _confirmationController.removeListener(_onConfirmationChanged);
    _confirmationController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  void _onConfirmationChanged() {
    if (!mounted) return;
    setState(() {});
  }

  Future<void> _submit() async {
    if (!_canDelete) {
      ShowSnack(context, 'Type DELETE to confirm.').error();
      return;
    }

    setState(() => _loading = true);
    final res = await ref
        .read(accountLifecycleApiProvider)
        .deleteAccount(
          confirmation: _confirmationController.text,
          reason: _reasonController.text,
        );
    if (!mounted) return;
    setState(() => _loading = false);

    res.fold((f) => ShowSnack(context, f.message).error(), (msg) async {
      ShowSnack(context, msg).success();
      await ref.read(authControllerProvider.notifier).logout();
      if (mounted) context.go(AppRoutes.login);
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Scaffold(
      backgroundColor: colors.surface,
      body: SafeArea(
        child: ListView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          children: [
            const _DeleteAccountAppBar(),
            const SizedBox(height: 18),
            const _DeleteAccountHero(),
            const SizedBox(height: 20),
            Text(
              'Delete your account?',
              textAlign: TextAlign.center,
              style: context.h5.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Text(
              'This is a serious action. Please read the details\n'
              'below before continuing.',
              textAlign: TextAlign.center,
              style: context.smallMuted.copyWith(height: 1.4),
            ),
            const SizedBox(height: 20),
            const _DeleteAccountWarningCard(),
            const SizedBox(height: 22),
            _ReasonField(controller: _reasonController),
            const SizedBox(height: 18),
            _ConfirmationField(controller: _confirmationController),
            const SizedBox(height: 26),
            _DeleteAccountButton(
              enabled: _canDelete,
              loading: _loading,
              onPressed: _submit,
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: _loading
                  ? null
                  : () => Navigator.of(context).maybePop(),
              style: TextButton.styleFrom(
                foregroundColor: colors.textPrimary,
                textStyle: context.small.copyWith(fontWeight: FontWeight.w500),
              ),
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }
}

class _DeleteAccountAppBar extends StatelessWidget {
  const _DeleteAccountAppBar();

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return SizedBox(
      height: 44,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Material(
              color: colors.surfaceBright,
              shape: CircleBorder(side: BorderSide(color: colors.border)),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: () => Navigator.of(context).maybePop(),
                child: SizedBox(
                  width: 38,
                  height: 38,
                  child: Icon(
                    Icons.arrow_back_rounded,
                    size: 20,
                    color: colors.textPrimary,
                  ),
                ),
              ),
            ),
          ),
          Text(
            'Delete Account',
            style: context.h6.copyWith(fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}

class _DeleteAccountHero extends StatelessWidget {
  const _DeleteAccountHero();

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Center(
      child: Container(
        width: 68,
        height: 68,
        decoration: BoxDecoration(
          color: colors.error.withValues(alpha: 0.12),
          shape: BoxShape.circle,
        ),
        child: Icon(Icons.warning_amber_rounded, size: 38, color: colors.error),
      ),
    );
  }
}

class _DeleteAccountWarningCard extends StatelessWidget {
  const _DeleteAccountWarningCard();

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: colors.primary.withValues(alpha: 0.055),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.primary.withValues(alpha: 0.24)),
      ),
      child: const Column(
        children: [
          _WarningRow(
            icon: Icons.pause_circle_outline_rounded,
            text:
                'Your account and listings will be\n'
                'deactivated and hidden immediately.',
          ),
          SizedBox(height: 12),
          _WarningRow(
            icon: Icons.restore_rounded,
            text:
                'You have 30 days to restore it by logging\n'
                'in and verifying your email.',
          ),
          SizedBox(height: 12),
          _WarningRow(
            icon: Icons.delete_outline_rounded,
            text:
                'After 30 days, your account and data\n'
                'are permanently deleted and cannot be\n'
                'recovered.',
          ),
        ],
      ),
    );
  }
}

class _WarningRow extends StatelessWidget {
  const _WarningRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 1),
          child: Icon(icon, size: 18, color: colors.error),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: context.small.copyWith(
              height: 1.35,
              color: colors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

class _ReasonField extends StatelessWidget {
  const _ReasonField({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return _FieldBlock(
      label: const Text('Reason for leaving (optional)'),
      child: TextField(
        controller: controller,
        minLines: 2,
        maxLines: 4,
        textInputAction: TextInputAction.newline,
        decoration: _fieldDecoration(
          context,
          hintText: "Help us improve — tell us why you're\nleaving",
        ),
      ),
    );
  }
}

class _ConfirmationField extends StatelessWidget {
  const _ConfirmationField({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return _FieldBlock(
      label: Text.rich(
        TextSpan(
          text: 'Type ',
          children: [
            TextSpan(
              text: 'DELETE',
              style: TextStyle(color: colors.primary),
            ),
            const TextSpan(text: ' to confirm'),
          ],
        ),
      ),
      child: TextField(
        controller: controller,
        textCapitalization: TextCapitalization.characters,
        textInputAction: TextInputAction.done,
        autocorrect: false,
        enableSuggestions: false,
        decoration: _fieldDecoration(context, hintText: 'DELETE'),
        onSubmitted: (_) {
          if (controller.text.trim() == 'DELETE') {
            FocusScope.of(context).unfocus();
          }
        },
      ),
    );
  }
}

class _FieldBlock extends StatelessWidget {
  const _FieldBlock({required this.label, required this.child});

  final Widget label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DefaultTextStyle(
          style: context.small.copyWith(fontWeight: FontWeight.w800),
          child: label,
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}

InputDecoration _fieldDecoration(
  BuildContext context, {
  required String hintText,
}) {
  final colors = context.appColors;
  final border = OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: BorderSide(color: colors.border),
  );

  return InputDecoration(
    hintText: hintText,
    hintStyle: context.pMuted.copyWith(
      fontWeight: FontWeight.w400,
      height: 1.35,
    ),
    filled: true,
    fillColor: colors.surfaceBright,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
    border: border,
    enabledBorder: border,
    focusedBorder: border.copyWith(
      borderSide: BorderSide(color: colors.primary.withValues(alpha: 0.42)),
    ),
  );
}

class _DeleteAccountButton extends StatelessWidget {
  const _DeleteAccountButton({
    required this.enabled,
    required this.loading,
    required this.onPressed,
  });

  final bool enabled;
  final bool loading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final isDisabled = !enabled || loading;

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: isDisabled ? null : onPressed,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: colors.primary,
          foregroundColor: colors.white,
          disabledBackgroundColor: colors.primary.withValues(alpha: 0.24),
          disabledForegroundColor: colors.white.withValues(alpha: 0.88),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
        ),
        child: loading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(colors.white),
                ),
              )
            : Text('Delete my account', style: AppTextStylesX(context).button),
      ),
    );
  }
}
