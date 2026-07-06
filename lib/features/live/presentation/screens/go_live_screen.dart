import 'dart:async';
import 'dart:io';

import 'package:africaonlinestores/core/media/data/media_upload_api_provider.dart';
import 'package:africaonlinestores/core/media/domain/media_upload_purpose.dart';
import 'package:africaonlinestores/core/media/helpers/media_helper.dart';
import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:africaonlinestores/features/live/application/providers/live_providers.dart';
import 'package:africaonlinestores/features/live/presentation/widgets/live_video_stage.dart';
import 'package:africaonlinestores/shared/widgets/app_snack.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:livekit_client/livekit_client.dart' as lk;
import 'package:permission_handler/permission_handler.dart';

class GoLiveScreen extends ConsumerStatefulWidget {
  const GoLiveScreen({super.key});

  @override
  ConsumerState<GoLiveScreen> createState() => _GoLiveScreenState();
}

class _GoLiveScreenState extends ConsumerState<GoLiveScreen> {
  final _titleController = TextEditingController();

  File? _selectedImage;
  String? _uploadedImageUrl;
  String? _uploadedCoverMediaId;
  lk.LocalVideoTrack? _previewTrack;

  bool _isUploading = false;
  bool _isStartingPreview = false;
  bool _isMicMuted = false;
  bool _isCountingDown = false;
  int? _countdown;

  bool _isFlippingCamera = false;
  bool _isFrontCamera = true;

  @override
  void initState() {
    super.initState();
    unawaited(_startCameraPreview());
  }

  Future<lk.LocalVideoTrack> _createPreviewTrack({required bool frontCamera}) {
    return lk.LocalVideoTrack.createCameraTrack(
      lk.CameraCaptureOptions(
        cameraPosition: frontCamera
            ? lk.CameraPosition.front
            : lk.CameraPosition.back,
      ),
    );
  }

  Future<void> _startCameraPreview() async {
    if (_isStartingPreview || _previewTrack != null) return;

    setState(() => _isStartingPreview = true);

    final statuses = await [Permission.camera, Permission.microphone].request();
    final cameraAllowed = statuses[Permission.camera]?.isGranted ?? false;
    final micAllowed = statuses[Permission.microphone]?.isGranted ?? false;

    if (!cameraAllowed || !micAllowed) {
      if (mounted) {
        ShowSnack(
          context,
          'Camera and microphone permissions are required.',
        ).error();

        setState(() => _isStartingPreview = false);
      }
      return;
    }

    try {
      final track = await _createPreviewTrack(frontCamera: _isFrontCamera);

      if (!mounted) {
        await track.stop();
        return;
      }

      setState(() {
        _previewTrack = track;
        _isStartingPreview = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() => _isStartingPreview = false);
      ShowSnack(context, 'Could not start camera preview.').error();
    }
  }

  Future<void> _flipPreviewCamera() async {
    final oldTrack = _previewTrack;

    if (oldTrack == null || _isFlippingCamera || _isStartingPreview) {
      return;
    }

    setState(() => _isFlippingCamera = true);

    final nextIsFrontCamera = !_isFrontCamera;

    try {
      setState(() => _previewTrack = null);

      await oldTrack.stop();

      // Some Android camera stacks, especially MIUI/Xiaomi, need a tiny
      // release window before opening the opposite camera.
      await Future<void>.delayed(const Duration(milliseconds: 180));

      final newTrack = await _createPreviewTrack(
        frontCamera: nextIsFrontCamera,
      );

      if (!mounted) {
        await newTrack.stop();
        return;
      }

      setState(() {
        _previewTrack = newTrack;
        _isFrontCamera = nextIsFrontCamera;
      });
    } catch (_) {
      if (!mounted) return;

      ShowSnack(context, 'Could not flip camera.').error();

      try {
        final fallbackTrack = await _createPreviewTrack(
          frontCamera: _isFrontCamera,
        );

        if (!mounted) {
          await fallbackTrack.stop();
          return;
        }

        setState(() => _previewTrack = fallbackTrack);
      } catch (_) {
        if (!mounted) return;
        setState(() => _previewTrack = null);
      }
    } finally {
      if (mounted) {
        setState(() => _isFlippingCamera = false);
      }
    }
  }

  Future<void> _pickAndUploadImage() async {
    final file = await MediaHelper.pickImageFromGallery();
    if (file == null) return;

    setState(() {
      _selectedImage = file;
      _isUploading = true;
    });

    final mediaApi = ref.read(mediaUploadApiProvider);

    final uploaded = await MediaHelper.uploadSingle(
      ref: ref,
      file: file,
      uploadFn: (pickedFile) => mediaApi.uploadMedia(
        file: pickedFile,
        purpose: MediaUploadPurpose.liveCover,
      ),
    );

    if (!mounted) return;

    setState(() {
      _isUploading = false;
      _uploadedImageUrl = uploaded?.url;
      _uploadedCoverMediaId = uploaded?.mediaId;
    });
  }

  Future<void> _startLive() async {
    final title = _titleController.text.trim();

    if (_uploadedCoverMediaId == null || title.isEmpty) {
      ShowSnack(context, 'Add cover image and title').error();
      return;
    }

    if (_isCountingDown || _isUploading || _isFlippingCamera) return;

    setState(() {
      _isCountingDown = true;
      _countdown = 3;
    });

    for (var i = 3; i >= 1; i--) {
      if (!mounted) return;
      setState(() => _countdown = i);
      await Future<void>.delayed(const Duration(seconds: 1));
    }

    if (!mounted) return;

    setState(() => _countdown = null);

    final hadPreviewCamera = _previewTrack != null;
    final micEnabled = !_isMicMuted;
    final frontCamera = _isFrontCamera;

    await _previewTrack?.stop();
    _previewTrack = null;

    await ref
        .read(liveManagerProvider.notifier)
        .startLive(
          title: title,
          coverImage: _uploadedImageUrl ?? '',
          coverMediaId: _uploadedCoverMediaId!,
          micEnabled: micEnabled,
          cameraEnabled: hadPreviewCamera,
          frontCamera: frontCamera,
        );

    if (mounted) {
      setState(() => _isCountingDown = false);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _previewTrack?.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Scaffold(
      backgroundColor: colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: LiveVideoStage(
              track: _previewTrack,
              emptyLabel: _isStartingPreview || _isFlippingCamera
                  ? 'Starting camera...'
                  : 'Camera preview unavailable',
              mirror: _isFrontCamera,
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    colors.black.withValues(alpha: .50),
                    Colors.transparent,
                    colors.black.withValues(alpha: .85),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton.filled(
                        style: IconButton.styleFrom(
                          backgroundColor: colors.black.withValues(alpha: .45),
                        ),
                        onPressed: () => Navigator.of(context).maybePop(),
                        icon: const Icon(Icons.close, color: Colors.white),
                      ),
                      const Spacer(),
                      _roundAction(
                        icon: Icons.cameraswitch_outlined,
                        label: _isFlippingCamera ? 'Flipping' : 'Flip',
                        onTap: _isFlippingCamera ? null : _flipPreviewCamera,
                      ),
                      const SizedBox(width: 10),
                      _roundAction(
                        icon: _isMicMuted
                            ? Icons.mic_off_outlined
                            : Icons.mic_none_outlined,
                        label: _isMicMuted ? 'Muted' : 'Mic',
                        onTap: _isFlippingCamera
                            ? null
                            : () => setState(() => _isMicMuted = !_isMicMuted),
                      ),
                    ],
                  ),
                  const Spacer(),
                  _buildSetupCard(context),
                ],
              ),
            ),
          ),
          if (_countdown != null)
            Positioned.fill(
              child: Container(
                color: colors.black.withValues(alpha: .42),
                alignment: Alignment.center,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  child: Text(
                    '$_countdown',
                    key: ValueKey(_countdown),
                    style: context.display.copyWith(
                      color: Colors.white,
                      fontSize: 92,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSetupCard(BuildContext context) {
    final colors = context.appColors;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.black.withValues(alpha: .48),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withValues(alpha: .16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: _isUploading ? null : _pickAndUploadImage,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Container(
                    width: 86,
                    height: 112,
                    color: Colors.white.withValues(alpha: .12),
                    child: _selectedImage == null
                        ? const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_photo_alternate_outlined,
                                color: Colors.white,
                              ),
                              SizedBox(height: 6),
                              Text(
                                'Cover',
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          )
                        : Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.file(_selectedImage!, fit: BoxFit.cover),
                              if (_isUploading)
                                const Center(
                                  child: CircularProgressIndicator(),
                                ),
                            ],
                          ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _titleController,
                  maxLength: 120,
                  minLines: 2,
                  maxLines: 3,
                  style: context.pStrong.copyWith(color: colors.white),
                  decoration: InputDecoration(
                    counterStyle: AppTextStylesX(
                      context,
                    ).caption.copyWith(color: colors.white),
                    hintText: 'Add a live title...',
                    hintStyle: context.p.copyWith(color: colors.white),
                    filled: true,
                    fillColor: colors.white.withValues(alpha: .10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
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
              onPressed:
                  _isUploading ||
                      _isCountingDown ||
                      _isFlippingCamera ||
                      _isStartingPreview
                  ? null
                  : _startLive,
              child: Text(
                _isCountingDown ? 'Starting...' : 'Go LIVE',
                style: AppTextStylesX(context).button,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Preview your camera, set your cover, then go live.',
            style: AppTextStylesX(
              context,
            ).caption.copyWith(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _roundAction({
    required IconData icon,
    required String label,
    required VoidCallback? onTap,
  }) {
    final enabled = onTap != null;

    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: enabled ? 1 : .55,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: .45),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.white.withValues(alpha: .16)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.white, size: 18),
              const SizedBox(width: 6),
              Text(label, style: const TextStyle(color: Colors.white)),
            ],
          ),
        ),
      ),
    );
  }
}
