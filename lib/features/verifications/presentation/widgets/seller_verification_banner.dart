import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:africaonlinestores/features/sellers/navigation/seller_routes.dart';
import 'package:africaonlinestores/features/verifications/controllers/get_my_verification_provider.dart';
import 'package:africaonlinestores/features/verifications/controllers/verification_controller_provider.dart';
import 'package:africaonlinestores/features/verifications/domain/verification_status.dart';
import 'package:africaonlinestores/features/verifications/presentation/widgets/base_verification_banner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SellerVerificationBanner extends StatelessWidget {
  const SellerVerificationBanner({super.key, required this.state});

  final SellerVerificationStatus state;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    switch (state.status) {
      case VerificationStatus.notSubmitted:
        return BaseVerificationBanner(
          color: colors.red,
          icon: Icons.verified_outlined,
          title: 'Get verified',
          subtitle: 'Boost trust and visibility',
          onTap: () => SellerNavigation.toSellerVerification(context),
        );

      case VerificationStatus.pending:
        return BaseVerificationBanner(
          color: colors.amber,
          icon: Icons.schedule,
          title: 'Verification in progress',
          subtitle: 'We’re reviewing your details',
        );

      case VerificationStatus.approved:
        return BaseVerificationBanner(
          color: colors.success,
          icon: Icons.check_circle,
          title: 'Verified seller',
          subtitle: state.verifiedOn != null
              ? 'Verified on ${_formatVerifiedDate(state.verifiedOn)}'
              : 'Your account is verified',
        );

      case VerificationStatus.rejected:
        return BaseVerificationBanner(
          color: colors.red,
          icon: Icons.error_outline,
          title: 'Verification rejected',
          subtitle: _buildRejectionText(state),
          onTap: () async {
            try {
              final container = ProviderScope.containerOf(context);

              final verification = await container.read(
                myBusinessVerificationProvider.future,
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
      return 'Update your details and try again';
    }

    // Optional: normalize casing a bit
    final cleaned = reason.trim();

    // Limit length to avoid UI breaking
    const maxLength = 90;

    if (cleaned.length <= maxLength) return cleaned;

    return '${cleaned.substring(0, maxLength)}...';
  }

  String _formatVerifiedDate(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '';
    }

    final normalized = value.trim().replaceFirst(' ', 'T');
    final date = DateTime.tryParse(normalized);

    if (date == null) {
      return value;
    }

    final day = date.day;
    final month = _monthName(date.month);
    final suffix = _daySuffix(day);

    return '$day$suffix $month ${date.year}';
  }

  String _monthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    if (month < 1 || month > 12) return '';
    return months[month - 1];
  }

  String _daySuffix(int day) {
    if (day >= 11 && day <= 13) return 'th';

    switch (day % 10) {
      case 1:
        return 'st';
      case 2:
        return 'nd';
      case 3:
        return 'rd';
      default:
        return 'th';
    }
  }
}
