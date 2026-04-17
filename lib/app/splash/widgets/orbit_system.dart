import 'dart:math';

import 'package:flutter/material.dart';

import 'package:africaonlinestores/app/splash/widgets/logo_card.dart';
import 'package:africaonlinestores/app/splash/widgets/orbit_icon.dart';

class OrbitSystem extends StatelessWidget {
  final AnimationController controller;

  const OrbitSystem({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, _) {
        final progress = controller.value;

        /// 🎯 PHASES
        final isCollapsing = progress > 0.70;

        /// 🔁 Radius animation (expand → hold → collapse)
        final radius = TweenSequence<double>([
          TweenSequenceItem(
            tween: Tween(
              begin: 10.0,
              end: 120.0,
            ).chain(CurveTween(curve: Curves.easeOutBack)),
            weight: 45,
          ),
          TweenSequenceItem(tween: ConstantTween(120.0), weight: 30),
          TweenSequenceItem(
            tween: Tween(
              begin: 120.0,
              end: 0.0,
            ).chain(CurveTween(curve: Curves.easeInCubic)),
            weight: 25,
          ),
        ]).transform(progress);

        /// ⚡ Speed up rotation during collapse
        final rotationSpeed = isCollapsing ? 4.0 : 1.0;
        final rotation = controller.value * 2 * pi * rotationSpeed;

        /// 🧲 Logo absorb animation
        final logoScale = TweenSequence<double>([
          TweenSequenceItem(tween: ConstantTween(1.0), weight: 70),
          TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.92), weight: 15),
          TweenSequenceItem(
            tween: Tween(
              begin: 0.92,
              end: 1.05,
            ).chain(CurveTween(curve: Curves.easeOutBack)),
            weight: 15,
          ),
        ]).transform(progress);

        return SizedBox(
          width: 260,
          height: 260,
          child: Stack(
            alignment: Alignment.center,
            children: [
              /// 🔴 Ring
              if (progress > 0.05)
                Opacity(
                  opacity: isCollapsing ? (1 - (progress - 0.7) * 3) : 1,
                  child: Container(
                    width: radius * 2,
                    height: radius * 2,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.red.shade400, width: 2),
                    ),
                  ),
                ),

              /// 🔄 Orbit icons
              Transform.rotate(
                angle: rotation,
                child: Stack(
                  children: List.generate(8, (i) {
                    final angle = (2 * pi / 8) * i;

                    return Positioned(
                      left: 130 + radius * cos(angle) - 20,
                      top: 130 + radius * sin(angle) - 20,
                      child: Transform.scale(
                        scale: isCollapsing
                            ? (radius / 120).clamp(0.0, 1.0)
                            : 1.0,
                        child: OrbitIcon(index: i),
                      ),
                    );
                  }),
                ),
              ),

              /// 🧩 Logo (absorbing center)
              Transform.scale(scale: logoScale, child: const LogoCard()),
            ],
          ),
        );
      },
    );
  }
}
