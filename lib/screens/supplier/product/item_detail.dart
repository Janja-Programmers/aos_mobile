// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/features/auth/presentation/auth_provider.dart';
import '/features/item/prov.dart';
import '/features/item/domain/entity.dart';

import '../../../shared/widgets/app_drawer.dart';
import '../../../shared/widgets/labeled_card.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/main_bar.dart';
import '../../../shared/widgets/selectable_field.dart';

class ItemDetailScreen extends StatefulWidget {
  final String? itemName;

  const ItemDetailScreen({super.key, this.itemName});

  @override
  State<ItemDetailScreen> createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends State<ItemDetailScreen> {
  late final _nameCtrl = TextEditingController();
  late final _groupCtrl = TextEditingController();

  String? _itemCode;
  bool _disabled = false;
  bool _loading = false;

  late final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.itemName != null) {
      final item = context.read<ItemProv>().getItemById(widget.itemName!);
      if (item != null) {
        _nameCtrl.text = item.itemName ?? item.name;
        _itemCode = item.itemCode ?? '';
        _groupCtrl.text = item.itemGroup ?? '';
        _disabled = item.disabled == 1;
      }
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _groupCtrl.dispose();
    super.dispose();
  }

  Future<void> _onSave() async {
    if (_nameCtrl.text.trim().isEmpty || (_itemCode?.isEmpty ?? true)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Name & Code are required')));
      return;
    }

    setState(() => _loading = true);

    final auth = context.read<AuthProvider>().user;
    final provider = context.read<ItemProv>();

    final entity = Item(
      name: widget.itemName ?? '',
      owner: auth?.username ?? '',
      itemCode: _itemCode,
      itemName: _nameCtrl.text.trim(),
      itemGroup: _groupCtrl.text.trim(),
      disabled: _disabled ? 1 : 0,
    );

    final ok =
        widget.itemName == null
            ? await provider.addItem(entity)
            : await provider.updateExistingItem(entity); //

    setState(() => _loading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(ok ? 'Saved' : provider.error ?? 'Error')),
    );

    if (ok) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return MainBarScaffold(
      scaffoldKey: _scaffoldKey,
      drawer: AppDrawer(selectedIndex: 3, onItemSelected: (_) {}),
      subTitle: widget.itemName == null ? 'Create Item' : 'Update Item',
      actionButton: CustomButton(
        label: 'Save',
        icon: Icons.save,
        pageBuilder: () => widget,
      ),
      onSave: _loading ? null : _onSave,
      body: AbsorbPointer(
        absorbing: _loading,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ► basic section
            LabeledCard(
              label: 'Basic',
              child: Column(
                children: [
                  TextField(
                    controller: _nameCtrl,
                    decoration: const InputDecoration(labelText: 'Name'),
                  ),
                  const SizedBox(height: 8),
                  SelectableItemCodeField(
                    value: _itemCode,
                    readOnly: widget.itemName != null,
                    onChanged: (code) => setState(() => _itemCode = code),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _groupCtrl,
                    decoration: const InputDecoration(labelText: 'Group'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // ► status section
            LabeledCard(
              label: 'Status',
              child: Row(
                children: [
                  Checkbox(
                    value: _disabled,
                    onChanged: (v) => setState(() => _disabled = v ?? false),
                  ),
                  const Text('Disabled'),
                ],
              ),
            ),

            if (_loading)
              const Padding(
                padding: EdgeInsets.only(top: 24),
                child: Center(child: CircularProgressIndicator()),
              ),
          ],
        ),
      ),
    );
  }
}
