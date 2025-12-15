import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '/core/utils/api_client.dart';
import '/core/utils/snackbar.dart';

import '/features/product/product_provider.dart';
import '/features/product/data/product_model.dart';

class AddItemController extends ChangeNotifier {
  ProductModel? product;

  final ProductProvider provider;
  final APIClient apiClient;

  final formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final groupController = TextEditingController();
  final itemCodeController = TextEditingController();
  final priceController = TextEditingController();
  final descController = TextEditingController();
  final shortDescController = TextEditingController();

  bool maintainStock = false;

  final List<WebsiteSpecificationEntry> specControllers = [];

  List<WebsiteSpecification> getWebsiteSpecificationsFromControllers() {
    return specControllers
        .map(
          (entry) => WebsiteSpecification(
            label: entry.labelController.text.trim(),
            description: entry.descriptionController.text.trim(),
          ),
        )
        .where((s) => s.label.isNotEmpty || s.description.isNotEmpty)
        .toList();
  }

  File? selectedImage;
  File? selectedVideo;

  bool isPickingImage = false;
  bool isPickingVideo = false;

  String? uploadedImageUrl;
  String? uploadedVideoUrl;

  bool isSubmitting = false;
  bool isLoading = false;

  bool get isUploading => isPickingImage || isPickingVideo;

  void setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  void setMaintainStock(bool value) {
    maintainStock = value;
    notifyListeners();
  }

  AddItemController({
    required this.provider,
    required this.apiClient,
    ProductModel? initialProduct,
  }) {
    reset();

    if (initialProduct != null) {
      setInitialProduct(initialProduct);
    }
  }

  Future<ProductModel?> fetchSingleProduct(String name) async {
    return await provider.getProductByName(name);
  }

  void setInitialProduct(ProductModel newProduct) {
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

    maintainStock = product!.isStockItem == 1;

    notifyListeners();
  }

  void addSpecificationFromNewRow() {
    specControllers.add(WebsiteSpecificationEntry());
    notifyListeners();
  }

  void removeSpecification(int index) {
    if (index >= 0 && index < specControllers.length) {
      specControllers[index].dispose();
      specControllers.removeAt(index);
      notifyListeners();
    }
  }

  Future<bool> submit(
    BuildContext context,
    ProductModel? existingProduct,
  ) async {
    isSubmitting = true;
    notifyListeners();

    try {
      if (!formKey.currentState!.validate()) {
        topSnackBar(
          context,
          'Please fix form errors',
          type: TopSnackType.error,
        );
        return false;
      }

      final model = ProductModel(
        name: existingProduct?.name ?? itemCodeController.text.trim(),
        itemName: nameController.text.trim(),
        itemPrice: double.tryParse(priceController.text) ?? 0,
        category: groupController.text.trim(),
        isStockItem: maintainStock ? 1 : 0,
        vendor: existingProduct?.vendor,
        image: uploadedImageUrl,
        demoVideo: uploadedVideoUrl,
        websiteDescription: descController.text.trim(),
        shortWebsiteDescription: shortDescController.text.trim(),
        websiteSpecifications: getWebsiteSpecificationsFromControllers(),
      );

      final success =
          existingProduct == null
              ? await provider.createProduct(model)
              : await provider.updateExistingItem(model);

      return success;
    } catch (_) {
      topSnackBar(context, 'Error saving product', type: TopSnackType.error);
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
    try {
      isPickingImage = true;
      isPickingVideo = true;
      notifyListeners();

      final picker = ImagePicker();
      final picked =
          isImage
              ? await picker.pickImage(source: ImageSource.gallery)
              : await picker.pickVideo(source: ImageSource.gallery);

      if (picked == null) {
        topSnackBar(context, 'No file selected');
        return null;
      }

      final file = File(picked.path);
      final uploadedUrl = await uploadFile(file);

      if (isImage) {
        selectedImage = file;
        uploadedImageUrl = uploadedUrl;
      } else {
        selectedVideo = file;
        uploadedVideoUrl = uploadedUrl;
      }

      notifyListeners();
      return uploadedUrl;
    } catch (e) {
      topSnackBar(context, 'Upload failed');
      return null;
    } finally {
      // ✅ Reset both flags together
      isPickingImage = false;
      isPickingVideo = false;
      notifyListeners();
    }
  }

  Future<String?> uploadFile(File file) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          file.path,
          filename: file.path.split('/').last,
        ),
      });

      final res = await apiClient.client.post(
        '/api/method/upload_file',
        data: formData,
      );

      return res.data['message']['file_url'];
    } catch (_) {
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

    super.dispose();
  }

  void reset() {
    product = null;
    maintainStock = false;

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

  Future<List<String>> fetchItemGroups() async {
    try {
      final res = await apiClient.client.get(
        '/api/resource/Item Group',
        queryParameters: {
          'fields': '["name"]',
          'filters': '[["is_group","=",0]]',
          'limit_page_length': 50,
        },
      );

      return (res.data['data'] as List)
          .map((e) => e['name'] as String)
          .toList();
    } catch (_) {
      return [];
    }
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
