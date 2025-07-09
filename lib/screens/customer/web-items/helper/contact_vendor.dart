import 'package:flutter/material.dart';

class ContactVendorButton extends StatelessWidget {
  final VoidCallback onPressed;

  const ContactVendorButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        side: const BorderSide(color: Colors.black),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        textStyle: const TextStyle(fontSize: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      icon: const Icon(Icons.phone),
      label: const Text('Contact Vendor'),
    );
  }
}
