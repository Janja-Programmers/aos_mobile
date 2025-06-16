import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color textColor;
  final Color backgroundColor;
  final Widget Function() pageBuilder;

  const CustomButton({
    super.key,
    required this.pageBuilder,
    this.label = "Create New",
    this.icon = Icons.add,
    this.textColor = Colors.white,
    this.backgroundColor = Colors.black,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      style: TextButton.styleFrom(
        foregroundColor: textColor,
        backgroundColor: backgroundColor,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),
      icon: Icon(icon, size: 16),
      label: Text(label, style: const TextStyle(fontSize: 13)),
      onPressed: () {
        Navigator.of(context).push(
          PageRouteBuilder(
            pageBuilder:
                (context, animation, secondaryAnimation) => pageBuilder(),
            transitionsBuilder: (
              context,
              animation,
              secondaryAnimation,
              child,
            ) {
              final slide = Tween<Offset>(
                begin: const Offset(0, 0.2),
                end: Offset.zero,
              ).chain(CurveTween(curve: Curves.easeInOut)).animate(animation);

              final fade = Tween<double>(
                begin: 0.0,
                end: 1.0,
              ).chain(CurveTween(curve: Curves.easeIn)).animate(animation);

              return SlideTransition(
                position: slide,
                child: FadeTransition(opacity: fade, child: child),
              );
            },
          ),
        );
      },
    );
  }
}
