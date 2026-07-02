import 'package:africaonlinestores/core/core.dart';
import 'package:flutter/material.dart';

class VerificationStepper extends StatelessWidget {
  const VerificationStepper({
    super.key,
    required this.totalSteps,
    required this.currentIndex,
    required this.completed,
    required this.onStepTapped,
    required this.isStepAccessible,
  });

  final int totalSteps;
  final int currentIndex;
  final Set<int> completed;

  final void Function(int index) onStepTapped;
  final bool Function(int index) isStepAccessible;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(totalSteps, (i) {
          final isCurrent = i == currentIndex;

          /// ✅ Only previous completed steps are visually done.
          final isDone = completed.contains(i) && i < currentIndex;

          final accessible = isStepAccessible(i);

          return Row(
            children: [
              GestureDetector(
                onTap: accessible ? () => onStepTapped(i) : null,
                child: Opacity(
                  opacity: accessible ? 1 : 0.4,
                  child: _buildCircle(context, i, isCurrent, isDone),
                ),
              ),

              if (i != totalSteps - 1) _buildConnector(context, isDone),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildCircle(
    BuildContext context,
    int index,
    bool isCurrent,
    bool isDone,
  ) {
    final colors = context.appColors;

    final bgColor = isCurrent
        ? colors.primary
        : isDone
        ? colors.success
        : colors.border;

    final contentColor = isCurrent || isDone
        ? colors.white
        : colors.textPrimary;

    return Container(
      width: 32,
      height: 32,
      alignment: Alignment.center,
      decoration: BoxDecoration(shape: BoxShape.circle, color: bgColor),
      child: isDone
          ? Icon(Icons.check, size: 18, color: contentColor)
          : Text(
              '${index + 1}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: contentColor,
              ),
            ),
    );
  }

  Widget _buildConnector(BuildContext context, bool isDone) {
    final colors = context.appColors;

    return Container(
      width: 36,
      height: 2,
      margin: const EdgeInsets.symmetric(horizontal: 6),
      color: isDone ? colors.success : colors.border,
    );
  }
}
