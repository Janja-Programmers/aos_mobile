import 'dart:async';

import 'package:africaonlinestores/core/routing/helpers/app_routes.dart';
import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/features/app_lock/application/app_lock_controller.dart';
import 'package:africaonlinestores/features/app_lock/domain/app_lock_models.dart';
import 'package:africaonlinestores/features/app_lock/presentation/widgets/app_lock_inputs.dart';
import 'package:africaonlinestores/features/auth/domain/auth_state.dart';
import 'package:africaonlinestores/features/auth/shared/providers/auth_controller_provider.dart';
import 'package:africaonlinestores/features/notifications/application/providers/notification_providers.dart';
import 'package:africaonlinestores/l10n/gen/app_localizations.dart';
import 'package:africaonlinestores/shared/components/app_confirm_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class AppLockScreen extends ConsumerStatefulWidget {
  const AppLockScreen({super.key});

  @override
  ConsumerState<AppLockScreen> createState() => _AppLockScreenState();
}

class _AppLockScreenState extends ConsumerState<AppLockScreen> {
  String _pin = '';
  List<int> _pattern = const <int>[];
  int _patternResetToken = 0;
  bool _biometricRequested = false;
  bool _resetting = false;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations localizations = AppLocalizations.of(context);
    final AppLockState lockState = ref.watch(appLockControllerProvider);
    final bool isVerifying = lockState.phase == AppLockPhase.verifying;
    final AppLockMethod? method = lockState.preference.method;

    if (method == AppLockMethod.biometric &&
        lockState.phase == AppLockPhase.locked &&
        !_biometricRequested) {
      _biometricRequested = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) unawaited(_unlockBiometric());
      });
    }

    return Material(
      color: Theme.of(context).colorScheme.surface,
      child: SafeArea(
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: (constraints.maxHeight - 48)
                      .clamp(0, double.infinity)
                      .toDouble(),
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: Semantics(
                      container: true,
                      label: localizations.appLockScreenAccessibilityLabel,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          ExcludeSemantics(
                            child: Image.asset(
                              'assets/images/logo_redone.png',
                              width: 84,
                              height: 84,
                              errorBuilder: (_, _, _) =>
                                  const Icon(Icons.lock_outline, size: 64),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            localizations.appLockTitle,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _prompt(localizations, method),
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          if (lockState.error != null) ...<Widget>[
                            const SizedBox(height: 10),
                            Semantics(
                              liveRegion: true,
                              child: Text(
                                _errorText(localizations, lockState.error!),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.error,
                                ),
                              ),
                            ),
                          ],
                          const SizedBox(height: 24),
                          if (method == AppLockMethod.pin)
                            PinLockInput(
                              value: _pin,
                              clearLabel: localizations.appLockClear,
                              semanticsLabel:
                                  localizations.appLockPinInputAccessibility,
                              enabled: !isVerifying && !_resetting,
                              onChanged: (String value) {
                                setState(() => _pin = value);
                                if (value.length ==
                                    AppLockController.pinLength) {
                                  unawaited(_unlockPin(value));
                                }
                              },
                            )
                          else if (method == AppLockMethod.pattern)
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 340),
                              child: PatternLockInput(
                                clearLabel: localizations.appLockClear,
                                semanticsLabel: localizations
                                    .appLockPatternInputAccessibility,
                                pointSemanticsLabel: localizations
                                    .appLockPatternPointAccessibility,
                                enabled: !isVerifying && !_resetting,
                                resetToken: _patternResetToken,
                                onCompleted: (List<int> pattern) {
                                  setState(() => _pattern = pattern);
                                },
                              ),
                            )
                          else if (method == AppLockMethod.biometric)
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton.icon(
                                onPressed: isVerifying || _resetting
                                    ? null
                                    : () {
                                        unawaited(_unlockBiometric());
                                      },
                                icon: isVerifying
                                    ? const SizedBox.square(
                                        dimension: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Icon(Icons.fingerprint),
                                label: Text(
                                  isVerifying
                                      ? localizations.appLockAuthenticating
                                      : localizations.appLockUseBiometrics,
                                  style: AppTextStylesX(context).button,
                                ),
                              ),
                            ),
                          if (method == null)
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton(
                                onPressed: isVerifying || _resetting
                                    ? null
                                    : () {
                                        unawaited(_retryInitialization());
                                      },
                                child: Text(
                                  localizations.appLockTryAgain,
                                  style: AppTextStylesX(context).button,
                                ),
                              ),
                            ),
                          if (method == AppLockMethod.pattern) ...<Widget>[
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton(
                                onPressed:
                                    !isVerifying &&
                                        !_resetting &&
                                        _pattern.length >=
                                            AppLockController
                                                .minimumPatternPoints
                                    ? () {
                                        unawaited(_unlockPattern(_pattern));
                                      }
                                    : null,
                                child: Text(
                                  localizations.appLockUnlock,
                                  style: AppTextStylesX(context).button,
                                ),
                              ),
                            ),
                          ],
                          const SizedBox(height: 16),
                          TextButton(
                            onPressed: isVerifying || _resetting
                                ? null
                                : () {
                                    unawaited(_resetAppLock());
                                  },
                            child: Text(
                              localizations.appLockReset,
                              style: AppTextStylesX(context).button.copyWith(
                                color: Theme.of(context).colorScheme.error,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            localizations.appLockResetHelp,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _retryInitialization() async {
    final AuthState authState = ref.read(authControllerProvider);
    final AppLockController controller = ref.read(
      appLockControllerProvider.notifier,
    );
    await controller.handleAuthState(authState);
  }

  Future<void> _unlockPin(String pin) async {
    final AppLockResult result = await ref
        .read(appLockControllerProvider.notifier)
        .unlockWithPin(pin);
    if (!mounted) return;
    if (!result.isSuccess) setState(() => _pin = '');
  }

  Future<void> _unlockPattern(List<int> pattern) async {
    final AppLockResult result = await ref
        .read(appLockControllerProvider.notifier)
        .unlockWithPattern(pattern);
    if (!mounted) return;
    if (!result.isSuccess) {
      setState(() {
        _pattern = const <int>[];
        _patternResetToken++;
      });
    }
  }

  Future<void> _unlockBiometric() async {
    final AppLocalizations localizations = AppLocalizations.of(context);
    final AppLockResult result = await ref
        .read(appLockControllerProvider.notifier)
        .unlockWithBiometric(reason: localizations.appLockUnlockReason);
    if (!mounted) return;
    if (!result.isSuccess) setState(() => _biometricRequested = false);
  }

  Future<void> _resetAppLock() async {
    final AppLocalizations localizations = AppLocalizations.of(context);
    final bool? confirmed = await showModalBottomSheet<bool>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext sheetContext) => AppConfirmSheet(
        icon: Icons.restart_alt,
        iconBg: Theme.of(sheetContext).colorScheme.error,
        title: localizations.appLockResetTitle,
        message: localizations.appLockResetMessage,
        primaryText: localizations.appLockResetConfirm,
        secondaryText: localizations.appLockCancel,
        onPrimary: () => Navigator.of(sheetContext).pop(true),
        onSecondary: () => Navigator.of(sheetContext).pop(false),
      ),
    );
    if (confirmed != true || !mounted) return;

    final AppLockController appLockController = ref.read(
      appLockControllerProvider.notifier,
    );
    final authController = ref.read(authControllerProvider.notifier);
    setState(() => _resetting = true);
    ref.read(protectedNavigationCoordinatorProvider).clear();
    try {
      await appLockController.resetForLogout();
    } finally {
      await authController.logout();
    }
    if (!mounted) return;
    context.go(AppRoutes.home);
  }

  String _prompt(AppLocalizations localizations, AppLockMethod? method) {
    switch (method) {
      case AppLockMethod.pin:
        return localizations.appLockEnterPin;
      case AppLockMethod.pattern:
        return localizations.appLockEnterPattern;
      case AppLockMethod.biometric:
        return localizations.appLockBiometricPrompt;
      case null:
        return localizations.appLockPrompt;
    }
  }

  String _errorText(AppLocalizations localizations, AppLockError error) {
    switch (error) {
      case AppLockError.invalidCredential:
        return localizations.appLockInvalidCredential;
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
      case AppLockError.hardwareTemporarilyUnavailable:
      case AppLockError.alreadyInProgress:
        return localizations.appLockTryAgain;
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
      case AppLockError.unknown:
        return localizations.appLockFailed;
    }
  }
}
