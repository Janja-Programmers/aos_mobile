import 'package:flutter/material.dart';

import 'package:africaonlinestores/features/shorts/application/upload/upload_state.dart';

class UploadProgressOverlay extends StatelessWidget {
  final UploadState upload;

  const UploadProgressOverlay({super.key, required this.upload});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.8),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (upload.stage == UploadStage.uploading)
              Column(
                children: [
                  const Text(
                    "Uploading...",
                    style: TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  CircularProgressIndicator(value: upload.progress),
                ],
              ),

            if (upload.stage == UploadStage.processing)
              const Text(
                "Processing...",
                style: TextStyle(color: Colors.white),
              ),

            if (upload.stage == UploadStage.ready)
              const Icon(Icons.check_circle, color: Colors.green, size: 60),

            if (upload.stage == UploadStage.failed)
              const Icon(Icons.error, color: Colors.red, size: 60),
          ],
        ),
      ),
    );
  }
}
