import 'package:flutter/material.dart';

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
  bool showRawEditor = false;

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;

    return Form(
      key: widget.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppTextField(
            label: 'Item Name',
            controller: controller.nameController,
            isRequired: true,
            validator:
                (val) => AppValidator.required(val, fieldName: 'Item Name'),
          ),
          const SizedBox(height: 10),

          AppTextField(
            label: 'Item Code',
            controller: controller.itemCodeController,
            isRequired: true,
            readOnly: widget.isUpdate,
            validator:
                (val) => AppValidator.required(val, fieldName: 'Item Code'),
          ),
          const SizedBox(height: 10),

          AppTextField(
            label: 'Item Price',
            controller: controller.priceController,
            isRequired: true,
            keyboardType: TextInputType.number,
            validator:
                (val) => AppValidator.isNumber(val, fieldName: 'Item Price'),
          ),
          const SizedBox(height: 10),

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
                  labelText: 'Category (Item Group)',
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
          const SizedBox(height: 10),

          AppTextField(
            label: 'Short Description',
            controller: controller.shortDescController,
            maxLines: 2,
          ),
          const SizedBox(height: 10),

          // 🔻 Long Description with toggle
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Long Description"),
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
                  label: 'Long Description',
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

          // 🧩 Specification list
          if (controller.websiteSpecifications.isNotEmpty)
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.websiteSpecifications.length,
              itemBuilder: (context, index) {
                final spec = controller.websiteSpecifications[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  child: ListTile(
                    title: Text(spec.label),
                    subtitle: Text(spec.description),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => controller.removeSpecification(index),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
