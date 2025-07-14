import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/features/website/domain/webitem.dart';

import '../utils/url_launcher.dart';
import '../utils/vendor_prov.dart';

void contactVendor(BuildContext context, WebsiteItem websiteItem) async {
  print('🟢 contactVendor CALLED');

  final vendorName = websiteItem.owner.trim();
  print('🟡 vendorName: "$vendorName"');

  if (vendorName.isEmpty) {
    print('🔴 vendorName is empty, showing alert');
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
  print('🟠 calling loadVendor...');
  await vendorProvider.loadVendor(vendorName);
  print('🟠 loadVendor finished');

  if (!context.mounted) return;

  showDialog(
    context: context,
    builder: (_) {
      print('🟢 showing dialog with vendor info');
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
            title: Text('Vendor: ${vendor.name}'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (vendor.email.isNotEmpty) Text('📧 ${vendor.email}'),
                if (vendor.phone.isNotEmpty) Text('📞 ${vendor.phone}'),
              ],
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
