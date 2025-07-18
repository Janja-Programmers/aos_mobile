import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/features/website/domain/webitem.dart';

import '../utils/url_launcher.dart';
import '../utils/vendor_prov.dart';

void contactVendor(BuildContext context, WebsiteItem websiteItem) async {
  final vendorName = websiteItem.owner.trim();
  if (vendorName.isEmpty) {
    showDialog(
      context: context,
      builder:
          (_) => const AlertDialog(
            title: Text('Vendor Not Found'),
            content: Text(
              'Vendor information is not available for this product.',
            ),
          ),
    );
    return;
  }

  final vendorProvider = context.read<VendorProvider>();
  await vendorProvider.loadVendor(vendorName);

  if (!context.mounted) return;

  showDialog(
    context: context,
    builder: (_) {
      return Consumer<VendorProvider>(
        builder: (context, provider, _) {
          if (provider.loading) {
            return const AlertDialog(
              content: SizedBox(
                height: 80,
                child: Center(child: CircularProgressIndicator()),
              ),
            );
          }

          final vendor = provider.vendor;
          if (vendor == null) {
            return const AlertDialog(
              title: Text('Error'),
              content: Text('Failed to load vendor details.'),
            );
          }

          return AlertDialog(
            title: const Text('Vendor Contact Information'),
            content: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color.fromARGB(232, 255, 255, 255),
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (vendor.name.isNotEmpty)
                    _InfoRow(
                      icon: Icons.person,
                      label: 'Name',
                      value: vendor.name,
                    ),
                  if (vendor.email.isNotEmpty)
                    _InfoRow(
                      icon: Icons.email,
                      label: 'Email',
                      value: vendor.email,
                    ),
                  if (vendor.phone.isNotEmpty)
                    _InfoRow(
                      icon: Icons.phone,
                      label: 'Phone',
                      value: vendor.phone,
                    ),
                ],
              ),
            ),
            actions: [
              if (vendor.phone.isNotEmpty)
                TextButton(
                  onPressed: () => launchCaller(vendor.phone),
                  child: const Text('Call'),
                ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          );
        },
      );
    },
  );
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.black54),
          const SizedBox(width: 4),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: DefaultTextStyle.of(
                  context,
                ).style.copyWith(fontSize: 14),
                children: [
                  TextSpan(
                    text: '$label: ',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: value),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
