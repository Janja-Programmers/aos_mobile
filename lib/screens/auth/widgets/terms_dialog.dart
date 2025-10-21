import 'package:flutter/material.dart';

Future<void> showTermsDialog(
  BuildContext context, {
  required void Function() onAcceptCheck,
}) {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return AlertDialog(
        title: const Text(
          "Terms & Conditions",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: SizedBox(
          width: double.maxFinite,
          height: 450,
          child: SingleChildScrollView(
            child: SelectableText('''
Terms & Conditions
Effective Date: 1st September, 2025

Welcome to Africa Online Stores ("we", "our", "us"). By accessing or using our application and related services, you agree to be bound by these Terms & Conditions. If you do not agree, please do not use our platform.

1. Eligibility
You must be at least 18 years old to use our services. By creating an account, you represent that you meet this requirement.

2. Account Responsibilities
You are responsible for maintaining the confidentiality of your account credentials.
You agree to provide accurate, current, and complete information when creating an account.
You are responsible for all activities that occur under your account and must notify us immediately of any unauthorized use.

3. Platform Role
Africa Online Stores is a multi-vendor marketplace platform. We do not buy, sell, or own products listed on the platform. We do not handle or process payments between buyers and vendors. All transactions, negotiations, and deliveries are conducted directly between buyers and vendors.

4. Vendor & User Responsibilities
Vendors are solely responsible for the products they list, including descriptions, pricing, and compliance with applicable laws.
Users are responsible for any content they upload, including reviews, images, and comments.
By uploading content (such as images, videos, product details, or reviews), you grant us a non-exclusive, worldwide, royalty-free license to display such content on our platform to operate and promote the marketplace.
You must not upload prohibited, illegal, counterfeit, or harmful items or content.

5. User-Generated Content Rules
You agree not to upload, post, or share any content that:

Is illegal, fraudulent, or misleading.
Promotes hate speech, violence, or harassment.
Contains pornography, sexually explicit material, or graphic violence.
Infringes on intellectual property rights.
Includes spam, scams, malware, or unauthorized promotions.
Violates privacy or impersonates another person.

6. Moderation & Reporting
We may review, monitor, and moderate content uploaded to the platform.
We reserve the right to remove or restrict any content that violates these Terms or applicable laws without notice.
Users can report inappropriate or abusive content directly within the app or by contacting us.
We will review reported content and take appropriate action within a reasonable timeframe.

7. Data Collection & Use
We collect certain personal data to operate our platform effectively. This includes:

Name, email, phone number, and address (optional unless placing an order).
Purchase history for managing orders.
Photos and videos uploaded by vendors for product listings.
App performance data such as crash logs and diagnostics.
App interactions, reviews, and other user-generated content.
Collected data is used for app functionality, account management, analytics, fraud prevention, and security purposes. We do not share personal data with third parties except as required for app functionality or by law.

8. Contact Vendor Feature
Product detail pages include a “Contact Vendor” button. When tapped, this feature opens your phone’s dialer with the vendor’s phone number pre-filled. The app does not initiate calls, access your contacts, or store call logs. Calls are initiated voluntarily by you.

9. Limitation of Liability
We provide the platform on an "as is" and "as available" basis. To the maximum extent permitted by law, we disclaim all warranties and are not liable for any damages, losses, or disputes arising from use of the platform, including transactions between buyers and vendors or user-generated content.

10. Termination
We may suspend or terminate accounts that violate these Terms & Conditions or applicable laws. Certain obligations, such as outstanding payments between buyers and vendors, may still apply after termination.

11. Governing Law
These Terms & Conditions are governed by and interpreted under the laws of Kenya. Any disputes shall be subject to the exclusive jurisdiction of the courts of Kenya.

12. Changes to These Terms
We may update these Terms & Conditions from time to time. Continued use of the platform after changes indicates acceptance of the updated terms.

13. Contact Us
If you have questions about these Terms & Conditions, you may contact us at:

Kalutu Daniel
Changamwe
Mombasa - 80100
Kenya (KE)
Email: kalutudaniel@gmail.com

These Terms & Conditions apply to the Africa Online Stores application and related services.

Last updated: 1st September, 2025.
''', style: const TextStyle(fontSize: 12, height: 1.4)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text("Decline"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              onAcceptCheck();
            },
            child: const Text("Accept"),
          ),
        ],
      );
    },
  );
}
