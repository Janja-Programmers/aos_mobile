import 'package:flutter/material.dart';

class AdStepper extends StatelessWidget {
  const AdStepper({
    super.key,
    required this.steps,
    required this.currentIndex,
    required this.completed,
  });

  final List<String> steps;
  final int currentIndex;
  final Set<int> completed;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: List.generate(steps.length, (i) {
          final isCurrent = i == currentIndex;
          final isDone = completed.contains(i);
          final circleColor = isDone || isCurrent ? scheme.primary : scheme.outlineVariant;
          final textColor = isDone || isCurrent ? scheme.primary : scheme.onSurfaceVariant;

          return Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 2,
                        color: i == 0 ? Colors.transparent : scheme.outlineVariant,
                      ),
                    ),
                    Container(
                      height: 28,
                      width: 28,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: scheme.surface,
                        border: Border.all(color: circleColor, width: 2),
                      ),
                      child: Center(
                        child: isDone
                            ? Icon(Icons.check, size: 16, color: circleColor)
                            : Text('${i + 1}', style: TextStyle(color: circleColor, fontWeight: FontWeight.w700)),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        height: 2,
                        color: i == steps.length - 1 ? Colors.transparent : scheme.outlineVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  steps[i],
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(color: textColor, fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
