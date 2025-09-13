import 'package:flutter/material.dart';

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
Privacy Policy for Africa Online Stores

1. Data Controller
Africa Online Stores
Contact: support@africaonlinestores.com

2. Data We Collect
- Username, email, phone number, user type, password (securely hashed).
- Vendor uploads: images and videos (via CAMERA and MEDIA permissions).
- Shipping addresses provided by Buyers.
- Vendor phone numbers displayed for contact purposes.

3. Purpose of Processing
- Account registration and authentication.
- Product listing and order management.
- Buyer–Vendor communication.
- Compliance with applicable laws.

4. Legal Basis
Processing is based on:
- Consent (checkbox acceptance of this Policy and Terms).
- Contract (provision of marketplace services).

5. Data Hosting
Data is processed and stored via ERPNext hosted on Frappe Cloud.  
See also: ERPNext’s Privacy Policy (TODO: link Frappe policy when available).

6. Data Sharing
We do not sell or share personal data with third parties. Limited processing may occur within ERPNext’s infrastructure.

7. Retention & Deletion
- Accounts may be deleted at any time via the app.  
- Upon deletion, all personal data is permanently erased. This action cannot be undone.  
- No data export is currently available.

8. Permissions
- CAMERA / MEDIA access: to upload vendor product photos/videos.  
- CALL_PHONE: to enable direct calls to vendors upon user action.  

9. User Rights
Under Kenya’s Data Protection Act, you have the right to:
- Access your data.
- Correct inaccuracies.
- Request deletion (available directly in the app).
- Withdraw consent at any time.

10. Data Breaches
We maintain safeguards to protect your information. If a breach occurs, we will notify affected users and the Office of the Data Protection Commissioner in accordance with Kenyan law.

11. Age Restriction
This service is intended for users aged 18 and above.

12. Updates
We may update this Policy from time to time. Users will be notified of material changes.

13. Contact
Questions? Contact us at:
support@africaonlinestores.com

For a full version online, please visit:
https://africaonlinestores.com/privacy_policy
              ''', style: const TextStyle(fontSize: 12, height: 1.4)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Decline"),
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
