import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '/core/di/service_locator.dart';
import '/core/utils/api_client.dart';
import '/core/utils/snackbar.dart';

import '/features/product/domain/product.dart';
import '/features/product/provider.dart';

import '/shared/widgets/main_bar.dart';
import '/shared/widgets/app_drawer.dart';
import '/shared/widgets/action_button.dart';

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
  late final AddItemController controller;
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    controller = AddItemController(
      provider: context.read<ProductProvider>(),
      apiClient: sl<APIClient>(),
      initialProduct: widget.product,
    );
  }

  @override
  void dispose() {
    controller.disposeControllers();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: controller,
      child: Consumer<AddItemController>(
        builder: (context, ctrl, _) {
          final isUpdate = widget.product != null;
          return MainBarScaffold(
            drawer: AppDrawer(selectedIndex: 1, onItemSelected: (_) {}),
            scaffoldKey: _scaffoldKey,
            subTitle: isUpdate ? 'Update Product' : 'Create Product',
            body: AbsorbPointer(
              absorbing: ctrl.isSubmitting,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    ItemFormFields(
                      controller: ctrl,
                      isUpdate: isUpdate,
                      formKey: ctrl.formKey,
                    ),
                    const SizedBox(height: 16),
                    ImageVideoPickerSection(
                      controller: ctrl,
                      product: widget.product,
                    ),
                    const SizedBox(height: 16),
                    ActionButton(
                      label: isUpdate ? 'Update Product' : 'Save Product',
                      isLoading: ctrl.isSubmitting,
                      onPressed: () async {
                        final success = await ctrl.submit(
                          context,
                          widget.product,
                        );
                        if (!mounted) return;
                        if (success) {
                          topSnackBar(context, 'Product saved successfully');
                          context.pop();
                        } else {
                          topSnackBar(
                            context,
                            ctrl.provider.error ?? 'Error saving product',
                            type: TopSnackType.error,
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
