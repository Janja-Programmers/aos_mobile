import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '/core/utils/snackbar.dart';

import '/features/product/domain/product.dart';

import '/shared/widgets/app_drawer.dart';
import '/shared/widgets/custom_button.dart';
import '/shared/widgets/main_bar.dart';

import 'controllers/add_item_controller.dart';
import 'sections/item_form_fields.dart';

class AddItemScreen extends StatefulWidget {
  final Product? product;
  final String? productName;

  const AddItemScreen({super.key, this.product, this.productName});

  @override
  State<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();

    final ctrl = context.read<AddItemController>();

    // ✅ Step 1: Reset everything to default
    ctrl.reset();

    // ✅ Step 2: Set loading state
    ctrl.setLoading(true);

    // ✅ Step 3: Async hydration for editing or fetching by name
    Future.microtask(() async {
      try {
        if (widget.product != null) {
          // Editing existing product
          ctrl.setInitialProduct(widget.product!);
        } else if (widget.productName != null) {
          // Fetch product by name (optional)
          final fetched = await ctrl.fetchSingleProduct(widget.productName!);
          if (fetched != null && mounted) {
            ctrl.setInitialProduct(fetched);
          } else if (mounted) {
            topSnackBar(context, 'Product not found', type: TopSnackType.error);
            context.pop();
            return;
          }
        }
        // ✅ At this point, either new product (empty) or existing product is loaded
      } catch (e, stack) {
        if (mounted) {
          topSnackBar(
            context,
            'Error loading product',
            type: TopSnackType.error,
          );
        }
        debugPrint('Error in AddItemScreen.initState(): $e\n$stack');
      } finally {
        if (mounted) {
          // ✅ Always reset loading state
          ctrl.setLoading(false);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AddItemController>();
    final isUpdate = widget.product != null;

    return MainBarScaffold(
      drawer: AppDrawer(selectedIndex: 1, onItemSelected: (_) {}),
      scaffoldKey: _scaffoldKey,
      subTitle: Text(
        isUpdate ? 'Update Product' : 'Create Product',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      actionButton:
          controller.isLoading
              ? null
              : CustomButton(
                label: isUpdate ? 'Update' : 'Save',
                icon: Icons.save,
                onPressed:
                    controller.isSubmitting
                        ? null
                        : () async {
                          final success = await controller.submit(
                            context,
                            widget.product,
                          );
                          if (!context.mounted) return;
                          if (success) {
                            topSnackBar(
                              context,
                              isUpdate
                                  ? 'Product updated successfully'
                                  : 'Product created successfully',
                            );
                            context.pop(true);
                          } else {
                            topSnackBar(
                              context,
                              'Error saving product',
                              type: TopSnackType.error,
                            );
                          }
                        },
                child:
                    controller.isSubmitting
                        ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                        : null,
              ),
      body: Container(
        color: Colors.white,
        child:
            controller.isLoading
                ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    const Text("Loading product details... Please wait"),
                    const SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: () {
                        setState(() {});
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text("Retry"),
                    ),
                  ],
                )
                : AbsorbPointer(
                  absorbing: controller.isSubmitting,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: ItemFormFields(
                      controller: controller,
                      isUpdate: isUpdate,
                      formKey: controller.formKey,
                      product: widget.product,
                    ),
                  ),
                ),
      ),
    );
  }
}
