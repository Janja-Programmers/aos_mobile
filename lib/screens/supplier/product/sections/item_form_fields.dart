import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/web_spec_table.dart';
import '/features/product/domain/product.dart';
import '/core/utils/validators.dart';

import '../controllers/add_item_controller.dart';

import '/shared/widgets/form_fields.dart';
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
  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    final isUpdate = widget.isUpdate;

    return Form(
      key: widget.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Only show Item Code in update mode
          if (isUpdate) ...[
            const Divider(),
            AppTextField(
              label: 'Item Code',
              controller: controller.itemCodeController,
              readOnly: true,
            ),
          ],
          const SizedBox(height: 10),

          // 🔷 Item Name
          AppTextField(
            label: 'Item Name',
            controller: controller.nameController,
            isRequired: true,
            validator:
                (val) => AppValidator.required(val, fieldName: 'Item Name'),
          ),
          const SizedBox(height: 10),

          // 🔷 Item Price
          AppTextField(
            label: 'Item Price',
            controller: controller.priceController,
            isRequired: true,
            keyboardType: TextInputType.number,
            validator:
                (val) => AppValidator.isNumber(val, fieldName: 'Item Price'),
          ),
          const SizedBox(height: 10),

          // 🔷 Category
          FutureBuilder<List<String>>(
            future: controller.fetchItemGroups(),
            builder: (context, snapshot) {
              final groups = snapshot.data ?? [];
              return DropdownButtonFormField<String>(
                value:
                    controller.groupController.text.isNotEmpty
                        ? controller.groupController.text
                        : null,
                onChanged: (val) => controller.groupController.text = val ?? '',
                items:
                    groups
                        .map(
                          (g) => DropdownMenuItem(
                            value: g,
                            child: Text(g, overflow: TextOverflow.ellipsis),
                          ),
                        )
                        .toList(),
                decoration: InputDecoration(
                  label: FittedBox(
                    alignment: Alignment.centerLeft,
                    child: RichText(
                      text: TextSpan(
                        text: 'Category',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.grey[700],
                        ),
                        children: const [
                          TextSpan(
                            text: ' *',
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  border: const OutlineInputBorder(),
                ),
                validator:
                    (value) =>
                        (value == null || value.isEmpty)
                            ? 'Category is required'
                            : null,
              );
            },
          ),
          const SizedBox(height: 10),

          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Display Images',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          const SizedBox(height: 10),

          ImageVideoPickerSection(
            controller: controller,
            product: widget.product,
          ),
          const SizedBox(height: 10),

          // ℹ️ Display Information
          const Text(
            'Display Information',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),

          // 🔶 Website Description
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (showRawEditor)
                AppTextField(
                  label: 'Website Description',
                  controller: controller.descController,
                  maxLines: 6,
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
            ],
          ),
          const SizedBox(height: 10),

          // 🔶 Short Website Description
          AppTextField(
            label: 'Short Website Description',
            controller: controller.shortDescController,
            maxLines: 2,
          ),
          const SizedBox(height: 10),

          // 🔶 Website Specifications
          Consumer<AddItemController>(
            builder:
                (_, controller, _) =>
                    WebsiteSpecificationsTable(controller: controller),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
