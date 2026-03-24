import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';

import 'package:africaonlinestores/features/seller/seller_verification/presentation/widgets/verification_shell.dart';

class VerificationScreen extends ConsumerWidget {
  const VerificationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;

    return Scaffold(
      backgroundColor: colors.surface,
      body: const SafeArea(child: SellerVerificationShell()),
    );
  }
}
