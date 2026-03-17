import 'package:flutter/material.dart';
import 'package:africaonlinestores/core/core.dart';
import 'package:africaonlinestores/core/theme/app_text_styles.dart';

class AdStepper extends StatelessWidget {
  const AdStepper({
    super.key,
    required this.steps,
    required this.currentIndex,
    required this.completed,
    required this.onStepTapped,
    required this.isStepAccessible,
  });

  final List<String> steps;
  final int currentIndex;
  final Set<int> completed;

  final void Function(int index) onStepTapped;
  final bool Function(int index) isStepAccessible;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final colors = context.appColors;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: List.generate(steps.length, (i) {
          final isCurrent = i == currentIndex;
          final isDone = completed.contains(i);
          final accessible = isStepAccessible(i);

          final circleColor = isDone || isCurrent
              ? scheme.primary
              : colors.border;

          final iconTextColor = isDone || isCurrent
              ? colors.white
              : colors.black;

          final textColor = isDone || isCurrent
              ? colors.primary
              : colors.textPrimary;

          final connectorColor = isDone
              ? scheme.primary
              : scheme.primaryFixedDim;

          return Expanded(
            child: GestureDetector(
              onTap: accessible ? () => onStepTapped(i) : null,
              child: Opacity(
                opacity: accessible ? 1 : 0.45,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        // Connector line (full width)
                        if (i != steps.length - 1)
                          Positioned.fill(
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: Container(
                                height: 2,
                                margin: const EdgeInsets.only(left: 14),
                                color: connectorColor,
                              ),
                            ),
                          ),

                        // Circle
                        Container(
                          height: 28,
                          width: 28,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: circleColor,
                            border: Border.all(color: circleColor, width: 2),
                          ),
                          child: Center(
                            child: isDone
                                ? Icon(
                                    Icons.check,
                                    size: 16,
                                    color: iconTextColor,
                                  )
                                : Text(
                                    '${i + 1}',
                                    style: context.p.copyWith(
                                      color: iconTextColor,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      steps[i],
                      style: context.p.copyWith(
                        color: textColor,
                        fontWeight: isCurrent
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
