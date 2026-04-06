import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';

import 'package:africaonlinestores/features/seller/navigation/seller_routes.dart';
import 'package:africaonlinestores/features/seller/seller_verification/controllers/get_my_verification_provider.dart';
import 'package:africaonlinestores/features/seller/seller_verification/controllers/verification_controller_provider.dart';
import 'package:africaonlinestores/features/seller/seller_verification/domain/verification_status.dart';
import 'package:africaonlinestores/features/seller/seller_verification/presentation/widgets/base_verification_banner.dart';

class SellerVerificationBanner extends StatelessWidget {
  const SellerVerificationBanner({super.key, required this.state});

  final SellerVerificationStatus state;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    switch (state.status) {
      case VerificationStatus.unverified:
        return BaseVerificationBanner(
          color: colors.red,
          icon: Icons.verified_outlined,
          title: "Get verified",
          subtitle: "Boost trust and visibility",
          onTap: () => SellerNavigation.toSellerVerification(context),
        );

      case VerificationStatus.pending:
        return BaseVerificationBanner(
          color: colors.amber,
          icon: Icons.schedule,
          title: "Verification in progress",
          subtitle: "We’re reviewing your details",
        );

      case VerificationStatus.approved:
        return BaseVerificationBanner(
          color: colors.success,
          icon: Icons.check_circle,
          title: "Verified seller",
          subtitle: state.verifiedOn != null
              ? "Verified on ${state.verifiedOn}"
              : "Your account is verified",
        );

      case VerificationStatus.rejected:
        return BaseVerificationBanner(
          color: colors.red,
          icon: Icons.error_outline,
          title: "Verification rejected",
          subtitle: _buildRejectionText(state),
          onTap: () async {
            try {
              final container = ProviderScope.containerOf(context);

              final verification = await container.read(
                myVerificationProvider.future,
              );

              container
                  .read(sellerVerificationControllerProvider.notifier)
                  .hydrateFromVerification(verification);

              if (context.mounted) {
                SellerNavigation.toSellerVerification(context);
              }
            } catch (_) {
              return;
            }
          },
        );
    }
  }

  String _buildRejectionText(SellerVerificationStatus state) {
    final reason = state.rejectionReason;

    if (reason == null || reason.trim().isEmpty) {
      return "Update your details and try again";
    }

    // Optional: normalize casing a bit
    final cleaned = reason.trim();

    // Limit length to avoid UI breaking
    const maxLength = 90;

    if (cleaned.length <= maxLength) return cleaned;

    return "${cleaned.substring(0, maxLength)}...";
  }
}
