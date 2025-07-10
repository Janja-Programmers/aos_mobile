import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/core/utils/validators.dart';
import '../controllers/add_item_controller.dart';
import '/shared/widgets/form_fields.dart';

class ItemFormFields extends StatefulWidget {
  final AddItemController controller;
  final bool isUpdate;
  final GlobalKey<FormState> formKey;

  const ItemFormFields({
    super.key,
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
                        .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                        .toList(),
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
                validator:
                    (value) =>
                        (value == null || value.isEmpty)
                            ? 'Category is required'
                            : null,
              );
            },
          ),
          const SizedBox(height: 20),

          // ℹ️ Display Information
          const Text(
            'Display Information',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),

          // 🔶 Website Description
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Website Description"),
                  TextButton(
                    onPressed: () {
                      setState(() => showRawEditor = !showRawEditor);
                    },
                    child: Text(showRawEditor ? 'Preview' : 'Edit HTML'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
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
          Row(
            children: [
              Text(
                'Website Specifications',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(width: 8),
              TextButton.icon(
                onPressed: controller.addSpecificationFromNewRow,
                icon: const Icon(Icons.add, size: 18, color: Colors.black),
                label: const Text(
                  'Add Row',
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          Consumer<AddItemController>(
            builder: (_, controller, _) {
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.all(12),
                itemCount: controller.specControllers.length,
                itemBuilder: (context, index) {
                  final entry = controller.specControllers[index];
                  return Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: entry.labelController,
                          decoration: const InputDecoration(labelText: 'Label'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextFormField(
                          controller: entry.descriptionController,
                          decoration: const InputDecoration(
                            labelText: 'Description',
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          controller.removeSpecification(index);
                        },
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
