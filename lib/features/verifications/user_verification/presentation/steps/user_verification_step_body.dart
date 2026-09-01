import 'package:flutter/material.dart';

/// Shared responsive shell for individual-verification steps.
///
/// The step content stays phone-friendly while avoiding edge-to-edge forms on
/// tablets, foldables, desktop-sized windows, and split-screen layouts. Text
/// scaling is intentionally inherited from the ambient [MediaQuery].
class UserVerificationStepBody extends StatelessWidget {
  const UserVerificationStepBody({
    super.key,
    required this.child,
    this.padding = const EdgeInsetsDirectional.fromSTEB(16, 12, 16, 24),
  });

  static const double maxContentWidth = 560;

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: padding,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: maxContentWidth),
          child: child,
        ),
      ),
    );
  }
}
