import 'package:flutter/material.dart';

enum TopSnackType { info, success, error, cart }

class _TopSnackBar extends StatefulWidget {
  final Widget child;
  final Duration duration;

  const _TopSnackBar({required this.child, required this.duration});

  @override
  State<_TopSnackBar> createState() => _TopSnackBarState();
}

class _TopSnackBarState extends State<_TopSnackBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 300),
  );

  late final Animation<Offset> _offsetAnimation = Tween<Offset>(
    begin: const Offset(0, -1),
    end: Offset.zero,
  ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

  @override
  void initState() {
    super.initState();
    _controller.forward();

    Future.delayed(widget.duration, () async {
      if (!mounted) return;
      await _controller.reverse();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(position: _offsetAnimation, child: widget.child);
  }
}

// Track if a snackbar is already visible
bool _isSnackVisible = false;

void topSnackBar(
  BuildContext context,
  String message, {
  TopSnackType type = TopSnackType.success,
  Duration duration = const Duration(seconds: 3),
}) {
  if (_isSnackVisible) return;
  _isSnackVisible = true;

  WidgetsBinding.instance.addPostFrameCallback((_) {
    final overlay = Overlay.of(context, rootOverlay: true);

    final color = switch (type) {
      TopSnackType.success => Colors.green.shade600,
      TopSnackType.error => Colors.red.shade600,
      TopSnackType.info => Colors.blue.shade600,
      TopSnackType.cart => Colors.black,
    };

    final icon = switch (type) {
      TopSnackType.success => Icons.check_circle,
      TopSnackType.error => Icons.error,
      TopSnackType.info => Icons.info,
      TopSnackType.cart => Icons.shopping_cart,
    };

    final overlayEntry = OverlayEntry(
      builder:
          (_) => Builder(
            builder: (context) {
              final paddingTop = MediaQuery.of(context).padding.top;
              return Positioned(
                top: paddingTop + 16,
                left: 16,
                right: 16,
                child: Material(
                  color: Colors.transparent,
                  child: _TopSnackBar(
                    duration: duration,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 6,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Icon(icon, color: Colors.white),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              message,
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
    );

    overlay.insert(overlayEntry);

    Future.delayed(duration + const Duration(milliseconds: 300), () {
      overlayEntry.remove();
      _isSnackVisible = false;
    });
  });
}
