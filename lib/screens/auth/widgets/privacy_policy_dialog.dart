import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> showPrivacyPolicyDialog(
  BuildContext context, {
  VoidCallback? onAccept,
}) {
  return showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text(
          "Privacy Policy",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: SingleChildScrollView(
            child: SelectableText('''
Privacy Policy
Effective Date: 1st September, 2025

Africa Online Stores ("we", "our", "us") operates a multi-vendor platform that connects buyers and vendors. This Privacy Policy explains how we collect, use, and protect information when you use our application and related services.

1. Information We Collect
- Account Information: Name, email address, phone number, and password when you create an account.
- Product Information: Images, descriptions, and files uploaded by vendors for their listings.
- Usage Data: Automatically collected through our servers and analytics tools, such as device type, operating system, app activity, and log data (error and crash reports).
- Optional Information: If you grant permission at runtime, we may access your camera and files only when you upload product images or related content.
We do not collect payment details, as all transactions occur directly between buyers and vendors outside our platform. We do not access location, contacts, or collect data in the background.

2. How We Use Information
- Provide and improve our marketplace services.
- Facilitate communication between buyers and vendors.
- Personalize user experience and display relevant content.
- Ensure platform security and prevent fraud or misuse.
- Comply with legal obligations.

3. Sharing of Information
We do not sell or rent personal data. Information may be shared only:
- With Vendors/Buyers: contact details necessary to connect buyers and vendors.
- With Service Providers: trusted providers (hosting, storage, analytics) under confidentiality agreements.
- For Legal Reasons: if required by law, regulation, or legal process.

4. Account Deletion & Data Retention
You may request deletion of your account at any time. Certain information (such as log data or security records) may be retained for a limited period, not exceeding 12 months.

5. User-Generated Content
Vendors are responsible for their uploads. We may remove content that violates Terms or laws.

6. Your Rights
- Access and update your account info anytime.
- Request deletion of your account.
- Contact us for data access, correction, or portability.

7. Data Security
We use HTTPS encryption, access controls, monitoring, and safeguards. However, no system is 100% secure.

8. Children and Age Restrictions
For users aged 18+. If under 18 data is discovered, we delete it immediately.

9. Changes
We may update this Policy. Any changes will be posted in-app and dated.

10. Contact Us
Kalutu Daniel
Changamwe, Mombasa - 80100, Kenya
Email: kalutudaniel@gmail.com

This policy applies to Africa Online Stores.

Read the full policy online:
https://africaonlinestores.com/privacy
''', style: const TextStyle(fontSize: 12, height: 1.4)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Decline"),
          ),
          TextButton(
            onPressed: () async {
              final url = Uri.parse("https://africaonlinestores.com/privacy");
              if (await canLaunchUrl(url)) {
                await launchUrl(url, mode: LaunchMode.externalApplication);
              }
            },
            child: const Text(
              "View Online",
              style: TextStyle(color: Colors.blue),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              if (onAccept != null) onAccept();
            },
            child: const Text("Accept"),
          ),
        ],
      );
    },
  );
}
