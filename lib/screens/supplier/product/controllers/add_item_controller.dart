import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:file_picker/file_picker.dart';

import '/core/di/service_locator.dart';
import '/core/utils/api_client.dart';

import '/features/product/domain/product.dart';
import '/features/product/provider.dart';

class AddItemController extends ChangeNotifier {
  final ProductProvider provider;
  final APIClient apiClient;
  final formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final groupController = TextEditingController();
  final itemCodeController = TextEditingController();
  final priceController = TextEditingController();
  final descController = TextEditingController();
  final shortDescController = TextEditingController();

  File? selectedImage;
  File? selectedVideo;
  bool isSubmitting = false;

  AddItemController({
    required this.provider,
    required this.apiClient,
    Product? initialProduct,
  }) {
    if (initialProduct != null) {
      nameController.text = initialProduct.itemName;
      groupController.text = initialProduct.category;
      itemCodeController.text = initialProduct.name;
      priceController.text = initialProduct.itemPrice.toString();
      descController.text = initialProduct.websiteDescription ?? '';
      shortDescController.text = initialProduct.shortWebsiteDescription ?? '';
    }
  }

  Future<void> pickFile(BuildContext context, {required bool isImage}) async {
    final permissionResult = await _requestPermissions(isImage: isImage);
    if (!permissionResult.granted) {
      if (permissionResult.permanentlyDenied) {
        await openAppSettings();
      }
      return;
    }

    final result = await FilePicker.platform.pickFiles(
      type: isImage ? FileType.image : FileType.video,
    );

    if (result != null && result.files.single.path != null) {
      if (isImage) {
        selectedImage = File(result.files.single.path!);
      } else {
        selectedVideo = File(result.files.single.path!);
      }
      notifyListeners();
    }
  }

  Future<PermissionResult> _requestPermissions({required bool isImage}) async {
    Permission permission;

    if (Platform.isAndroid) {
      permission = Permission.storage;
    } else {
      permission = Permission.photos;
    }

    var status = await permission.request();
    return PermissionResult(
      granted: status.isGranted,
      permanentlyDenied: status.isPermanentlyDenied,
    );
  }

  Future<List<String>> fetchItemGroups() async {
    final response = await apiClient.client.get(
      'https://ownashop.com/api/resource/Item Group',
      queryParameters: {'fields': '["name"]', 'limit_page_length': 100},
    );
    final List data = response.data['data'];
    return data.map((e) => e['name'] as String).toList();
  }

  Future<String?> uploadFile(File? file) async {
    if (file == null) return null;

    try {
      final fileName = file.path.split('/').last;
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(file.path, filename: fileName),
      });

      final client = sl<APIClient>();

      final response = await client.client.post(
        '/api/method/upload_file',
        data: formData,
      );

      final fileUrl = response.data['message']['file_url'];
      return fileUrl;
    } catch (e, stack) {
      debugPrint('❌ Upload failed: $e\n$stack');
      return null;
    }
  }

  Future<bool> submit(Product? existingProduct) async {
    if (!formKey.currentState!.validate()) {
      debugPrint("❌ Form validation failed");
      return false;
    }

    if (!formKey.currentState!.validate()) return false;

    isSubmitting = true;
    notifyListeners();

    String? imagePath = existingProduct?.image;
    String? videoPath = existingProduct?.demoVideo;
    if (selectedImage != null) {
      imagePath = await uploadFile(selectedImage);
      if (imagePath == null) {
        isSubmitting = false;
        notifyListeners();
        return false;
      }
    }

    if (selectedVideo != null) {
      videoPath = await uploadFile(selectedVideo!);
    }

    final product = Product(
      name: existingProduct?.name ?? itemCodeController.text.trim(),
      itemName: nameController.text.trim(),
      itemPrice: double.tryParse(priceController.text.trim()) ?? 0.0,
      category: groupController.text.trim(),
      vendor: existingProduct?.vendor,
      image: imagePath,
      demoVideo: videoPath,
      websiteDescription: descController.text.trim(),
      shortWebsiteDescription: shortDescController.text.trim(),
      websiteSpecifications: existingProduct?.websiteSpecifications ?? [],
    );

    final success =
        existingProduct == null
            ? await provider.createProduct(product)
            : await provider.updateExistingItem(product);

    isSubmitting = false;
    notifyListeners();
    return success;
  }

  void disposeControllers() {
    nameController.dispose();
    groupController.dispose();
    itemCodeController.dispose();
    priceController.dispose();
    descController.dispose();
    shortDescController.dispose();
  }
}

class PermissionResult {
  final bool granted;
  final bool permanentlyDenied;
  PermissionResult({required this.granted, required this.permanentlyDenied});
}
