import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:flutter/material.dart';

/// Shared, reusable legal document content widgets.
/// These are used both in full pages and in bottom sheets (e.g. Register consent).
class TermsConditionsContent extends StatelessWidget {
  const TermsConditionsContent({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _H1('Africa Online Stores (AOS) - Terms & Conditions'),
        SizedBox(height: 12),
        _P(
          'These Terms & Conditions govern your use of the AOS mobile application and related services. '
          'By creating an account or using the app, you agree to comply with these terms.',
        ),
        SizedBox(height: 16),
        _H2('1. Marketplace Nature'),
        _P(
          'AOS is a discovery and communication platform that connects buyers and sellers. '
          'Payments and delivery arrangements are handled outside the app unless explicitly stated otherwise.',
        ),
        SizedBox(height: 12),
        _H2('2. User Accounts'),
        _P(
          'You are responsible for maintaining the confidentiality of your account and for all activities '
          'that occur under your account.',
        ),
        SizedBox(height: 12),
        _H2('3. Listings & Content'),
        _P(
          'Sellers must provide accurate information, lawful products/services, and compliant media. '
          'AOS may remove or restrict listings that violate policies, local laws, or safety guidelines.',
        ),
        SizedBox(height: 12),
        _H2('4. Safety & Prohibited Behavior'),
        _P(
          'Harassment, spam, fraudulent activity, and abusive behavior are not allowed. '
          'We may suspend or ban accounts that violate safety rules.',
        ),
        SizedBox(height: 12),
        _H2('5. Communications'),
        _P(
          'In-app chat and calls are provided to facilitate buyer-seller communication. '
          'Misuse may result in restrictions, reporting actions, or account suspension.',
        ),
        SizedBox(height: 12),
        _H2('6. Changes to These Terms'),
        _P(
          'We may update these terms from time to time. Continued use of the app after updates '
          'means you accept the revised terms.',
        ),
        SizedBox(height: 16),
        _P(
          'Note: This is a placeholder Terms page for the MVP. Replace this content with your final legal text '
          'or a hosted document before production release.',
        ),
      ],
    );
  }
}

class PrivacyPolicyContent extends StatelessWidget {
  const PrivacyPolicyContent({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _H1('Africa Online Stores (AOS) - Privacy Policy'),
        SizedBox(height: 12),
        _P(
          'This Privacy Policy explains how AOS collects, uses, and protects your information when you use the app.',
        ),
        SizedBox(height: 16),
        _H2('1. Information We Collect'),
        _P(
          'We may collect account information (such as name, email/phone), profile details, and app usage data '
          'to provide and improve our services.',
        ),
        SizedBox(height: 12),
        _H2('2. How We Use Your Information'),
        _P(
          'We use your information to create and manage your account, personalize your experience, enable '
          'buyer-seller communication, and improve platform safety.',
        ),
        SizedBox(height: 12),
        _H2('3. Sharing'),
        _P(
          'We do not sell your personal information. We may share limited data with service providers '
          '(e.g., push notifications, media storage) strictly to operate the app.',
        ),
        SizedBox(height: 12),
        _H2('4. Security'),
        _P(
          'We use reasonable security measures to protect your data. However, no method of transmission or storage '
          'is 100% secure.',
        ),
        SizedBox(height: 12),
        _H2('5. Your Choices'),
        _P(
          'You can update your profile and preferences in-app. You can also request deletion of your account '
          'subject to legal and operational requirements.',
        ),
        SizedBox(height: 12),
        _H2('6. Updates to This Policy'),
        _P(
          'We may update this Privacy Policy from time to time. Continued use of the app after updates '
          'means you accept the revised policy.',
        ),
        SizedBox(height: 16),
        _P(
          'Note: This is a placeholder Privacy Policy for the MVP. Replace this content with your final legal text '
          'or a hosted document before production release.',
        ),
      ],
    );
  }
}

class _H1 extends StatelessWidget {
  const _H1(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Text(
      text,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w800,
        color: colors.textPrimary,
      ),
    );
  }
}

class _H2 extends StatelessWidget {
  const _H2(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w800,
          color: colors.textPrimary,
        ),
      ),
    );
  }
}

class _P extends StatelessWidget {
  const _P(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Text(
      text,
      style: TextStyle(height: 1.45, fontSize: 13.5, color: colors.textMuted),
    );
  }
}
