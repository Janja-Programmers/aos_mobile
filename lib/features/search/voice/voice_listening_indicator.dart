import 'package:flutter/material.dart';
import 'package:africaonlinestores/core/core.dart';

class VoiceListeningIndicator extends StatefulWidget {
  const VoiceListeningIndicator({super.key});

  @override
  State<VoiceListeningIndicator> createState() =>
      _VoiceListeningIndicatorState();
}

class _VoiceListeningIndicatorState extends State<VoiceListeningIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildCircle(double size, double opacity) {
    final colors = context.appColors;

    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: colors.primary.withOpacity(opacity),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return SizedBox(
      height: 140,
      width: 140,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (_, _) {
          final value = _controller.value;

          return Stack(
            alignment: Alignment.center,
            children: [
              _buildCircle(140 * value, .10),
              _buildCircle(110 * value, .15),
              _buildCircle(80 * value, .20),

              Container(
                height: 70,
                width: 70,
                decoration: BoxDecoration(
                  color: colors.primary,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.mic, color: colors.white, size: 34),
              ),
            ],
          );
        },
      ),
    );
  }
}
