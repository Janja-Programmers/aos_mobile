import 'package:flutter/material.dart';

import '/core/utils/validators.dart';

import '../controllers/add_item_controller.dart';

import '/shared/widgets/form_fields.dart';

class ItemFormFields extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        children: [
          AppTextField(
            label: 'Item Name',
            controller: controller.nameController,
            isRequired: true,
            readOnly: isUpdate,
            validator:
                (val) => AppValidator.required(val, fieldName: 'Item Name'),
          ),
          const SizedBox(height: 10),
          AppTextField(
            label: 'Item Code',
            controller: controller.itemCodeController,
            isRequired: true,
            readOnly: isUpdate,
            validator:
                (val) => AppValidator.required(val, fieldName: 'Item Code'),
          ),
          const SizedBox(height: 10),
          // Group dropdown is already validated in its own builder
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
          AppTextField(
            label: 'Long Description',
            controller: controller.descController,
            maxLines: 4,
          ),
        ],
      ),
    );
  }
}
