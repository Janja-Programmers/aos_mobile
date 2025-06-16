import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/features/auth/presentation/auth_provider.dart';
import '../../../item/prov.dart';

class SelectableItemCodeField extends StatefulWidget {
  final String? value;
  final bool? readOnly;
  final void Function(String)? onChanged;

  const SelectableItemCodeField({
    super.key,
    this.value,
    this.readOnly = true,
    this.onChanged,
  });

  @override
  State<SelectableItemCodeField> createState() =>
      _SelectableItemCodeFieldState();
}

class _SelectableItemCodeFieldState extends State<SelectableItemCodeField> {
  List<String> codes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCodes();
  }

  Future<void> _loadCodes() async {
    final auth = context.read<AuthProvider>().user;
    final itemProv = context.read<ItemProv>();

    if (itemProv.items.isEmpty && !itemProv.isLoading) {
      await itemProv.loadItems();
    }

    final userItems = itemProv.items.where(
      (item) => item.owner == auth?.username,
    );

    setState(() {
      codes = userItems.map((e) => e.itemCode ?? "").toSet().toList()..sort();
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const CircularProgressIndicator();

    if (widget.readOnly == true) {
      return TextField(
        controller: TextEditingController(text: widget.value ?? ''),
        decoration: const InputDecoration(labelText: 'Code'),
        readOnly: true,
      );
    }

    return Autocomplete<String>(
      initialValue: TextEditingValue(text: widget.value ?? ''),
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text.isEmpty) return codes;
        return codes.where(
          (code) =>
              code.toLowerCase().contains(textEditingValue.text.toLowerCase()),
        );
      },
      onSelected: widget.onChanged,
      fieldViewBuilder: (
        context,
        textEditingController,
        focusNode,
        onFieldSubmitted,
      ) {
        return TextField(
          controller: textEditingController,
          focusNode: focusNode,
          decoration: const InputDecoration(labelText: 'Code'),
        );
      },
    );
  }
}
