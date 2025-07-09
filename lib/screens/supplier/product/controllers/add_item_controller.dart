import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '/core/utils/api_client.dart';
import '/core/utils/snackbar.dart';
import '/core/utils/logger.dart';
import '/core/di/service_locator.dart';

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

  final specLabelController = TextEditingController();
  final specDescController = TextEditingController();

  final List<WebsiteSpecification> websiteSpecifications = [];

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

      // Pre-fill specifications if editing
      websiteSpecifications.addAll(initialProduct.websiteSpecifications ?? []);
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
          topSnackBar(context, 'Image uploaded. Please fix form errors.');
        }
      } else {
        selectedVideo = file;
        uploadedVideoUrl = await uploadFile(file);
        if (uploadedVideoUrl != null &&
            formKey.currentState != null &&
            !formKey.currentState!.validate()) {
          topSnackBar(context, 'Video uploaded. Please fix form errors.');
        }
      }
      notifyListeners();
    }
  }

  Future<PermissionResult> _requestPermissions({required bool isImage}) async {
    if (!Platform.isAndroid) {
      // iOS: request photos
      final status = await Permission.photos.request();
      return PermissionResult(
        granted: status.isGranted,
        permanentlyDenied: status.isPermanentlyDenied,
      );
    }

    // For Android, handle API-specific permissions
    final androidInfo = await DeviceInfoPlugin().androidInfo;
    final sdkInt = androidInfo.version.sdkInt;

    Permission permission;

    if (sdkInt >= 33) {
      // Android 13+ uses granular permissions
      permission = isImage ? Permission.photos : Permission.videos;
    } else {
      // Android 12 and below use storage
      permission = Permission.storage;
    }

    final status = await permission.request();
    return PermissionResult(
      granted: status.isGranted,
      permanentlyDenied: status.isPermanentlyDenied,
    );
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

  Future<String?> uploadFile(File? file) async {
    if (file == null) return null;

    try {
      final fileName = file.path.split('/').last;
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(file.path, filename: fileName),
      });

      final response = await apiClient.client.post(
        '/api/method/upload_file',
        data: formData,
      );

      debugPrint('Upload response: ${response.data}');
      return response.data['message']['file_url'];
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
        websiteSpecifications: websiteSpecifications,
      );

      appLogger.i('📦 Submitting product: ${product.name}');
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
            e.response!.data['exception']?.toString() ?? errorMessage;
        if (errorMessage.contains('PermissionError')) {
          errorMessage = 'You do not have permission to update this product.';
        }
      }
      topSnackBar(context, errorMessage, type: TopSnackType.error);
      return false;
    } finally {
      isSubmitting = false;
      notifyListeners();
    }
  }

  void addSpecification() {
    final label = specLabelController.text.trim();
    final desc = specDescController.text.trim();

    if (label.isEmpty || desc.isEmpty) return;

    websiteSpecifications.add(
      WebsiteSpecification(label: label, description: desc),
    );

    specLabelController.clear();
    specDescController.clear();

    notifyListeners();
  }

  void removeSpecification(int index) {
    websiteSpecifications.removeAt(index);
    notifyListeners();
  }

  void disposeControllers() {
    nameController.dispose();
    groupController.dispose();
    itemCodeController.dispose();
    priceController.dispose();
    descController.dispose();
    shortDescController.dispose();
    specLabelController.dispose();
    specDescController.dispose();
  }
}

class PermissionResult {
  final bool granted;
  final bool permanentlyDenied;

  PermissionResult({required this.granted, required this.permanentlyDenied});
}
