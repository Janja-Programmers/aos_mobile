import 'package:flutter/material.dart';

import '/shared/widgets/app_bars.dart';

class PrivacyPage extends StatelessWidget {
  const PrivacyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TopAppBar(),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: SelectableText('''
Privacy Policy
Effective Date: 1st September, 2025

Africa Online Stores ("we", "our", "us") operates a multi-vendor platform that connects buyers and vendors. This Privacy Policy explains how we collect, use, and protect information when you use our application and related services.

1. Information We Collect
Personal Information: Name, email address, phone number, and address (address is optional unless placing an order). Collected to authenticate users, manage accounts, and facilitate orders.
Financial Information: Purchase history, collected to manage orders and provide order history.
Photos and Videos: Images and videos uploaded by vendors for their product listings. Optional and visible to buyers.
App Info and Performance: Crash logs, diagnostics, and other performance data, collected to improve app performance and security.
App Activity: App interactions and other user-generated content, such as product reviews, reporting products and adding items to cart.

2. How We Use Information
Enable app functionality and authenticate users.
Manage user accounts and facilitate communication between buyers and vendors.
Monitor app performance and conduct analytics to improve the service.
Ensure platform security, prevent fraud, and comply with legal obligations.

3. Sharing of Information
We do not share your personal data with third parties beyond what is necessary for app functionality. This means:

With Vendors/Buyers: Limited information (such as contact details) is shared to enable buyers and vendors to communicate when users initiate contact or place orders.
For Legal Reasons: If required by law, regulation, or legal process.
No other third-party SDKs collect personal data beyond what is required to run our app.

4. Data Deletion & Retention
You can request the deletion of your account and associated personal data at any time. To learn more about how this process works, visit Delete Your Account.

Once your account is deleted, your data will be removed from active systems. However, certain information (such as logs or records required for security or legal compliance) may be retained for up to 12 months.

5. User-Generated Content
Vendors are responsible for content they upload (product images, videos, descriptions). We may review and remove content violating our Terms & Conditions or applicable laws.

6. Your Rights
Access and update your account information at any time.
Request deletion of your account and personal data.
Contact us to exercise rights related to data access, correction, or portability.

7. Data Security
We implement technical and organizational measures to protect your data, including:

Encryption of all data transmitted over HTTPS.
Access controls to limit who can view or modify personal data.
Monitoring servers for potential vulnerabilities.
Safeguards on file uploads to reduce risks.

8. Children and Age Restrictions
Our services are intended for users aged 18 and above. We do not knowingly allow children under 18 to register. Any data collected from children will be deleted immediately.

9. Changes to This Policy
We may update this Privacy Policy from time to time. Changes will be posted in the app and reflect a new "Effective Date."

10. Contact Us
If you have questions about this Privacy Policy or how we handle your data, please contact us at: kalutudaniel@gmail.com

This policy applies to the Africa Online Stores application and related services.

Last updated: 1st September, 2025.
          ''', style: const TextStyle(fontSize: 13, height: 1.5)),
        ),
      ),
    );
  }
}
