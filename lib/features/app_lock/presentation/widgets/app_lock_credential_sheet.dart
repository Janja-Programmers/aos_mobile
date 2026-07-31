import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/features/app_lock/application/app_lock_controller.dart';
import 'package:africaonlinestores/features/app_lock/domain/app_lock_models.dart';
import 'package:africaonlinestores/features/app_lock/presentation/widgets/app_lock_inputs.dart';
import 'package:flutter/material.dart';

class AppLockCredentialInput {
  const AppLockCredentialInput.pin(this.pin) : pattern = null;
  const AppLockCredentialInput.pattern(this.pattern) : pin = null;

  final String? pin;
  final List<int>? pattern;
}

class AppLockCredentialSheetLabels {
  const AppLockCredentialSheetLabels({
    required this.enterPin,
    required this.confirmPin,
    required this.enterPattern,
    required this.confirmPattern,
    required this.pinHelp,
    required this.patternHelp,
    required this.continueLabel,
    required this.confirmLabel,
    required this.cancelLabel,
    required this.clearLabel,
    required this.invalidPin,
    required this.patternTooShort,
    required this.confirmationMismatch,
    required this.pinAccessibilityLabel,
    required this.patternAccessibilityLabel,
    required this.patternPointAccessibilityLabel,
  });

  final String enterPin;
  final String confirmPin;
  final String enterPattern;
  final String confirmPattern;
  final String pinHelp;
  final String patternHelp;
  final String continueLabel;
  final String confirmLabel;
  final String cancelLabel;
  final String clearLabel;
  final String invalidPin;
  final String patternTooShort;
  final String confirmationMismatch;
  final String pinAccessibilityLabel;
  final String patternAccessibilityLabel;
  final String patternPointAccessibilityLabel;
}

Future<AppLockCredentialInput?> showAppLockCredentialSheet({
  required BuildContext context,
  required AppLockMethod method,
  required bool confirmCredential,
  required AppLockCredentialSheetLabels labels,
}) {
  // ignore: prefer_asserts_with_message
  assert(method != AppLockMethod.biometric);
  return showModalBottomSheet<AppLockCredentialInput>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    builder: (BuildContext context) => AppLockCredentialSheet(
      method: method,
      confirmCredential: confirmCredential,
      labels: labels,
    ),
  );
}

class AppLockCredentialSheet extends StatefulWidget {
  const AppLockCredentialSheet({
    required this.method,
    required this.confirmCredential,
    required this.labels,
    super.key,
  });

  final AppLockMethod method;
  final bool confirmCredential;
  final AppLockCredentialSheetLabels labels;

  @override
  State<AppLockCredentialSheet> createState() => _AppLockCredentialSheetState();
}

class _AppLockCredentialSheetState extends State<AppLockCredentialSheet> {
  String _pin = '';
  String? _firstPin;
  List<int> _pattern = const <int>[];
  List<int>? _firstPattern;
  int _step = 0;
  int _patternResetToken = 0;
  String? _error;

  bool get _requiresConfirmation => widget.confirmCredential;
  bool get _isConfirmationStep => _requiresConfirmation && _step == 1;

  @override
  Widget build(BuildContext context) {
    final MediaQueryData media = MediaQuery.of(context);
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + media.viewInsets.bottom),
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text(
                  _title(),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  widget.method == AppLockMethod.pin
                      ? widget.labels.pinHelp
                      : widget.labels.patternHelp,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                if (widget.method == AppLockMethod.pin)
                  PinLockInput(
                    value: _pin,
                    clearLabel: widget.labels.clearLabel,
                    semanticsLabel: widget.labels.pinAccessibilityLabel,
                    onChanged: (String value) {
                      setState(() {
                        _pin = value;
                        _error = null;
                      });
                    },
                  )
                else
                  Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 340),
                      child: PatternLockInput(
                        clearLabel: widget.labels.clearLabel,
                        semanticsLabel: widget.labels.patternAccessibilityLabel,
                        pointSemanticsLabel:
                            widget.labels.patternPointAccessibilityLabel,
                        resetToken: _patternResetToken,
                        onCompleted: (List<int> value) {
                          setState(() {
                            _pattern = value;
                            _error = null;
                          });
                        },
                      ),
                    ),
                  ),
                if (_error != null) ...<Widget>[
                  const SizedBox(height: 12),
                  Semantics(
                    liveRegion: true,
                    child: Text(
                      _error!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: _submit,
                  child: Text(
                    _isConfirmationStep || !_requiresConfirmation
                        ? widget.labels.confirmLabel
                        : widget.labels.continueLabel,
                    style: AppTextStylesX(context).button,
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    widget.labels.cancelLabel,
                    style: AppTextStylesX(context).button.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _title() {
    if (widget.method == AppLockMethod.pin) {
      return _isConfirmationStep
          ? widget.labels.confirmPin
          : widget.labels.enterPin;
    }
    return _isConfirmationStep
        ? widget.labels.confirmPattern
        : widget.labels.enterPattern;
  }

  void _submit() {
    if (widget.method == AppLockMethod.pin) {
      _submitPin();
    } else {
      _submitPattern();
    }
  }

  void _submitPin() {
    if (!RegExp(r'^\d{4}$').hasMatch(_pin)) {
      setState(() => _error = widget.labels.invalidPin);
      return;
    }

    if (!_requiresConfirmation) {
      Navigator.of(context).pop(AppLockCredentialInput.pin(_pin));
      return;
    }

    if (_step == 0) {
      setState(() {
        _firstPin = _pin;
        _pin = '';
        _step = 1;
        _error = null;
      });
      return;
    }

    if (_pin != _firstPin) {
      setState(() {
        _error = widget.labels.confirmationMismatch;
        _pin = '';
      });
      return;
    }
    Navigator.of(context).pop(AppLockCredentialInput.pin(_pin));
  }

  void _submitPattern() {
    final List<int>? normalized = AppLockController.normalizePattern(_pattern);
    if (normalized == null) {
      setState(() => _error = widget.labels.patternTooShort);
      return;
    }

    if (!_requiresConfirmation) {
      Navigator.of(context).pop(AppLockCredentialInput.pattern(normalized));
      return;
    }

    if (_step == 0) {
      setState(() {
        _firstPattern = normalized;
        _pattern = const <int>[];
        _patternResetToken++;
        _step = 1;
        _error = null;
      });
      return;
    }

    if (!_listEquals(normalized, _firstPattern!)) {
      setState(() {
        _error = widget.labels.confirmationMismatch;
        _pattern = const <int>[];
        _patternResetToken++;
      });
      return;
    }
    Navigator.of(context).pop(AppLockCredentialInput.pattern(normalized));
  }

  bool _listEquals(List<int> left, List<int> right) {
    if (left.length != right.length) return false;
    for (int index = 0; index < left.length; index++) {
      if (left[index] != right[index]) return false;
    }
    return true;
  }
}
