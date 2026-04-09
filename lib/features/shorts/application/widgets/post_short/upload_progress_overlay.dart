import 'package:flutter/material.dart';

import 'package:africaonlinestores/features/shorts/application/state/upload_state.dart';

class UploadProgressOverlay extends StatelessWidget {
  final UploadState upload;
  final VoidCallback? onRetry;

  const UploadProgressOverlay({super.key, required this.upload, this.onRetry});

  @override
  Widget build(BuildContext context) {
    final status = upload.status;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 250),
      opacity: _shouldShow(status) ? 1 : 0,
      child: IgnorePointer(
        ignoring: !_shouldShow(status),
        child: Container(
          color: Colors.black.withOpacity(0.8),
          child: Center(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _buildContent(upload),
            ),
          ),
        ),
      ),
    );
  }

  // ───────────── CONTENT SWITCH ─────────────

  Widget _buildContent(UploadState upload) {
    switch (upload.status) {
      case UploadStatus.initializing:
        return _message("Preparing upload...");

      case UploadStatus.uploading:
        return _progress(upload);

      case UploadStatus.confirming:
        return _message("Finalizing upload...");

      case UploadStatus.processing:
        return _message("Processing video...");

      case UploadStatus.ready:
        return _success();

      case UploadStatus.failed:
        return _error();

      default:
        return const SizedBox.shrink();
    }
  }

  // ───────────── STATES ─────────────
  Widget _progress(UploadState upload) {
    return Column(
      key: const ValueKey("uploading"),
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          "Uploading...",
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
        const SizedBox(height: 12),

        CircularProgressIndicator(
          value: upload.progress > 0 ? upload.progress : null,
        ),

        const SizedBox(height: 8),

        if (upload.progress > 0)
          Text(
            "${(upload.progress * 100).toStringAsFixed(0)}%",
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
      ],
    );
  }

  Widget _message(String text) {
    return Column(
      key: ValueKey(text),
      mainAxisSize: MainAxisSize.min,
      children: [
        const CircularProgressIndicator(),
        const SizedBox(height: 12),
        Text(text, style: const TextStyle(color: Colors.white, fontSize: 14)),
      ],
    );
  }

  Widget _success() {
    return const Column(
      key: ValueKey("success"),
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.check_circle, color: Colors.green, size: 64),
        SizedBox(height: 12),
        Text(
          "Upload complete",
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
      ],
    );
  }

  Widget _error() {
    return Column(
      key: const ValueKey("error"),
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.error, color: Colors.red, size: 64),

        const SizedBox(height: 12),

        const Text(
          "Upload failed. Please try again.",
          style: TextStyle(color: Colors.white, fontSize: 14),
        ),

        const SizedBox(height: 16),

        ElevatedButton(onPressed: onRetry, child: const Text("Retry")),
      ],
    );
  }
  // ───────────── VISIBILITY ─────────────

  bool _shouldShow(UploadStatus status) {
    return status != UploadStatus.idle && status != UploadStatus.picked;
  }
}
