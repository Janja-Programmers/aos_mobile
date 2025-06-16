import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/features/website/domain/webitem.dart';
import '/features/website/prov.dart';
import '/features/auth/presentation/auth_provider.dart';
import '/features/shared/widgets/custom_button.dart';

import '../../shared/widgets/app_drawer.dart';
import '../../shared/widgets/main_bar.dart';

import 'widgets/custom_text_controller.dart';
import 'widgets/file_upload.dart';
import 'widgets/labeled_card.dart';
import 'widgets/selectable_field.dart';

class AddWebsiteItemScreen extends StatefulWidget {
  final WebsiteItem? existingItem;

  const AddWebsiteItemScreen({super.key, this.existingItem});

  @override
  State<AddWebsiteItemScreen> createState() => _AddWebsiteItemScreenState();
}

class _AddWebsiteItemScreenState extends State<AddWebsiteItemScreen> {
  // ───── text controllers ─────
  late final _nameCtrl = TextEditingController(text: widget.existingItem?.name);
  late final _shortCtrl = TextEditingController(
    text: widget.existingItem?.shortDescription,
  );
  late final _longCtrl = TextEditingController(
    text: widget.existingItem?.longDescription,
  );

  // ───── state ─────
  String? _itemCode; // ← selected code (was _codeCtrl)
  bool _isPublished = false;
  bool _isLoading = false;
  List<String> _images = [];
  String? _video;

  @override
  void initState() {
    super.initState();
    if (widget.existingItem != null) {
      final itm = widget.existingItem!;
      _isPublished = itm.published;
      _itemCode = itm.itemCode;
      _images = itm.imageUrl.isNotEmpty ? [itm.imageUrl] : [];
      _video = itm.demoVideoUrl?.isNotEmpty == true ? itm.demoVideoUrl : null;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _shortCtrl.dispose();
    _longCtrl.dispose();
    super.dispose();
  }

  // ───────────────────────── submit ─────────────────────────
  Future<void> _onSave() async {
    if (_nameCtrl.text.trim().isEmpty || (_itemCode?.isEmpty ?? true)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Name & Code are required')));
      return;
    }

    setState(() => _isLoading = true);

    final auth = context.read<AuthProvider>().user!;
    final provider = context.read<WebsiteItemProv>();

    final entity = WebsiteItem(
      id: widget.existingItem?.id ?? '',
      name: _nameCtrl.text.trim(),
      owner: auth.username,
      imageUrl: _images.isNotEmpty ? _images.first : '',
      demoVideoUrl: _video ?? '',
      itemCode: _itemCode!,
      shortDescription: _shortCtrl.text.trim(),
      longDescription: _longCtrl.text.trim(),
      published: _isPublished,
      specifications: const [],
      itemGroup: '',
      description: '',
      thumbnailUrl: '',
      onBackorder: false,
      title: '',
    );

    final ok =
        widget.existingItem == null
            ? await provider.addItem(entity)
            : await provider.updateExistingItem(entity.id, entity);

    setState(() => _isLoading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok ? 'Saved successfully' : provider.error ?? 'Error'),
      ),
    );
    if (ok) Navigator.of(context).pop();
  }

  // ───────────────────────── view ─────────────────────────
  @override
  Widget build(BuildContext context) {
    return MainBarScaffold(
      subTitle:
          widget.existingItem == null
              ? 'Create Website Item'
              : 'Update Website Item',
      scaffoldKey: GlobalKey<ScaffoldState>(),
      drawer: AppDrawer(selectedIndex: 4, onItemSelected: (_) {}),
      actionButton: CustomButton(
        label: 'Save',
        icon: Icons.save,
        pageBuilder: () => widget,
      ),
      onSave: _isLoading ? null : _onSave,
      body: AbsorbPointer(
        absorbing: _isLoading,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ► name & code
            LabeledCard(
              label: 'Basic',
              child: Column(
                children: [
                  CustomTextField(controller: _nameCtrl, label: 'Name'),
                  const SizedBox(height: 8),
                  SelectableItemCodeField(
                    value: _itemCode,
                    readOnly: widget.existingItem != null,
                    onChanged: (code) => setState(() => _itemCode = code),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // images
            ImagePickerField(
              paths: _images,
              onChanged: (paths) => setState(() => _images = paths),
            ),
            const SizedBox(height: 12),

            // video
            VideoPickerField(
              path: _video,
              onChanged: (p) => setState(() => _video = p),
            ),
            const SizedBox(height: 12),

            // descriptions
            LabeledCard(
              label: 'Descriptions',
              child: Column(
                children: [
                  CustomTextField(
                    controller: _shortCtrl,
                    label: 'Short Description',
                    maxLines: 2,
                  ),
                  const SizedBox(height: 8),
                  CustomTextField(
                    controller: _longCtrl,
                    label: 'Long Description',
                    maxLines: 4,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // publish
            LabeledCard(
              label: 'Publish',
              child: Row(
                children: [
                  Checkbox(
                    value: _isPublished,
                    onChanged: (v) => setState(() => _isPublished = v ?? false),
                  ),
                  const Text('Visible on website'),
                ],
              ),
            ),

            if (_isLoading)
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
