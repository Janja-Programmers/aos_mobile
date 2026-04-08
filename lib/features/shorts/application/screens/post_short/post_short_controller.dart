import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class PostShortController {
  String? selectedAdId;
  File? videoFile;
  final captionController = TextEditingController();
  final ImagePicker picker = ImagePicker();
  List<String> hashtags = [];

  Future<void> pickVideo(VoidCallback onUpdate) async {
    final file = await picker.pickVideo(source: ImageSource.gallery);
    if (file == null) return;

    videoFile = File(file.path);
    onUpdate();
  }

  void setAd(String adId, VoidCallback onUpdate) {
    selectedAdId = adId;
    onUpdate();
  }

  void dispose() {
    captionController.dispose();
  }
}
