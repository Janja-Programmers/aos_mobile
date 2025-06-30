import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '/core/utils/snackbar.dart';

import '/features/product/domain/product.dart';
import '/features/product/provider.dart';

import '/shared/widgets/app_drawer.dart';
import '/shared/widgets/main_bar.dart';
import '/shared/widgets/form_fields.dart';
import '/shared/widgets/action_button.dart';

class AddItemScreen extends StatefulWidget {
  final Product? product;

  const AddItemScreen({super.key, this.product});

  @override
  State<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  final _nameController = TextEditingController();
  final _groupController = TextEditingController();
  final _itemCodeController = TextEditingController();
  final _priceController = TextEditingController();
  final _descController = TextEditingController(); // long
  final _shortDescController = TextEditingController();

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();

    if (widget.product != null) {
      final product = widget.product!;
      _nameController.text = product.itemName;
      _groupController.text = product.category;
      _itemCodeController.text = product.name;
      _priceController.text = product.itemPrice.toString();
      _descController.text = product.websiteDescription ?? '';
      _shortDescController.text = product.shortWebsiteDescription ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _groupController.dispose();
    _itemCodeController.dispose();
    _priceController.dispose();
    _descController.dispose();
    _shortDescController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<ProductProvider>();

    setState(() => _isSubmitting = true);

    final product = Product(
      name: widget.product?.name ?? _itemCodeController.text.trim(),
      itemName: _nameController.text.trim(),
      itemPrice: double.tryParse(_priceController.text.trim()) ?? 0.0,
      category: _groupController.text.trim(),
      vendor: widget.product?.vendor,
      image: widget.product?.image,
      slideShow: widget.product?.slideShow,
      demoVideo: widget.product?.demoVideo,
      websiteDescription: _descController.text.trim(),
      shortWebsiteDescription: _shortDescController.text.trim(),
      websiteSpecifications: widget.product?.websiteSpecifications ?? [],
    );

    final success =
        widget.product == null
            ? await provider.createProduct(product)
            : await provider.updateExistingItem(product);

    setState(() => _isSubmitting = false);

    if (!mounted) return;

    if (success) {
      topSnackBar(context, 'Product saved successfully');
      context.pop();
    } else {
      topSnackBar(
        context,
        provider.error ?? 'Error saving product',
        type: TopSnackType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isUpdate = widget.product != null;

    return MainBarScaffold(
      scaffoldKey: _scaffoldKey,
      drawer: AppDrawer(selectedIndex: 1, onItemSelected: (_) {}),
      subTitle: isUpdate ? 'Update Item' : 'Create Item',
      body: AbsorbPointer(
        absorbing: _isSubmitting,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                AppTextField(
                  label: 'Item Name',
                  controller: _nameController,
                  isRequired: true,
                  readOnly: isUpdate,
                ),
                const SizedBox(height: 10),
                AppTextField(
                  label: 'Item Code',
                  controller: _itemCodeController,
                  isRequired: true,
                  readOnly: isUpdate,
                ),
                const SizedBox(height: 10),
                AppTextField(label: 'Item Group', controller: _groupController),
                const SizedBox(height: 16),
                AppTextField(
                  label: 'Item Price',
                  controller: _priceController,
                  isRequired: true,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 10),
                AppTextField(
                  label: 'Short Description',
                  controller: _shortDescController,
                  maxLines: 2,
                ),
                const SizedBox(height: 10),
                AppTextField(
                  label: 'Long Description',
                  controller: _descController,
                  maxLines: 4,
                ),
                const SizedBox(height: 24),
                ActionButton(
                  label: isUpdate ? 'Update Item' : 'Save Item',
                  onPressed: _submit,
                  isLoading: _isSubmitting,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
