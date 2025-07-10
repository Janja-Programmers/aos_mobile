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
  Product? product;

  final ProductProvider provider;
  final APIClient apiClient;

  final formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final groupController = TextEditingController();
  final itemCodeController = TextEditingController();
  final priceController = TextEditingController();
  final descController = TextEditingController();
  final shortDescController = TextEditingController();

  final List<WebsiteSpecificationEntry> specControllers = [];

  List<WebsiteSpecification> getWebsiteSpecificationsFromControllers() {
    return specControllers
        .map(
          (entry) => WebsiteSpecification(
            label: entry.labelController.text.trim(),
            description: entry.descriptionController.text.trim(),
          ),
        )
        .where((spec) => spec.label.isNotEmpty || spec.description.isNotEmpty)
        .toList();
  }

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
      setInitialProduct(initialProduct);
    } else {
      // If creating new, start with one spec row
      specControllers.add(WebsiteSpecificationEntry());
    }
  }

  void setInitialProduct(Product newProduct) {
    if (product != null) return;

    product = newProduct;

    nameController.text = product!.itemName;
    groupController.text = product!.category;
    itemCodeController.text = product!.name;
    priceController.text = product!.itemPrice.toString();
    descController.text = product!.websiteDescription ?? '';
    shortDescController.text = product!.shortWebsiteDescription ?? '';
    uploadedImageUrl = product!.image;
    uploadedVideoUrl = product!.demoVideo;

    specControllers.clear();
    for (final spec in product!.websiteSpecifications ?? []) {
      specControllers.add(
        WebsiteSpecificationEntry(
          label: spec.label,
          description: spec.description,
        ),
      );
    }

    notifyListeners();
  }

  void addSpecificationFromNewRow() {
    specControllers.add(WebsiteSpecificationEntry());
    notifyListeners();
  }

  void removeSpecification(int index) {
    if (specControllers.length <= 1) return;
    if (index >= 0 && index < specControllers.length) {
      specControllers.removeAt(index);
      notifyListeners();
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

      final specs = getWebsiteSpecificationsFromControllers();

      final productToSubmit = Product(
        name: existingProduct?.name ?? itemCodeController.text.trim(),
        itemName: nameController.text.trim(),
        itemPrice: double.tryParse(priceController.text.trim()) ?? 0.0,
        category: groupController.text.trim(),
        vendor: existingProduct?.vendor,
        image: uploadedImageUrl,
        demoVideo: uploadedVideoUrl,
        websiteDescription: descController.text.trim(),
        shortWebsiteDescription: shortDescController.text.trim(),
        websiteSpecifications: specs,
      );

      appLogger.i('📦 Submitting product: ${productToSubmit.name}');

      if (existingProduct != null &&
          existingProduct.name != productToSubmit.name) {
        topSnackBar(
          context,
          'Item code mismatch during update.',
          type: TopSnackType.error,
        );
        return false;
      }

      final success =
          await (existingProduct == null
              ? submitRaw(context)
              : provider.updateExistingItem(productToSubmit));

      return success;
    } catch (e, stack) {
      debugPrint('Group fetch error: $e\n$stack');

      debugPrint('❌ Submit failed: $e');
      String errorMessage = 'Error saving product';
      if (e is DioException && e.response != null) {
        errorMessage = errorMessage;
        if (errorMessage.contains('PermissionError')) {
          errorMessage = 'You do not have permission to update this product.';
        }
      }
      if (!context.mounted) return false;
      topSnackBar(context, errorMessage, type: TopSnackType.error);

      debugPrint('❌ Submit error: $errorMessage');
      return false;
    } finally {
      isSubmitting = false;
      notifyListeners();
    }
  }

  Future<bool> submitRaw(BuildContext context) async {
    if (formKey.currentState == null || !formKey.currentState!.validate()) {
      topSnackBar(
        context,
        'Please fix the form errors',
        type: TopSnackType.error,
      );
      return false;
    }

    isSubmitting = true;
    notifyListeners();

    try {
      final payload = {
        "item_name": nameController.text.trim(),
        "item_price": double.tryParse(priceController.text.trim()) ?? 0.0,
        "category": groupController.text.trim(),
        "website_description": descController.text.trim(),
        "short_website_description": shortDescController.text.trim(),
        "image": uploadedImageUrl,
        "demo_video": uploadedVideoUrl,
        "website_specifications":
            getWebsiteSpecificationsFromControllers()
                .map(
                  (e) => {
                    "doctype": "Product Website Specification",
                    "label": e.label,
                    "description": e.description,
                  },
                )
                .toList(),
      };

      debugPrint('📤 Submitting payload: $payload');

      final success = await provider.createProductFromRaw(payload);

      if (success) {
        if (context.mounted) {
          topSnackBar(context, 'Product created successfully');
          Navigator.pop(context);
        }
        return true;
      } else {
        if (!context.mounted) return false;
        topSnackBar(
          context,
          'Failed to create product',
          type: TopSnackType.error,
        );
        return false;
      }
    } catch (e) {
      debugPrint('❌ SubmitRaw failed: $e');
      topSnackBar(
        context,
        'Failed to create product',
        type: TopSnackType.error,
      );
      return false;
    } finally {
      isSubmitting = false;
      notifyListeners();
    }
  }

  Future<String?> pickFile(
    BuildContext context, {
    required bool isImage,
  }) async {
    final permissionResult = await _requestPermissions(isImage: isImage);
    if (!permissionResult.granted) {
      if (permissionResult.permanentlyDenied) {
        await openAppSettings();
      }
      return null;
    }

    final result = await FilePicker.platform.pickFiles(
      type: isImage ? FileType.image : FileType.video,
      allowMultiple: false,
    );

    if (result != null && result.files.single.path != null) {
      final path = result.files.single.path!;
      debugPrint("✅ Picked ${isImage ? "image" : "video"}: $path");

      final file = File(path);
      if (isImage) {
        selectedImage = file;
        uploadedImageUrl = await uploadFile(file);
        notifyListeners();
        return uploadedImageUrl;
      } else {
        selectedVideo = file;
        uploadedVideoUrl = await uploadFile(file);
        notifyListeners();
        return uploadedVideoUrl;
      }
    } else {
      debugPrint("❌ No file picked or path is null.");
    }

    return null;
  }

  Future<PermissionResult> _requestPermissions({required bool isImage}) async {
    if (!Platform.isAndroid) {
      final status = await Permission.photos.request();
      return PermissionResult(
        granted: status.isGranted,
        permanentlyDenied: status.isPermanentlyDenied,
      );
    }

    final androidInfo = await DeviceInfoPlugin().androidInfo;
    final sdkInt = androidInfo.version.sdkInt;

    if (sdkInt >= 33) {
      // Use both for safety
      final storageStatus = await Permission.storage.request();
      return PermissionResult(
        granted: storageStatus.isGranted,
        permanentlyDenied: storageStatus.isPermanentlyDenied,
      );
    } else {
      final storageStatus = await Permission.storage.request();
      return PermissionResult(
        granted: storageStatus.isGranted,
        permanentlyDenied: storageStatus.isPermanentlyDenied,
      );
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

  @override
  void dispose() {
    super.dispose();
    nameController.dispose();
    groupController.dispose();
    itemCodeController.dispose();
    priceController.dispose();
    descController.dispose();
    shortDescController.dispose();
    for (final entry in specControllers) {
      entry.dispose();
    }
  }

  void reset() {
    product = null;
    nameController.clear();
    groupController.clear();
    itemCodeController.clear();
    priceController.clear();
    descController.clear();
    shortDescController.clear();
    uploadedImageUrl = null;
    uploadedVideoUrl = null;
    selectedImage = null;
    selectedVideo = null;

    for (final entry in specControllers) {
      entry.dispose();
    }
    specControllers.clear();
    specControllers.add(WebsiteSpecificationEntry());

    notifyListeners();
  }
}

class WebsiteSpecificationEntry {
  final TextEditingController labelController;
  final TextEditingController descriptionController;

  WebsiteSpecificationEntry({String? label, String? description})
    : labelController = TextEditingController(text: label ?? ''),
      descriptionController = TextEditingController(text: description ?? '');

  void dispose() {
    labelController.dispose();
    descriptionController.dispose();
  }
}

class PermissionResult {
  final bool granted;
  final bool permanentlyDenied;

  PermissionResult({required this.granted, required this.permanentlyDenied});
}
