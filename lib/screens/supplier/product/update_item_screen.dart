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
    Future.microtask(() async {
      final ctrl = context.read<AddItemController>();
      ctrl.reset();

      if (widget.product != null) {
        ctrl.setInitialProduct(widget.product!);
      } else if (widget.productName != null) {
        final fetched = await ctrl.fetchSingleProduct(widget.productName!);
        if (fetched != null && mounted) {
          ctrl.setInitialProduct(fetched);
        } else if (mounted) {
          topSnackBar(context, 'Product not found', type: TopSnackType.error);
          context.pop();
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
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      actionButton: CustomButton(
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
                    if (isUpdate) {
                      topSnackBar(context, 'Product updated successfully');
                    } else {
                      topSnackBar(context, 'Product created successfully');
                    }
                    context.pop(true);
                  } else {
                    topSnackBar(
                      context,
                      controller.provider.error ?? 'Error saving product',
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
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
                : null,
      ),
      body: Container(
        color: Colors.white,
        child: AbsorbPointer(
          absorbing: controller.isSubmitting,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                ItemFormFields(
                  controller: controller,
                  isUpdate: isUpdate,
                  formKey: controller.formKey,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
