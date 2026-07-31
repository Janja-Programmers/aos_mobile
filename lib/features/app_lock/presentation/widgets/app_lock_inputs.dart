import 'dart:math' as math;

import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';

class PinLockInput extends StatelessWidget {
  const PinLockInput({
    required this.value,
    required this.onChanged,
    required this.clearLabel,
    required this.semanticsLabel,
    super.key,
    this.enabled = true,
  });

  final String value;
  final ValueChanged<String> onChanged;
  final String clearLabel;
  final String semanticsLabel;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Semantics(
          label: semanticsLabel,
          liveRegion: true,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List<Widget>.generate(4, (int index) {
              final bool filled = index < value.length;
              return Container(
                width: 18,
                height: 18,
                margin: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: filled
                      ? Theme.of(context).colorScheme.primary
                      : Colors.transparent,
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outline,
                    width: 1.5,
                  ),
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: 24),
        GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 1.35,
          children: <Widget>[
            for (int digit = 1; digit <= 9; digit++)
              _PinKey(
                label: digit.toString(),
                enabled: enabled && value.length < 4,
                onPressed: () => onChanged('$value$digit'),
              ),
            TextButton(
              onPressed: enabled && value.isNotEmpty
                  ? () => onChanged('')
                  : null,
              child: Text(
                clearLabel,
                style: AppTextStylesX(
                  context,
                ).button.copyWith(color: Theme.of(context).colorScheme.primary),
              ),
            ),
            _PinKey(
              label: '0',
              enabled: enabled && value.length < 4,
              onPressed: () => onChanged('${value}0'),
            ),
            IconButton(
              tooltip: MaterialLocalizations.of(context).deleteButtonTooltip,
              onPressed: enabled && value.isNotEmpty
                  ? () => onChanged(value.substring(0, value.length - 1))
                  : null,
              icon: const Icon(Icons.backspace_outlined),
            ),
          ],
        ),
      ],
    );
  }
}

class _PinKey extends StatelessWidget {
  const _PinKey({
    required this.label,
    required this.enabled,
    required this.onPressed,
  });

  final String label;
  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: OutlinedButton(
        onPressed: enabled ? onPressed : null,
        style: OutlinedButton.styleFrom(shape: const CircleBorder()),
        child: Text(
          label,
          style: AppTextStylesX(
            context,
          ).button.copyWith(color: Theme.of(context).colorScheme.primary),
        ),
      ),
    );
  }
}

class PatternLockInput extends StatefulWidget {
  const PatternLockInput({
    required this.onCompleted,
    required this.clearLabel,
    required this.semanticsLabel,
    required this.pointSemanticsLabel,
    super.key,
    this.enabled = true,
    this.resetToken = 0,
  });

  final ValueChanged<List<int>> onCompleted;
  final String clearLabel;
  final String semanticsLabel;
  final String pointSemanticsLabel;
  final bool enabled;
  final int resetToken;

  @override
  State<PatternLockInput> createState() => _PatternLockInputState();
}

class _PatternLockInputState extends State<PatternLockInput> {
  final List<int> _selected = <int>[];
  Offset? _pointer;

  @override
  void didUpdateWidget(covariant PatternLockInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.resetToken != widget.resetToken) {
      _clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color primary = Theme.of(context).colorScheme.primary;
    final Color outline = Theme.of(context).colorScheme.outline;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Semantics(
          container: true,
          label: widget.semanticsLabel,
          liveRegion: true,
          child: AspectRatio(
            aspectRatio: 1,
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                final Size size = Size.square(constraints.maxWidth);
                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onPanStart: widget.enabled
                      ? (DragStartDetails details) {
                          _pointer = details.localPosition;
                          _addPointForPosition(details.localPosition, size);
                        }
                      : null,
                  onPanUpdate: widget.enabled
                      ? (DragUpdateDetails details) {
                          setState(() => _pointer = details.localPosition);
                          _addPointForPosition(details.localPosition, size);
                        }
                      : null,
                  onPanEnd: widget.enabled
                      ? (_) {
                          _pointer = null;
                          widget.onCompleted(List<int>.unmodifiable(_selected));
                          setState(() {});
                        }
                      : null,
                  child: Stack(
                    fit: StackFit.expand,
                    children: <Widget>[
                      CustomPaint(
                        painter: _PatternPainter(
                          selected: List<int>.unmodifiable(_selected),
                          pointer: _pointer,
                          primary: primary,
                          outline: outline,
                        ),
                      ),
                      for (int point = 0; point < 9; point++)
                        _PatternPointButton(
                          point: point,
                          selected: _selected.contains(point),
                          enabled: widget.enabled,
                          semanticsLabel: widget.pointSemanticsLabel,
                          onTap: () {
                            _addPoint(point);
                            widget.onCompleted(
                              List<int>.unmodifiable(_selected),
                            );
                          },
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 8),
        TextButton.icon(
          onPressed: widget.enabled && _selected.isNotEmpty ? _clear : null,
          icon: const Icon(Icons.refresh),
          label: Text(
            widget.clearLabel,
            style: AppTextStylesX(
              context,
            ).button.copyWith(color: Theme.of(context).colorScheme.primary),
          ),
        ),
      ],
    );
  }

  void _addPointForPosition(Offset position, Size size) {
    final double cell = size.width / 3;
    final int column = (position.dx / cell).floor().clamp(0, 2).toInt();
    final int row = (position.dy / cell).floor().clamp(0, 2).toInt();
    final int point = row * 3 + column;
    final Offset center = Offset((column + 0.5) * cell, (row + 0.5) * cell);
    if ((position - center).distance <= cell * 0.34) {
      _addPoint(point);
    }
  }

  void _addPoint(int point) {
    if (!widget.enabled || _selected.contains(point)) return;
    setState(() => _selected.add(point));
  }

  void _clear() {
    if (!mounted) return;
    setState(() {
      _selected.clear();
      _pointer = null;
    });
  }
}

class _PatternPointButton extends StatelessWidget {
  const _PatternPointButton({
    required this.point,
    required this.selected,
    required this.enabled,
    required this.semanticsLabel,
    required this.onTap,
  });

  final int point;
  final bool selected;
  final bool enabled;
  final String semanticsLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final int row = point ~/ 3;
    final int column = point % 3;
    return Align(
      alignment: Alignment(-2 / 3 + column * 2 / 3, -2 / 3 + row * 2 / 3),
      child: Semantics(
        button: true,
        selected: selected,
        label: '$semanticsLabel ${point + 1}',
        child: SizedBox.square(
          dimension: 56,
          child: InkResponse(
            onTap: enabled ? onTap : null,
            radius: 28,
            child: const SizedBox.expand(),
          ),
        ),
      ),
    );
  }
}

class _PatternPainter extends CustomPainter {
  const _PatternPainter({
    required this.selected,
    required this.pointer,
    required this.primary,
    required this.outline,
  });

  final List<int> selected;
  final Offset? pointer;
  final Color primary;
  final Color outline;

  @override
  void paint(Canvas canvas, Size size) {
    final double cell = size.width / 3;
    Offset centerFor(int point) {
      final int row = point ~/ 3;
      final int column = point % 3;
      return Offset((column + 0.5) * cell, (row + 0.5) * cell);
    }

    final Paint linePaint = Paint()
      ..color = primary
      ..strokeWidth = math.max(3.0, size.width * 0.012)
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    if (selected.length > 1) {
      final Path path = Path()
        ..moveTo(centerFor(selected.first).dx, centerFor(selected.first).dy);
      for (final int point in selected.skip(1)) {
        final Offset center = centerFor(point);
        path.lineTo(center.dx, center.dy);
      }
      canvas.drawPath(path, linePaint);
    }

    if (selected.isNotEmpty && pointer != null) {
      canvas.drawLine(centerFor(selected.last), pointer!, linePaint);
    }

    for (int point = 0; point < 9; point++) {
      final bool active = selected.contains(point);
      final Offset center = centerFor(point);
      canvas.drawCircle(
        center,
        cell * 0.12,
        Paint()
          ..color = active ? primary : Colors.transparent
          ..style = PaintingStyle.fill,
      );
      canvas.drawCircle(
        center,
        cell * 0.12,
        Paint()
          ..color = active ? primary : outline
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _PatternPainter oldDelegate) =>
      !_samePoints(oldDelegate.selected, selected) ||
      oldDelegate.pointer != pointer ||
      oldDelegate.primary != primary ||
      oldDelegate.outline != outline;

  bool _samePoints(List<int> left, List<int> right) {
    if (left.length != right.length) return false;
    for (int index = 0; index < left.length; index++) {
      if (left[index] != right[index]) return false;
    }
    return true;
  }
}
