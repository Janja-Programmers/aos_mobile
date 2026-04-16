import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class LogoCard extends StatelessWidget {
  const LogoCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 110,
      height: 110,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 12)],
      ),
      child: Image.asset('assets/images/logo.png'),
    ).animate().scale(duration: 700.ms, curve: Curves.easeOutBack).fadeIn();
  }
}
