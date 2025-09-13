import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
Welcome to Africa Online Stores.

1. Acceptance  
By creating an account (Vendor or Buyer), you agree to these Terms and our Privacy Policy.

2. Eligibility  
This platform is intended only for persons aged 18 years and above. By registering you confirm that you meet this requirement.

3. Services We Provide  
Africa Online Stores is a **digital marketplace**.  
- Vendors may list their products with images and videos.  
- Buyers may browse, place orders, and contact Vendors directly.  
⚠️ We are not a bank, escrow, or payments provider. All payments are strictly between Buyer and Vendor.

4. Vendor Responsibilities  
Vendors must:  
- Provide truthful and accurate information.  
- Upload only lawful images and videos (with CAMERA or MEDIA permission).  
- Ensure stock availability and product quality.  

5. Buyer Responsibilities  
Buyers must:  
- Review all product details carefully before purchase.  
- Use the “Contact Vendor” feature responsibly. The vendor’s phone number is displayed when you choose to contact them.

6. Liability Disclaimer  
Africa Online Stores only **connects buyers and vendors**.  
- We do not control the transaction or delivery.  
- We are **not liable** for disputes, refunds, delivery delays, or damages.  
- Buyers and Vendors resolve payments between themselves.

7. Account and Data  
- Your account information (name, email, phone, etc.) is stored securely using ERPNext (a business software platform hosted on Frappe Cloud).  
- Think of ERPNext as the “secure storage engine” where your account and order data live.  
- When you delete your account, all personal data is **permanently erased immediately**.  
- We do not sell or share your information with outside companies.

8. Intellectual Property  
All content, branding, and the app design belong to Africa Online Stores.

9. Termination  
We reserve the right to suspend or close accounts that violate these Terms.

10. Governing Law  
These Terms are governed by the laws of Kenya.

For the full version online, please visit:  
https://africaonlinestores.com/terms_and_conditions
              ''', style: const TextStyle(fontSize: 12, height: 1.4)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.go('/login');
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
