import 'dart:async';
import 'dart:io';

import 'package:africaonlinestores/core/media/data/media_upload_api_provider.dart';
import 'package:africaonlinestores/core/media/domain/media_upload_purpose.dart';
import 'package:africaonlinestores/core/media/helpers/media_helper.dart';
import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:africaonlinestores/core/utils/logger.dart';
import 'package:africaonlinestores/features/live/application/providers/live_providers.dart';
import 'package:africaonlinestores/features/live/presentation/widgets/live_video_stage.dart';
import 'package:africaonlinestores/shared/widgets/app_snack.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:livekit_client/livekit_client.dart' as lk;

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
  bool _previewTransferred = false;

  @override
  void initState() {
    super.initState();
    unawaited(_startCameraPreview());
  }

  Future<void> _startCameraPreview() async {
    if (_isStartingPreview || _previewTrack != null) return;

    setState(() => _isStartingPreview = true);

    try {
      final track = await ref
          .read(liveMediaServiceProvider)
          .prepareCamera(frontCamera: _isFrontCamera);

      if (!mounted) {
        await ref.read(liveMediaServiceProvider).releasePreparedCamera();
        return;
      }

      setState(() {
        _previewTrack = track;
        _isStartingPreview = false;
      });
    } on Object catch (error, stackTrace) {
      appLogger.e(
        'Live camera preview failed',
        error: error,
        stackTrace: stackTrace,
      );
      if (!mounted) return;

      setState(() => _isStartingPreview = false);
      ShowSnack(context, 'Could not start camera preview.').error();
    }
  }

  Future<void> _flipPreviewCamera() async {
    if (_previewTrack == null || _isFlippingCamera || _isStartingPreview) {
      return;
    }

    setState(() => _isFlippingCamera = true);

    try {
      final switched = await ref.read(liveMediaServiceProvider).flipCamera();
      if (!mounted) return;
      if (!switched) {
        ShowSnack(context, 'No alternate camera is available.').error();
        return;
      }
      setState(() => _isFrontCamera = !_isFrontCamera);
    } on Object catch (error, stackTrace) {
      appLogger.e(
        'Live preview camera flip failed',
        error: error,
        stackTrace: stackTrace,
      );
      if (!mounted) return;
      ShowSnack(context, 'Could not flip camera.').error();
    } finally {
      if (mounted) {
        setState(() => _isFlippingCamera = false);
      }
    }
  }

  Future<void> _pickAndUploadImage() async {
    final file = await MediaHelper.pickImageFromGallery();
    if (file == null || !mounted) return;

    setState(() {
      _selectedImage = file;
      _uploadedImageUrl = null;
      _uploadedCoverMediaId = null;
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

    if (uploaded == null) {
      setState(() => _isUploading = false);
      ShowSnack(context, 'Could not upload the Live cover.').error();
      return;
    }

    setState(() {
      _isUploading = false;
      _uploadedImageUrl = uploaded.url;
      _uploadedCoverMediaId = uploaded.mediaId;
    });
  }

  Future<void> _startLive() async {
    final title = _titleController.text.trim();

    if (title.isEmpty) {
      ShowSnack(context, 'Add a live title.').error();
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
    _previewTransferred = true;

    final started = await ref
        .read(liveManagerProvider.notifier)
        .startLive(
          title: title,
          coverImage: _uploadedImageUrl,
          coverMediaId: _uploadedCoverMediaId,
          micEnabled: micEnabled,
          cameraEnabled: hadPreviewCamera,
          frontCamera: frontCamera,
        );

    if (mounted) {
      setState(() {
        _isCountingDown = false;
        _previewTransferred = started;
        if (!started) _previewTrack = null;
      });
      if (!started) unawaited(_startCameraPreview());
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    if (!_previewTransferred) {
      unawaited(ref.read(liveMediaServiceProvider).releasePreparedCamera());
    }
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
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight > 32
                          ? constraints.maxHeight - 32
                          : 0,
                    ),
                    child: IntrinsicHeight(
                      child: Column(
                        children: [
                          Row(
                            children: [
                              IconButton.filled(
                                tooltip: 'Close',
                                style: IconButton.styleFrom(
                                  backgroundColor: colors.black.withValues(
                                    alpha: .45,
                                  ),
                                ),
                                onPressed: _close,
                                icon: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                ),
                              ),
                              const Spacer(),
                              IconButton.filled(
                                tooltip: 'Flip camera',
                                onPressed: _isFlippingCamera
                                    ? null
                                    : _flipPreviewCamera,
                                icon: const Icon(Icons.cameraswitch_outlined),
                              ),
                              const SizedBox(width: 8),
                              IconButton.filled(
                                tooltip: _isMicMuted
                                    ? 'Unmute'
                                    : 'Mute microphone',
                                onPressed: _isFlippingCamera
                                    ? null
                                    : () => setState(
                                        () => _isMicMuted = !_isMicMuted,
                                      ),
                                icon: Icon(
                                  _isMicMuted
                                      ? Icons.mic_off_outlined
                                      : Icons.mic_none_outlined,
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          _buildSetupCard(context),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          if (_countdown != null)
            Positioned.fill(
              child: ColoredBox(
                color: colors.black.withValues(alpha: .42),
                child: Center(
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
                  child: SizedBox(
                    width: 86,
                    height: 112,
                    child: ColoredBox(
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
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.primary,
                minimumSize: const Size.fromHeight(52),
                padding: const EdgeInsets.symmetric(vertical: 14),
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
            'Preview your camera, add a title, and optionally choose a cover.',
            style: AppTextStylesX(
              context,
            ).caption.copyWith(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  void _close() {
    unawaited(_closeAsync());
  }

  Future<void> _closeAsync() async {
    await Navigator.of(context).maybePop();
  }
}
