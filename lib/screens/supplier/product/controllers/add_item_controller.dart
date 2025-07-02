import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:ownashop/core/utils/logger.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:file_picker/file_picker.dart';

import '/core/di/service_locator.dart';
import '/core/utils/api_client.dart';
import '/core/utils/snackbar.dart';
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
  String? uploadedImageUrl;
  String? uploadedVideoUrl;
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
      uploadedImageUrl = initialProduct.image;
      uploadedVideoUrl = initialProduct.demoVideo;
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
      final file = File(result.files.single.path!);
      if (isImage) {
        selectedImage = file;
        uploadedImageUrl = await uploadFile(file);
        if (uploadedImageUrl != null &&
            formKey.currentState != null &&
            !formKey.currentState!.validate()) {
          topSnackBar(
            context,
            'Image uploaded, please fill all required fields',
          );
        }
      } else {
        selectedVideo = file;
        uploadedVideoUrl = await uploadFile(file);
        if (uploadedVideoUrl != null &&
            formKey.currentState != null &&
            !formKey.currentState!.validate()) {
          topSnackBar(
            context,
            'Video uploaded, please fill all required fields',
          );
        }
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
    try {
      final response = await apiClient.client.get(
        'https://ownashop.com/api/resource/Item Group',
        queryParameters: {'fields': '["name"]', 'limit_page_length': 100},
      );
      final List data = response.data['data'];
      return data.map((e) => e['name'] as String).toList();
    } catch (e) {
      debugPrint('❌ Failed to fetch item groups: $e');
      return [];
    }
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

      debugPrint('Upload response: ${response.data}');
      final fileUrl = response.data['message']['file_url'];
      debugPrint('Uploaded file URL: $fileUrl');
      return fileUrl;
    } catch (e, stack) {
      debugPrint('❌ Upload failed: $e\n$stack');
      return null;
    }
  }

  Future<bool> submit(BuildContext context, Product? existingProduct) async {
    isSubmitting = true;
    notifyListeners();

    try {
      if (formKey.currentState == null || !formKey.currentState!.validate()) {
        debugPrint("❌ Form validation failed");
        topSnackBar(
          context,
          'Please fix form errors',
          type: TopSnackType.error,
        );
        return false;
      }

      final product = Product(
        name: existingProduct?.name ?? itemCodeController.text.trim(),
        itemName: nameController.text.trim(),
        itemPrice: double.tryParse(priceController.text.trim()) ?? 0.0,
        category: groupController.text.trim(),
        vendor: existingProduct?.vendor,
        image: uploadedImageUrl,
        demoVideo: uploadedVideoUrl,
        websiteDescription: descController.text.trim(),
        shortWebsiteDescription: shortDescController.text.trim(),
        websiteSpecifications: existingProduct?.websiteSpecifications ?? [],
      );

      appLogger.i('📦 Submitting product: ${product.name}');
      appLogger.i('📦 Submitting product: ${product.itemName}');
      appLogger.i('📦 Submitting product: ${product.itemPrice}');
      appLogger.i('Image URL: ${product.category}');
      appLogger.i('Image URL: ${product.vendor}');
      appLogger.i('Image URL: ${product.image}');
      appLogger.i('Video URL: ${product.demoVideo}');

      final success =
          existingProduct == null
              ? await provider.createProduct(product)
              : await provider.updateExistingItem(product);
      return success;
    } catch (e) {
      debugPrint('❌ Submit failed: $e');
      String errorMessage = 'Error saving product';
      if (e is DioException && e.response != null) {
        errorMessage =
            e.response!.data['exception']?.toString() ?? 'Error saving product';
        if (errorMessage.contains('PermissionError')) {
          errorMessage =
              'You do not have permission to update this product. Contact an admin.';
        }
      }
      topSnackBar(context, errorMessage, type: TopSnackType.error);
      return false;
    } finally {
      isSubmitting = false;
      notifyListeners();
    }
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
