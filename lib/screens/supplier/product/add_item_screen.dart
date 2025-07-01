import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:ownashop/core/di/service_locator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/utils/api_client.dart';
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
  final _descController = TextEditingController();
  final _shortDescController = TextEditingController();
  File? _selectedImage;
  File? _selectedVideo;
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

  Future<void> _pickFile({required bool isImage}) async {
    final permissionResult = await _requestPermissions(isImage: isImage);
    if (!permissionResult.granted) {
      if (permissionResult.permanentlyDenied) {
        topSnackBar(
          context,
          'Please enable ${isImage ? 'photos' : 'videos'} permission in app settings',
          type: TopSnackType.error,
        );
        await openAppSettings();
      } else {
        topSnackBar(
          context,
          'Permission denied for ${isImage ? 'photos' : 'videos'}',
          type: TopSnackType.error,
        );
      }
      return;
    }

    final result = await FilePicker.platform.pickFiles(
      type: isImage ? FileType.image : FileType.video,
      allowMultiple: false,
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        if (isImage) {
          _selectedImage = File(result.files.single.path!);
        } else {
          _selectedVideo = File(result.files.single.path!);
        }
      });
    }
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
      imageFile: _selectedImage,
      slideShow: widget.product?.slideShow,
      demoVideo: widget.product?.demoVideo,
      videoFile: _selectedVideo,
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

  Future<PermissionResult> _requestPermissions({required bool isImage}) async {
    Permission permission;

    if (Platform.isAndroid) {
      permission = Permission.storage; // use storage for all file access
    } else if (Platform.isIOS) {
      permission = Permission.photos; // photos covers images/videos
    } else {
      return PermissionResult(granted: true, permanentlyDenied: false);
    }

    var status = await permission.status;
    print('Permission status: $status');

    if (status.isGranted) {
      return PermissionResult(granted: true, permanentlyDenied: false);
    }

    status = await permission.request();

    if (status.isGranted) {
      return PermissionResult(granted: true, permanentlyDenied: false);
    }

    if (status.isPermanentlyDenied) {
      return PermissionResult(granted: false, permanentlyDenied: true);
    }

    return PermissionResult(granted: false, permanentlyDenied: false);
  }

  Future<List<String>> _fetchItemGroups() async {
    final client = sl<APIClient>();
    final response = await client.client.get(
      'https://ownashop.com/api/resource/Item Group',
      queryParameters: {'fields': '["name"]', 'limit_page_length': 100},
    );
    final List data = response.data['data'];
    return data.map((e) => e['name'] as String).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isUpdate = widget.product != null;
    final imageUrl =
        widget.product?.image != null
            ? 'https://ownashop.com${widget.product!.image}'
            : null;
    final videoUrl =
        widget.product?.demoVideo != null
            ? 'https://ownashop.com${widget.product!.demoVideo}'
            : null;

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
                FutureBuilder<List<String>>(
                  future: _fetchItemGroups(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const CircularProgressIndicator();
                    }

                    final groups = snapshot.data!;
                    return DropdownButtonFormField<String>(
                      value:
                          _groupController.text.isNotEmpty &&
                                  groups.contains(_groupController.text)
                              ? _groupController.text
                              : null,
                      items:
                          groups
                              .map(
                                (g) =>
                                    DropdownMenuItem(value: g, child: Text(g)),
                              )
                              .toList(),
                      onChanged: (val) => _groupController.text = val ?? '',
                      decoration: const InputDecoration(
                        labelText: 'Item Group',
                        border: OutlineInputBorder(),
                      ),
                      validator:
                          (val) =>
                              val == null || val.isEmpty
                                  ? 'Select an item group'
                                  : null,
                    );
                  },
                ),

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
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Image picker UI
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Product Image',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          const SizedBox(height: 8),
                          _selectedImage != null
                              ? Image.file(
                                _selectedImage!,
                                height: 100,
                                width: 100,
                                fit: BoxFit.cover,
                              )
                              : imageUrl != null
                              ? Image.network(
                                imageUrl,
                                height: 100,
                                width: 100,
                                fit: BoxFit.cover,
                                errorBuilder:
                                    (context, error, stackTrace) =>
                                        const Icon(Icons.error),
                              )
                              : const Text('No image selected'),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: () => _pickFile(isImage: true),
                            child: const Text('Pick Image'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Video picker UI
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Demo Video',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          const SizedBox(height: 8),
                          _selectedVideo != null
                              ? Text(
                                'Selected: ${_selectedVideo!.path.split('/').last}',
                              )
                              : videoUrl != null
                              ? Text('Video: $videoUrl')
                              : const Text('No video selected'),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: () => _pickFile(isImage: false),
                            child: const Text('Pick Video'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
                const SizedBox(height: 16),

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

class PermissionResult {
  final bool granted;
  final bool permanentlyDenied;

  PermissionResult({required this.granted, required this.permanentlyDenied});
}
