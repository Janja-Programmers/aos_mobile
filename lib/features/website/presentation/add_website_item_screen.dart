import 'dart:io';

import 'package:ownashop/core/utils/permissions.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../auth/presentation/auth_provider.dart';
import '../domain/website_item.dart';
import 'web_item_provider.dart';
import 'widgets/custom_button.dart';
import 'widgets/custom_text_controller.dart';

class AddWebsiteItemScreen extends StatefulWidget {
  const AddWebsiteItemScreen({super.key});

  @override
  State<AddWebsiteItemScreen> createState() => _AddWebsiteItemScreenState();
}

class _AddWebsiteItemScreenState extends State<AddWebsiteItemScreen> {
  final _websiteDisplayNameController = TextEditingController();
  final _itemCodeController = TextEditingController();
  final _shortDescController = TextEditingController();
  final _fullDescController = TextEditingController();

  bool _isPublished = false;
  bool _isLoading = false;

  String? _selectedVideo;
  List<String> _selectedImages = [];

  @override
  void dispose() {
    _websiteDisplayNameController.dispose();
    _itemCodeController.dispose();
    _shortDescController.dispose();
    _fullDescController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.image,
      );

      if (result == null || result.files.isEmpty) return; // Graceful skip

      final pickedFiles = result.files.take(5).toList(); // Limit to 5
      final imagePaths =
          pickedFiles
              .map((file) => file.path)
              .whereType<String>() // remove nulls
              .toList();

      setState(() {
        _selectedImages = imagePaths;
      });
    } catch (e) {
      debugPrint('Image picking failed: $e');
      // optionally show a snackbar
    }
  }

  Future<void> _pickVideo() async {
    final hasPermission = await checkStoragePermission();
    if (!hasPermission) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Storage permission is required')));
      return;
    }

    final result = await FilePicker.platform.pickFiles(
      type: FileType.video,
      allowMultiple: false,
    );

    if (result != null && result.files.isNotEmpty) {
      final path = result.files.single.path;
      if (path != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            setState(() {
              _selectedVideo = path;
            });
          }
        });
      }
    }
  }

  void _submit() async {
    FocusScope.of(context).unfocus();

    final authProvider = context.read<AuthProvider>();
    final user = authProvider.user;

    if (user == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('User not logged in')));
      return;
    }

    final websiteItemProvider = context.read<WebsiteItemProvider>();

    final websiteDisplayName = _websiteDisplayNameController.text.trim();
    final itemCode = _itemCodeController.text.trim();
    final shortDesc = _shortDescController.text.trim();
    final fullDesc = _fullDescController.text.trim();

    if (websiteDisplayName.isEmpty || itemCode.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final newItem = WebsiteItem(
        id: null,
        websiteDisplayName: websiteDisplayName,
        itemCode: itemCode,
        isPublished: _isPublished,
        images: _selectedImages,
        video: _selectedVideo,
        shortDescription: shortDesc.isEmpty ? null : shortDesc,
        fullDescription: fullDesc.isEmpty ? null : fullDesc,
        createdBy: user.id!,
        createdAt: DateTime.now(),
      );

      await websiteItemProvider.addWebsiteItem(newItem);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Website item added successfully!')),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to add website item')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildSelectedImagesPreview() {
    if (_selectedImages.isEmpty) {
      return Text('No images selected');
    } else {
      return Wrap(
        spacing: 8,
        runSpacing: 8,
        children:
            _selectedImages.map((path) {
              return Builder(
                builder: (_) {
                  final file = File(path);
                  return FutureBuilder<bool>(
                    future: file.exists(),
                    builder: (_, snapshot) {
                      if (snapshot.connectionState != ConnectionState.done ||
                          snapshot.data != true) {
                        return const SizedBox();
                      }
                      return Image.file(
                        file,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                      );
                    },
                  );
                },
              );
            }).toList(),
      );
    }
  }

  Widget _buildSelectedVideoPreview() {
    if (_selectedVideo == null) return Text('No video selected');
    final filename = _selectedVideo!.split('/').last;
    return Chip(label: Text(filename));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Website Item')),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ListView(
            children: [
              CustomTextField(
                controller: _websiteDisplayNameController,
                label: 'Website Display Name',
                textInputAction: TextInputAction.next,
              ),

              SizedBox(height: 12),

              CustomTextField(
                controller: _itemCodeController,
                label: 'Item Code',
                textInputAction: TextInputAction.next,
              ),

              SizedBox(height: 12),

              Text('Images'),

              SizedBox(height: 4),

              _buildSelectedImagesPreview(),
              ElevatedButton.icon(
                onPressed: _pickImages,
                icon: Icon(Icons.photo_library),
                label: Text('Pick Images'),
              ),

              SizedBox(height: 12),

              Text('Video'),

              SizedBox(height: 4),

              _buildSelectedVideoPreview(),
              ElevatedButton.icon(
                onPressed: _pickVideo,
                icon: Icon(Icons.videocam),
                label: Text('Pick Video'),
              ),

              SizedBox(height: 12),

              CustomTextField(
                controller: _shortDescController,
                label: 'Short Description',
                maxLines: 2,
                textInputAction: TextInputAction.next,
              ),

              SizedBox(height: 12),

              CustomTextField(
                controller: _fullDescController,
                label: 'Full Description',
                maxLines: 4,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _submit(),
              ),

              SizedBox(height: 12),

              Row(
                children: [
                  Checkbox(
                    value: _isPublished,
                    onChanged:
                        (val) => setState(() => _isPublished = val ?? false),
                  ),
                  Text('Publish'),
                ],
              ),

              SizedBox(height: 24),

              CustomButton(
                label: 'Add Website Item',
                onPressed: _submit,
                isLoading: _isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
