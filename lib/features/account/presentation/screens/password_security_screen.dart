import 'dart:async';

import 'package:africaonlinestores/core/core.dart';
import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/features/app_lock/application/app_lock_controller.dart';
import 'package:africaonlinestores/features/app_lock/domain/app_lock_models.dart';
import 'package:africaonlinestores/features/app_lock/presentation/widgets/app_lock_credential_sheet.dart';
import 'package:africaonlinestores/features/auth/shared/providers/auth_controller_provider.dart';
import 'package:africaonlinestores/l10n/gen/app_localizations.dart';
import 'package:africaonlinestores/shared/components/app_success_sheet.dart';
import 'package:africaonlinestores/shared/components/app_text_fields.dart';
import 'package:africaonlinestores/shared/components/buttons/primary_button.dart';
import 'package:africaonlinestores/shared/widgets/app_snack.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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

        await showModalBottomSheet<void>(
          context: parentContext,
          isScrollControlled: true,
          backgroundColor: context.appColors.surface,
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
              context.goNamed(AppRoutes.nAccount);
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
                    : const _AppLockSettings(),
              ),
              if (_tab == 0)
                SizedBox(
                  height: 56,
                  width: double.infinity,
                  child: PrimaryButton(
                    text: 'Update',
                    onPressed: !_loading ? _submit : null,
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

class _AppLockSettings extends ConsumerWidget {
  const _AppLockSettings();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations localizations = AppLocalizations.of(context);
    final AppLockState state = ref.watch(appLockControllerProvider);
    final AppLockController controller = ref.read(
      appLockControllerProvider.notifier,
    );
    final bool busy =
        state.phase == AppLockPhase.verifying ||
        state.phase == AppLockPhase.initializing;

    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: <Widget>[
        Text(
          localizations.appLockSettingTitle,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        Text(localizations.appLockSettingDescription),
        const SizedBox(height: 20),
        if (!state.isEnabled)
          _MethodButtons(
            busy: busy,
            onSelected: (AppLockMethod method) {
              unawaited(_configureMethod(context, controller, method));
            },
          )
        else ...<Widget>[
          Card(
            margin: EdgeInsets.zero,
            child: ListTile(
              leading: Icon(_methodIcon(state.preference.method!)),
              title: Text(localizations.appLockConfigured),
              subtitle: Text(
                _methodLabel(localizations, state.preference.method!),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            localizations.appLockTimingTitle,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 4),
          Text(localizations.appLockProcessRestartNote),
          const SizedBox(height: 8),
          RadioGroup<AppLockTimeout>(
            groupValue: state.preference.timeout,
            onChanged: (AppLockTimeout? value) {
              if (!busy && value != null) {
                unawaited(controller.setTimeout(value));
              }
            },
            child: Column(
              children: AppLockTimeout.values
                  .map(
                    (AppLockTimeout timeout) => RadioListTile<AppLockTimeout>(
                      contentPadding: EdgeInsets.zero,
                      value: timeout,
                      enabled: !busy,
                      title: Text(_timeoutLabel(localizations, timeout)),
                    ),
                  )
                  .toList(growable: false),
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: busy
                ? null
                : () {
                    unawaited(
                      _changeMethod(context, controller, state.preference),
                    );
                  },
            icon: const Icon(Icons.swap_horiz),
            label: Text(
              localizations.appLockChangeMethod,
              style: AppTextStylesX(
                context,
              ).button.copyWith(color: Theme.of(context).colorScheme.primary),
            ),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: busy
                ? null
                : () {
                    unawaited(_disable(context, controller, state.preference));
                  },
            style: OutlinedButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
              side: BorderSide(color: Theme.of(context).colorScheme.error),
            ),
            icon: const Icon(Icons.lock_open_outlined),
            label: Text(
              localizations.appLockDisable,
              style: AppTextStylesX(
                context,
              ).button.copyWith(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
        if (state.error != null && state.error != AppLockError.success) ...[
          const SizedBox(height: 12),
          Text(
            _appLockSettingsError(localizations, state.error!),
            textAlign: TextAlign.center,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ],
        if (busy) ...<Widget>[
          const SizedBox(height: 12),
          const LinearProgressIndicator(),
        ],
      ],
    );
  }

  static Future<void> _configureMethod(
    BuildContext context,
    AppLockController controller,
    AppLockMethod method,
  ) async {
    final AppLocalizations localizations = AppLocalizations.of(context);
    AppLockResult result;

    if (method == AppLockMethod.biometric) {
      result = await controller.configureBiometric(
        reason: localizations.appLockEnableReason,
      );
    } else {
      final AppLockCredentialInput? input = await showAppLockCredentialSheet(
        context: context,
        method: method,
        confirmCredential: true,
        labels: _sheetLabels(localizations),
      );
      if (input == null || !context.mounted) return;
      result = method == AppLockMethod.pin
          ? await controller.configurePin(input.pin!)
          : await controller.configurePattern(input.pattern!);
    }

    if (!context.mounted || result.isSuccess) return;
    ShowSnack(
      context,
      _appLockSettingsError(localizations, result.error),
    ).error();
  }

  static Future<void> _changeMethod(
    BuildContext context,
    AppLockController controller,
    AppLockPreference preference,
  ) async {
    final AppLockResult verified = await _verifyCurrent(
      context,
      controller,
      preference.method!,
    );
    if (!context.mounted || !verified.isSuccess) {
      if (context.mounted && verified.error != AppLockError.userCancelled) {
        final AppLocalizations localizations = AppLocalizations.of(context);
        ShowSnack(
          context,
          _appLockSettingsError(localizations, verified.error),
        ).error();
      }
      return;
    }

    final AppLockMethod? method = await _showMethodChooser(context);
    if (method == null || !context.mounted) return;
    await _configureMethod(context, controller, method);
  }

  static Future<void> _disable(
    BuildContext context,
    AppLockController controller,
    AppLockPreference preference,
  ) async {
    final AppLocalizations localizations = AppLocalizations.of(context);
    final AppLockMethod method = preference.method!;
    AppLockResult result;

    if (method == AppLockMethod.biometric) {
      result = await controller.disableWithBiometric(
        reason: localizations.appLockDisableReason,
      );
    } else {
      final AppLockCredentialInput? input = await showAppLockCredentialSheet(
        context: context,
        method: method,
        confirmCredential: false,
        labels: _sheetLabels(localizations),
      );
      if (input == null || !context.mounted) return;
      result = method == AppLockMethod.pin
          ? await controller.disableWithPin(input.pin!)
          : await controller.disableWithPattern(input.pattern!);
    }

    if (!context.mounted || result.isSuccess) return;
    ShowSnack(
      context,
      _appLockSettingsError(localizations, result.error),
    ).error();
  }

  static Future<AppLockResult> _verifyCurrent(
    BuildContext context,
    AppLockController controller,
    AppLockMethod method,
  ) async {
    final AppLocalizations localizations = AppLocalizations.of(context);
    if (method == AppLockMethod.biometric) {
      return controller.verifyBiometric(
        reason: localizations.appLockChangeReason,
      );
    }

    final AppLockCredentialInput? input = await showAppLockCredentialSheet(
      context: context,
      method: method,
      confirmCredential: false,
      labels: _sheetLabels(localizations),
    );
    if (input == null) {
      return const AppLockResult(AppLockError.userCancelled);
    }
    return method == AppLockMethod.pin
        ? controller.verifyPin(input.pin!)
        : controller.verifyPattern(input.pattern!);
  }

  static Future<AppLockMethod?> _showMethodChooser(BuildContext context) {
    final AppLocalizations localizations = AppLocalizations.of(context);
    return showModalBottomSheet<AppLockMethod>(
      context: context,
      useRootNavigator: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      builder: (BuildContext sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                localizations.appLockChooseMethod,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              for (final AppLockMethod method in AppLockMethod.values)
                ListTile(
                  leading: Icon(_methodIcon(method)),
                  title: Text(_methodLabel(localizations, method)),
                  onTap: () => Navigator.of(sheetContext).pop(method),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MethodButtons extends StatelessWidget {
  const _MethodButtons({required this.busy, required this.onSelected});

  final bool busy;
  final ValueChanged<AppLockMethod> onSelected;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations localizations = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(
          localizations.appLockChooseMethod,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        for (final AppLockMethod method in AppLockMethod.values) ...<Widget>[
          OutlinedButton.icon(
            onPressed: busy ? null : () => onSelected(method),
            icon: Icon(_methodIcon(method)),
            label: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                _methodLabel(localizations, method),
                style: AppTextStylesX(
                  context,
                ).button.copyWith(color: Theme.of(context).colorScheme.primary),
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
        Text(
          localizations.appLockMethodHelp,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

AppLockCredentialSheetLabels _sheetLabels(AppLocalizations localizations) {
  return AppLockCredentialSheetLabels(
    enterPin: localizations.appLockEnterPin,
    confirmPin: localizations.appLockConfirmPin,
    enterPattern: localizations.appLockEnterPattern,
    confirmPattern: localizations.appLockConfirmPattern,
    pinHelp: localizations.appLockPinHelp,
    patternHelp: localizations.appLockPatternHelp,
    continueLabel: localizations.appLockContinue,
    confirmLabel: localizations.appLockConfirm,
    cancelLabel: localizations.appLockCancel,
    clearLabel: localizations.appLockClear,
    invalidPin: localizations.appLockPinHelp,
    patternTooShort: localizations.appLockPatternHelp,
    confirmationMismatch: localizations.appLockConfirmationMismatch,
    pinAccessibilityLabel: localizations.appLockPinInputAccessibility,
    patternAccessibilityLabel: localizations.appLockPatternInputAccessibility,
    patternPointAccessibilityLabel:
        localizations.appLockPatternPointAccessibility,
  );
}

String _timeoutLabel(AppLocalizations localizations, AppLockTimeout timeout) {
  switch (timeout) {
    case AppLockTimeout.immediately:
      return localizations.appLockTimingImmediately;
    case AppLockTimeout.fiveSeconds:
      return localizations.appLockTimingFiveSeconds;
    case AppLockTimeout.tenSeconds:
      return localizations.appLockTimingTenSeconds;
    case AppLockTimeout.fifteenSeconds:
      return localizations.appLockTimingFifteenSeconds;
    case AppLockTimeout.thirtySeconds:
      return localizations.appLockTimingThirtySeconds;
  }
}

String _methodLabel(AppLocalizations localizations, AppLockMethod method) {
  switch (method) {
    case AppLockMethod.pin:
      return localizations.appLockMethodPin;
    case AppLockMethod.pattern:
      return localizations.appLockMethodPattern;
    case AppLockMethod.biometric:
      return localizations.appLockMethodBiometric;
  }
}

IconData _methodIcon(AppLockMethod method) {
  switch (method) {
    case AppLockMethod.pin:
      return Icons.dialpad;
    case AppLockMethod.pattern:
      return Icons.gesture;
    case AppLockMethod.biometric:
      return Icons.fingerprint;
  }
}

String _appLockSettingsError(
  AppLocalizations localizations,
  AppLockError error,
) {
  switch (error) {
    case AppLockError.noDeviceCredential:
    case AppLockError.notEnrolled:
      return localizations.appLockNoDeviceCredential;
    case AppLockError.hardwareUnavailable:
    case AppLockError.unsupported:
      return localizations.appLockUnsupported;
    case AppLockError.temporaryLockout:
      return localizations.appLockTemporaryLockout;
    case AppLockError.permanentLockout:
      return localizations.appLockPermanentLockout;
    case AppLockError.userCancelled:
    case AppLockError.systemCancelled:
    case AppLockError.backgroundInterrupted:
      return localizations.appLockCancelled;
    case AppLockError.invalidCredential:
      return localizations.appLockInvalidCredential;
    case AppLockError.invalidPin:
      return localizations.appLockPinHelp;
    case AppLockError.patternTooShort:
      return localizations.appLockPatternHelp;
    case AppLockError.confirmationMismatch:
      return localizations.appLockConfirmationMismatch;
    case AppLockError.storageFailure:
      return localizations.appLockStorageFailure;
    case AppLockError.success:
      return '';
    case AppLockError.authenticationFailed:
    case AppLockError.hardwareTemporarilyUnavailable:
    case AppLockError.alreadyInProgress:
    case AppLockError.unknown:
      return localizations.appLockFailed;
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
    final colors = context.appColors;

    return InkWell(
      borderRadius: _pill,
      onTap: onTap,
      child: Container(
        height: 36,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? colors.primary : colors.surface,
          borderRadius: _pill,
        ),
        child: Text(
          text,
          style: context.p.copyWith(
            color: selected ? colors.btnText : colors.textPrimary,
          ),
        ),
      ),
    );
  }
}
