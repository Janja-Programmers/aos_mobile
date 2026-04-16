import 'dart:io';

import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:africaonlinestores/features/live/application/providers/live_providers.dart';
import 'package:africaonlinestores/shared/widgets/app_snack.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:africaonlinestores/core/files/data/files_api_provider.dart';
import 'package:africaonlinestores/core/files/helpers/media_helper.dart';
import 'package:africaonlinestores/core/theme/app_text_styles.dart';

class GoLiveScreen extends ConsumerStatefulWidget {
  const GoLiveScreen({super.key});

  @override
  ConsumerState<GoLiveScreen> createState() => _GoLiveScreenState();
}

class _GoLiveScreenState extends ConsumerState<GoLiveScreen> {
  File? _selectedImage;
  String? _uploadedImageUrl;

  final _titleController = TextEditingController();
  bool _isUploading = false;

  Future<void> _pickAndUploadImage() async {
    final file = await MediaHelper.pickImageFromGallery();
    if (file == null) return;

    setState(() {
      _selectedImage = file;
      _isUploading = true;
    });

    final filesApi = ref.read(filesApiProvider);

    final uploaded = await MediaHelper.uploadSingle(
      ref: ref,
      file: file,
      uploadFn: (file) => filesApi.uploadMedia(file: file),
    );

    setState(() {
      _isUploading = false;
      _uploadedImageUrl = uploaded?.url;
    });
  }

  void _startLive() {
    final title = _titleController.text.trim();

    if (_uploadedImageUrl == null || title.isEmpty) {
      ShowSnack(context, "Add cover image and title").error();
      return;
    }

    ref
        .read(liveManagerProvider.notifier)
        .startLive(title: title, coverImage: _uploadedImageUrl!);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        backgroundColor: colors.surface,
        elevation: 0,
        leading: const BackButton(),
        title: Text("Go Live", style: context.p),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /// COVER IMAGE
            GestureDetector(
              onTap: _pickAndUploadImage,
              child: Container(
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: colors.primary.withOpacity(.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: colors.border),
                ),
                child: _selectedImage == null
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.camera_alt,
                              size: 28,
                              color: colors.primary,
                            ),
                            const SizedBox(height: 8),
                            Text("Add Cover Photo", style: context.pStrong),
                          ],
                        ),
                      )
                    : Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(
                              _selectedImage!,
                              width: double.infinity,
                              height: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),

                          /// CHANGE BUTTON
                          Positioned(
                            right: 8,
                            top: 8,
                            child: GestureDetector(
                              onTap: _pickAndUploadImage,
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: colors.surface,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Icon(
                                  Icons.edit,
                                  size: 16,
                                  color: colors.textPrimary,
                                ),
                              ),
                            ),
                          ),

                          if (_isUploading)
                            const Center(child: CircularProgressIndicator()),
                        ],
                      ),
              ),
            ),

            const SizedBox(height: 16),

            /// TITLE INPUT
            TextField(
              controller: _titleController,
              style: context.p,
              decoration: InputDecoration(
                hintText: "Add stream title...",
                hintStyle: context.p,
                filled: true,
                fillColor: colors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              maxLength: 512,
            ),

            const Spacer(),

            /// GO LIVE BUTTON
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: _isUploading ? null : _startLive,
                child: Text(
                  "Go Live Now",
                  style: AppTextStylesX(context).button,
                ),
              ),
            ),

            const SizedBox(height: 8),

            /// FOOTER TEXT
            Text("Viewers will be notified when you go live", style: context.p),

            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
