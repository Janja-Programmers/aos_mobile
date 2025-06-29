import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '/core/utils/snackbar.dart';

import '/features/product/provider.dart';
import '/features/product/domain/product.dart';

import '/shared/utils/media_picker.dart';
import '/shared/widgets/action_button.dart';
import '/shared/widgets/app_drawer.dart';
import '/shared/widgets/main_bar.dart';
import '/shared/widgets/form_fields.dart';

class AddItemScreen extends StatefulWidget {
  const AddItemScreen({super.key});

  @override
  State<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _categoryController = TextEditingController();
  final _descController = TextEditingController();
  final _shortDescController = TextEditingController();

  String? _imagePath;
  String? _videoPath;

  bool _isSubmitting = false;

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<ProductProvider>();

    setState(() => _isSubmitting = true);

    final product = Product(
      name: '',
      itemName: _nameController.text.trim(),
      itemPrice: double.tryParse(_priceController.text.trim()) ?? 0.0,
      category: _categoryController.text.trim(),
      vendor: null,
      image: _imagePath,
      slideShow: null,
      demoVideo: _videoPath,
      websiteDescription: _descController.text.trim(),
      shortWebsiteDescription: _shortDescController.text.trim(),
      websiteSpecifications: [],
    );

    await provider.createProduct(product);
    setState(() => _isSubmitting = false);

    if (!mounted) return;

    if (provider.error == null) {
      topSnackBar(context, 'Product created successfully!');
      context.pop();
    } else {
      topSnackBar(
        context,
        "Error: ${provider.error}",
        type: TopSnackType.error,
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _categoryController.dispose();
    _descController.dispose();
    _shortDescController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MainBarScaffold(
      drawer: AppDrawer(selectedIndex: 1, onItemSelected: (_) {}),
      scaffoldKey: _scaffoldKey,
      subTitle: "Add Item",
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              AppTextField(
                label: "Item Name",
                controller: _nameController,
                isRequired: true,
              ),
              const SizedBox(height: 10),
              AppTextField(
                label: "Price",
                controller: _priceController,
                keyboardType: TextInputType.number,
                isRequired: true,
              ),
              const SizedBox(height: 10),
              AppTextField(label: "Category", controller: _categoryController),
              const SizedBox(height: 10),
              AppTextField(
                label: "Short Description",
                controller: _shortDescController,
                maxLines: 2,
              ),
              const SizedBox(height: 10),
              AppTextField(
                label: "Long Description",
                controller: _descController,
                maxLines: 4,
              ),
              const SizedBox(height: 16),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    MediaPicker(
                      label: "Select Image",
                      filePath: _imagePath,
                      onPick: (path) => setState(() => _imagePath = path),
                      type: MediaType.image,
                    ),
                    SizedBox(width: 12),
                    MediaPicker(
                      label: "Select Video",
                      filePath: _videoPath,
                      onPick: (path) => setState(() => _videoPath = path),
                      type: MediaType.video,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              ActionButton(
                label: "Save Product",
                onPressed: _submit,
                isLoading: _isSubmitting,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
