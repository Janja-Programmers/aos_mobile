import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '/core/utils/api_client.dart';
import '/core/utils/snackbar.dart';
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

  Future<Product?> fetchSingleProduct(String name) async {
    try {
      final product = await provider.getProductByName(name);
      return product;
    } catch (e) {
      return null;
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
    if (index >= 0 && index < specControllers.length) {
      specControllers[index].dispose();
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

      final payload = _buildPayloadFromProduct(productToSubmit);

      final success =
          await (existingProduct == null
              ? provider.createProductFromRaw(payload)
              : provider.updateExistingItem(productToSubmit));

      return success;
    } catch (e) {
      if (!context.mounted) return false;
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
      XFile? pickedFile;

      pickedFile =
          isImage
              ? await picker.pickImage(source: ImageSource.gallery)
              : await picker.pickVideo(source: ImageSource.gallery);

      if (pickedFile == null) {
        topSnackBar(context, 'No file selected', type: TopSnackType.info);
        return null;
      }

      final file = File(pickedFile.path);

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
      topSnackBar(context, 'Error: ${e.toString()}', type: TopSnackType.error);
      return null;
    } finally {
      // ✅ Reset both flags together
      isPickingImage = false;
      isPickingVideo = false;
      notifyListeners();
    }
  }

  Future<List<String>> fetchItemGroups() async {
    try {
      final res = await sl<APIClient>().client.get(
        'https://africaonlinestores.com/api/resource/Item Group',
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

      return response.data['message']['file_url'];
    } catch (e) {
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

  Map<String, dynamic> _buildPayloadFromProduct(Product p) {
    return {
      "name": p.name,
      "item_name": p.itemName,
      "item_price": p.itemPrice,
      "category": p.category,
      "vendor": p.vendor,
      "web_long_description": p.websiteDescription,
      "short_description": p.shortWebsiteDescription,
      "image": p.image,
      "demo_video": p.demoVideo,
      "website_specifications":
          p.websiteSpecifications
              ?.map(
                (e) => {
                  "doctype": "Product Website Specification",
                  "label": e.label,
                  "description": e.description,
                },
              )
              .toList(),
    };
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
