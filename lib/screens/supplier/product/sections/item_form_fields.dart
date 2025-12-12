import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/core/utils/validators.dart';
import '/features/product/domain/product.dart';
import '/shared/widgets/form_fields.dart';

import '../controllers/add_item_controller.dart';
import '../widgets/web_spec_table.dart';

import 'image_video_picker.dart';

class ItemFormFields extends StatefulWidget {
  final Product? product;
  final AddItemController controller;
  final bool isUpdate;
  final GlobalKey<FormState> formKey;

  const ItemFormFields({
    super.key,
    this.product,
    required this.controller,
    required this.isUpdate,
    required this.formKey,
  });

  @override
  State<ItemFormFields> createState() => _ItemFormFieldsState();
}

class _ItemFormFieldsState extends State<ItemFormFields> {
  bool showRawEditor = true;
  List<String> _categories = [];
  bool _isLoadingCategories = true;
  String? _categoryError;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final groups = await widget.controller.fetchItemGroups();
      setState(() {
        _categories = groups;
        _isLoadingCategories = false;
      });
    } catch (e) {
      setState(() {
        _categoryError = 'Failed to load categories';
        _isLoadingCategories = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;

    const fieldSpacing = SizedBox(height: 16);

    return Form(
      key: widget.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔷 Item Name
          AppTextField(
            label: 'Item Name',
            controller: controller.nameController,
            isRequired: true,
            maxLength: 100,
            validator:
                (val) => AppValidator.required(val, fieldName: 'Item Name'),
          ),
          fieldSpacing,

          // 🔷 Item Price
          AppTextField(
            label: 'Item Price',
            controller: controller.priceController,
            maxLength: 10,
            isRequired: true,
            keyboardType: TextInputType.number,
            validator:
                (val) => AppValidator.isNumber(val, fieldName: 'Item Price'),
          ),
          fieldSpacing,

          // 🔷 Category Dropdown
          if (_isLoadingCategories)
            const Center(child: CircularProgressIndicator())
          else if (_categoryError != null)
            Text(_categoryError!, style: const TextStyle(color: Colors.red))
          else
            DropdownButtonFormField<String>(
              isExpanded: true,
              menuMaxHeight: 250,
              value:
                  controller.groupController.text.isNotEmpty
                      ? controller.groupController.text
                      : null,
              onChanged: (val) {
                controller.groupController.text = val ?? '';
              },
              items:
                  _categories
                      .map(
                        (g) => DropdownMenuItem(
                          value: g,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12.0,
                            ),
                            child: Text(
                              g,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 15),
                            ),
                          ),
                        ),
                      )
                      .toList(),
              decoration: InputDecoration(
                labelText: 'Category *',
                border: const OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
              validator:
                  (val) => AppValidator.required(val, fieldName: 'Category'),
            ),
          fieldSpacing,

          // 🔷 Maintain Stock Checkbox
          Consumer<AddItemController>(
            builder: (_, controller, _) {
              return Row(
                children: [
                  Checkbox(
                    value: controller.maintainStock,
                    onChanged:
                        (value) => controller.setMaintainStock(value ?? false),
                  ),
                  Text(
                    'Maintain Stock',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              );
            },
          ),
          fieldSpacing,

          // 🖼️ Display Images
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
          fieldSpacing,

          // ℹ️ Display Information
          const Text(
            'Display Information',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),

          // 🔶 Website Description
          if (showRawEditor)
            AppTextField(
              label: 'Website Description',
              controller: controller.descController,
              maxLines: 6,
              maxLength: 1000,
              keyboardType: TextInputType.multiline,
            )
          else
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                controller.descController.text.trim().isEmpty
                    ? 'No description added.'
                    : controller.descController.text.trim(),
                style: const TextStyle(fontSize: 14),
              ),
            ),
          fieldSpacing,

          // 🔶 Short Website Description
          AppTextField(
            label: 'Short Website Description',
            controller: controller.shortDescController,
            maxLines: 2,
          ),
          fieldSpacing,

          // 🔶 Website Specifications Table
          Consumer<AddItemController>(
            builder:
                (_, controller, _) =>
                    WebsiteSpecificationsTable(controller: controller),
          ),
        ],
      ),
    );
  }
}
