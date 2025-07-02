import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '/shared/widgets/app_drawer.dart';
import '/shared/widgets/main_bar.dart';
import '/shared/widgets/action_button.dart';

import '/core/utils/api_client.dart';
import '/core/utils/snackbar.dart';
import '/core/di/service_locator.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final nameController = TextEditingController();
  final priceController = TextEditingController();
  final descController = TextEditingController();
  final shortDescController = TextEditingController();
  String? selectedCategory;
  File? selectedImage;
  File? selectedVideo;
  String? uploadedImageUrl;
  String? uploadedVideoUrl;
  bool isSubmitting = false;

  Future<void> pickFile({required bool isImage}) async {
    final permission =
        Platform.isAndroid ? Permission.storage : Permission.photos;
    final result = await permission.request();
    if (!result.isGranted) {
      if (result.isPermanentlyDenied) await openAppSettings();
      return;
    }
    final picked = await FilePicker.platform.pickFiles(
      type: isImage ? FileType.image : FileType.video,
    );
    if (picked != null && picked.files.single.path != null) {
      final file = File(picked.files.single.path!);
      final url = await uploadFile(file);
      setState(() {
        if (isImage) {
          selectedImage = file;
          uploadedImageUrl = url;
        } else {
          selectedVideo = file;
          uploadedVideoUrl = url;
        }
      });
    }
  }

  Future<String?> uploadFile(File file) async {
    try {
      final fileName = file.path.split('/').last;
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(file.path, filename: fileName),
      });
      final response = await sl<APIClient>().client.post(
        '/api/method/upload_file',
        data: formData,
      );
      return response.data['message']['file_url'];
    } catch (e) {
      debugPrint('Upload failed: $e');
      return null;
    }
  }

  Future<List<String>> fetchItemGroups() async {
    try {
      final res = await sl<APIClient>().client.get(
        'https://ownashop.com/api/resource/Item Group',
        queryParameters: {
          'fields': '["name"]',
          'limit_page_length': 20,
          'filters': '[["is_group", "=", 0]]',
        },
      );
      return (res.data['data'] as List)
          .map((e) => e['name'] as String)
          .toList();
    } catch (e) {
      debugPrint('Group fetch error: $e');
      return [];
    }
  }

  Future<void> submit() async {
    if (!formKey.currentState!.validate()) {
      topSnackBar(
        context,
        'Please fix the form errors',
        type: TopSnackType.error,
      );
      return;
    }

    setState(() => isSubmitting = true);

    try {
      final payload = {
        "item_name": nameController.text.trim(),
        "item_price": double.tryParse(priceController.text.trim()) ?? 0.0,
        "category": selectedCategory,
        "website_description": descController.text.trim(),
        "short_website_description": shortDescController.text.trim(),
        "image": uploadedImageUrl,
        "demo_video": uploadedVideoUrl,
      };

      debugPrint('Submitting product: $payload');

      final res = await sl<APIClient>().client.post(
        'https://ownashop.com/api/resource/Product',
        data: payload,
      );

      debugPrint('✅ Product created: ${res.data}');
      if (!mounted) return;
      topSnackBar(context, 'Product created successfully');
      Navigator.pop(context);
    } catch (e) {
      debugPrint('❌ Submit failed: $e');
      topSnackBar(
        context,
        'Failed to create product',
        type: TopSnackType.error,
      );
    } finally {
      setState(() => isSubmitting = false);
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    priceController.dispose();
    descController.dispose();
    shortDescController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget content;
    content = SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: formKey,
        child: Column(
          children: [
            TextFormField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Item Name'),
              validator:
                  (val) => val == null || val.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Item Price'),
              validator:
                  (val) =>
                      val == null || double.tryParse(val) == null
                          ? 'Enter valid number'
                          : null,
            ),
            const SizedBox(height: 12),
            FutureBuilder<List<String>>(
              future: fetchItemGroups(),
              builder: (context, snapshot) {
                final groups = snapshot.data ?? [];
                return DropdownButtonFormField<String>(
                  value: selectedCategory,
                  onChanged: (val) => setState(() => selectedCategory = val),
                  items:
                      groups
                          .map(
                            (g) => DropdownMenuItem(value: g, child: Text(g)),
                          )
                          .toList(),
                  decoration: const InputDecoration(
                    labelText: 'Category (Item Group)',
                    border: OutlineInputBorder(),
                  ),
                  validator:
                      (val) =>
                          val == null || val.isEmpty
                              ? 'Category is required'
                              : null,
                );
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: shortDescController,
              maxLines: 2,
              decoration: const InputDecoration(labelText: 'Short Description'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: descController,
              maxLines: 4,
              decoration: const InputDecoration(labelText: 'Long Description'),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () => pickFile(isImage: true),
                  icon: const Icon(Icons.image),
                  label: const Text('Pick Image'),
                ),
                ElevatedButton.icon(
                  onPressed: () => pickFile(isImage: false),
                  icon: const Icon(Icons.videocam),
                  label: const Text('Pick Video'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            ActionButton(
              label: 'Save Product',
              isLoading: isSubmitting,
              onPressed: submit,
            ),
          ],
        ),
      ),
    );

    return MainBarScaffold(
      drawer: AppDrawer(selectedIndex: 1, onItemSelected: (_) {}),
      scaffoldKey: _scaffoldKey,
      subTitle: "Items",
      body: content,
    );
  }
}
