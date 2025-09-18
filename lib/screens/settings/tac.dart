import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '/shared/widgets/app_bars.dart';

class TermsPage extends StatelessWidget {
  const TermsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TopAppBar(),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: SelectableText('''
Terms & Conditions
Effective Date: 1st September, 2025

Welcome to Africa Online Stores ("we", "our", "us"). By accessing or using our application and related services, you agree to be bound by these Terms & Conditions. If you do not agree, please do not use our platform.

1. Eligibility
You must be at least 18 years old to use our services. By creating an account, you represent that you meet this requirement.

2. Account Responsibilities
- You are responsible for maintaining the confidentiality of your account credentials.
- You agree to provide accurate, current, and complete information when creating an account.
- You are responsible for all activities that occur under your account and must notify us immediately of any unauthorized use.

3. Platform Role
Africa Online Stores is a multi-vendor marketplace platform. We do not buy, sell, or own products listed on the platform. We do not handle or process payments between buyers and vendors. All transactions, negotiations, and deliveries are conducted directly between buyers and vendors.

4. Vendor Responsibilities
- Vendors are solely responsible for the products they list, including descriptions, pricing, and compliance with applicable laws.
- By uploading content (such as images or descriptions), vendors grant us a non-exclusive, worldwide, royalty-free license to display such content on our platform for the purpose of operating and promoting the marketplace.
- Vendors must not upload prohibited, illegal, counterfeit, or harmful items.

5. Prohibited Uses
You agree not to use the platform to:
- Engage in fraudulent or deceptive activities.
- Sell illegal, restricted, or counterfeit goods.
- Upload harmful, offensive, or misleading content.
- Disrupt the operation of the platform or compromise its security.

6. Intellectual Property
All rights, title, and interest in the Africa Online Stores platform (excluding user-generated content) remain our property. You may not copy, modify, or distribute any part of our platform without prior written permission.

7. Limitation of Liability
We provide the platform on an "as is" and "as available" basis. To the maximum extent permitted by law, we disclaim all warranties and are not liable for any damages, losses, or disputes arising from use of the platform, including but not limited to transactions between buyers and vendors.

8. Termination
We reserve the right to suspend or terminate accounts that violate these Terms & Conditions or applicable laws. Upon termination, your access to the platform will end, but certain obligations (such as outstanding payments between buyers and vendors) may still apply.

9. Governing Law
These Terms & Conditions shall be governed by and interpreted under the laws of Kenya. Any disputes shall be subject to the exclusive jurisdiction of the courts of Kenya.

10. Changes to These Terms
We may update these Terms & Conditions from time to time. Continued use of the platform after changes means you accept the updated terms.

11. Contact Us
Kalutu Daniel
Changamwe
Mombasa - 80100
Kenya (KE)
Email: kalutudaniel@gmail.com

These Terms & Conditions apply to the Africa Online Stores application and related services.
            ''', style: const TextStyle(fontSize: 13, height: 1.5)),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: OutlinedButton.icon(
            icon: const Icon(Icons.open_in_new),
            label: const Text("Read Full Version Online"),
            onPressed: () async {
              final url = Uri.parse("https://africaonlinestores.com/tac");
              if (await canLaunchUrl(url)) {
                await launchUrl(url, mode: LaunchMode.externalApplication);
              }
            },
          ),
        ),
      ),
    );
  }
}
