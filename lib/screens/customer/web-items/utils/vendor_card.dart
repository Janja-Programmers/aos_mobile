import 'package:flutter/material.dart';
import 'package:ownashop/features/product/domain/product.dart';
import 'package:provider/provider.dart';

import '/features/website/domain/webitem.dart';
import '/features/product/provider.dart';

import '../utils/url_launcher.dart';
import '../utils/vendor_prov.dart';

void contactVendor(BuildContext context, WebsiteItem websiteItem) async {
  final productProvider = context.read<ProductProvider>();

  // Try to find a product with a matching name
  final matchedProduct = productProvider.products.firstWhere(
    (p) =>
        p.itemName.trim().toLowerCase() ==
        websiteItem.name.trim().toLowerCase(),
    orElse:
        () => Product(
          itemName: '',
          vendor: null,
          name: '',
          itemPrice: 0.00,
          category: '',
        ),
  );

  if (matchedProduct.itemName.isEmpty || matchedProduct.vendor == null) {
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
  await vendorProvider.loadVendor(matchedProduct.vendor!);

  if (!context.mounted) return;

  showDialog(
    context: context,
    builder:
        (_) => Consumer<VendorProvider>(
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
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              title: Text('Supplier: ${vendor.name}'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (vendor.email.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Text('📧 ${vendor.email}'),
                    ),
                  if (vendor.phone.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Text('📞 ${vendor.phone}'),
                    ),
                ],
              ),
              actions: [
                if (vendor.phone.isNotEmpty)
                  TextButton(
                    onPressed: () => launchCaller(vendor.phone),
                    child: const Text(
                      'Call',
                      style: TextStyle(color: Colors.blueAccent),
                    ),
                  ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Close',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            );
          },
        ),
  );
}
