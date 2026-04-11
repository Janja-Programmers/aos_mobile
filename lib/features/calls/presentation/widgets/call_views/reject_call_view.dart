import 'package:flutter/material.dart';

import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:africaonlinestores/features/calls/presentation/widgets/incoming_call/call_avatar.dart';

class CallRejectedView extends StatelessWidget {
  final String name;
  final String? avatarUrl;
  final VoidCallback onClose;

  const CallRejectedView({
    super.key,
    required this.name,
    this.avatarUrl,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Scaffold(
      backgroundColor: colors.surface,
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              const Spacer(flex: 2),

              // Avatar (same as incoming)
              CallAvatar(avatarUrl: avatarUrl, fallback: name),

              const SizedBox(height: 42),

              // Name + status
              Column(
                children: [
                  Text(
                    name,
                    style: context.body.copyWith(
                      fontSize: 34,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Call declined',
                    style: context.body.copyWith(
                      fontSize: 20,
                      color: colors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),

              const Spacer(flex: 3),

              // Close button (single action)
              FloatingActionButton(
                heroTag: 'close_rejected',
                backgroundColor: colors.primary,
                onPressed: onClose,
                child: Icon(Icons.close, color: colors.surface),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
