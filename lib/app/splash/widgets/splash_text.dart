import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class SplashText extends StatelessWidget {
  final AnimationController controller;

  const SplashText({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          "A O S",
          style: TextStyle(
            fontSize: 36,
            letterSpacing: 10,
            fontWeight: FontWeight.w600,
          ),
        ).animate(delay: 4.seconds).fadeIn(duration: 600.ms).slideY(begin: 0.3),

        const SizedBox(height: 10),

        const Text(
          "AFRICA ONLINE STORES",
          style: TextStyle(
            letterSpacing: 3,
            fontSize: 12,
            color: Colors.black54,
          ),
        ).animate(delay: 4.3.seconds).fadeIn(duration: 600.ms),
      ],
    );
  }
}
