import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:flutter/material.dart';

class UserVerificationStepper extends StatelessWidget {
  const UserVerificationStepper({
    super.key,
    required this.currentStep,
    required this.completedSteps,
    required this.onStepTapped,
    required this.isStepAccessible,
  });

  final int currentStep;
  final Set<int> completedSteps;
  final ValueChanged<int> onStepTapped;
  final bool Function(int step) isStepAccessible;

  static const int _stepCount = 4;
  static const double _buttonExtent = 52;

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];

    for (var index = 0; index < _stepCount; index++) {
      final completed = completedSteps.contains(index);
      final accessible = isStepAccessible(index);

      children.add(
        _StepButton(
          index: index,
          active: index == currentStep,
          completed: completed,
          accessible: accessible,
          onTap: () => onStepTapped(index),
        ),
      );

      if (index < _stepCount - 1) {
        children.add(Expanded(child: _StepConnector(completed: completed)));
      }
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 22),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 346),
          child: Row(children: children),
        ),
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({
    required this.index,
    required this.active,
    required this.completed,
    required this.accessible,
    required this.onTap,
  });

  final int index;
  final bool active;
  final bool completed;
  final bool accessible;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final background = active
        ? colors.primary
        : completed
        ? colors.success
        : colors.elevated;
    final foreground = completed || active ? colors.white : colors.textMuted;

    return Semantics(
      button: true,
      enabled: accessible,
      selected: active,
      label: 'Verification step ${index + 1}',
      child: Opacity(
        opacity: accessible ? 1 : 0.45,
        child: Material(
          color: Colors.transparent,
          child: InkResponse(
            onTap: accessible ? onTap : null,
            radius: 28,
            child: SizedBox.square(
              dimension: UserVerificationStepper._buttonExtent,
              child: Center(
                child: Container(
                  width: 44,
                  height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: background,
                  ),
                  child: completed && !active
                      ? Icon(Icons.check_rounded, color: foreground, size: 25)
                      : Text(
                          '${index + 1}',
                          style: context.pStrong.copyWith(
                            color: foreground,
                            fontSize: 17,
                          ),
                        ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StepConnector extends StatelessWidget {
  const _StepConnector({required this.completed});

  final bool completed;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      height: 4,
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        color: completed ? colors.success : colors.border,
        borderRadius: BorderRadius.circular(99),
      ),
    );
  }
}
