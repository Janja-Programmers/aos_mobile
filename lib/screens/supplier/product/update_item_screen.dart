import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '/core/utils/snackbar.dart';

import '/features/product/domain/product.dart';

import '/shared/widgets/app_drawer.dart';
import '/shared/widgets/custom_button.dart';
import '/shared/widgets/main_bar.dart';

import 'controllers/add_item_controller.dart';
import 'sections/image_video_picker.dart';
import 'sections/item_form_fields.dart';

class AddItemScreen extends StatefulWidget {
  final Product? product;
  const AddItemScreen({super.key, this.product});

  @override
  State<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final ctrl = context.read<AddItemController>();
      ctrl.reset();
      if (widget.product != null) {
        ctrl.setInitialProduct(widget.product!);
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
      subTitle: isUpdate ? 'Update Product' : 'Create Product',
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
                    topSnackBar(context, 'Product saved successfully');
                    context.pop();
                  } else {
                    topSnackBar(
                      context,
                      controller.provider.error ?? 'Error saving product',
                      type: TopSnackType.error,
                    );
                  }
                },
      ),
      body: AbsorbPointer(
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
              const SizedBox(height: 16),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Display Images',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              const SizedBox(height: 8),
              ImageVideoPickerSection(
                controller: controller,
                product: widget.product,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
