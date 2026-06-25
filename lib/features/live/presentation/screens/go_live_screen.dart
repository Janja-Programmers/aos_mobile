import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:livekit_client/livekit_client.dart' as lk;
import 'package:permission_handler/permission_handler.dart';

import 'package:africaonlinestores/core/files/data/files_api_provider.dart';
import 'package:africaonlinestores/core/files/helpers/media_helper.dart';
import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';

import 'package:africaonlinestores/features/live/application/providers/live_providers.dart';
import 'package:africaonlinestores/features/live/presentation/widgets/live_video_stage.dart';

import 'package:africaonlinestores/shared/widgets/app_snack.dart';

class GoLiveScreen extends ConsumerStatefulWidget {
  const GoLiveScreen({super.key});

  @override
  ConsumerState<GoLiveScreen> createState() => _GoLiveScreenState();
}

class _GoLiveScreenState extends ConsumerState<GoLiveScreen> {
  final _titleController = TextEditingController();

  File? _selectedImage;
  String? _uploadedImageUrl;
  lk.LocalVideoTrack? _previewTrack;
  bool _isUploading = false;
  bool _isStartingPreview = false;
  bool _isMicMuted = false;
  bool _isCountingDown = false;
  int? _countdown;

  @override
  void initState() {
    super.initState();
    unawaited(_startCameraPreview());
  }

  Future<void> _startCameraPreview() async {
    if (_isStartingPreview || _previewTrack != null) return;
    setState(() => _isStartingPreview = true);

    final statuses = await [Permission.camera, Permission.microphone].request();
    final cameraAllowed = statuses[Permission.camera]?.isGranted == true;
    final micAllowed = statuses[Permission.microphone]?.isGranted == true;

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
      final track = await lk.LocalVideoTrack.createCameraTrack();
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
    final track = _previewTrack;
    if (track == null) return;

    try {
      final devices = await lk.Hardware.instance.enumerateDevices();
      final cameras = devices.where((d) => d.kind == 'videoinput').toList();
      if (cameras.length < 2) return;

      final currentDeviceId = track.currentOptions.deviceId;
      final currentIndex = cameras.indexWhere(
        (camera) => camera.deviceId == currentDeviceId,
      );
      final nextCamera = cameras[(currentIndex + 1) % cameras.length];
      await track.switchCamera(nextCamera.deviceId);
    } catch (_) {
      if (!mounted) return;
      ShowSnack(context, 'Could not flip camera.').error();
    }
  }

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

    if (!mounted) return;
    setState(() {
      _isUploading = false;
      _uploadedImageUrl = uploaded?.url;
    });
  }

  Future<void> _startLive() async {
    final title = _titleController.text.trim();

    if (_uploadedImageUrl == null || title.isEmpty) {
      ShowSnack(context, 'Add cover image and title').error();
      return;
    }

    if (_isCountingDown || _isUploading) return;

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

    await _previewTrack?.stop();
    _previewTrack = null;

    await ref
        .read(liveManagerProvider.notifier)
        .startLive(
          title: title,
          coverImage: _uploadedImageUrl!,
          micEnabled: !_isMicMuted,
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
              emptyLabel: _isStartingPreview
                  ? 'Starting camera...'
                  : 'Camera preview unavailable',
              mirror: true,
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    colors.black.withOpacity(.50),
                    Colors.transparent,
                    colors.black.withOpacity(.85),
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
                          backgroundColor: colors.black.withOpacity(.45),
                        ),
                        onPressed: () => Navigator.of(context).maybePop(),
                        icon: const Icon(Icons.close, color: Colors.white),
                      ),
                      const Spacer(),
                      _roundAction(
                        icon: Icons.cameraswitch_outlined,
                        label: 'Flip',
                        onTap: _flipPreviewCamera,
                      ),
                      const SizedBox(width: 10),
                      _roundAction(
                        icon: _isMicMuted
                            ? Icons.mic_off_outlined
                            : Icons.mic_none_outlined,
                        label: _isMicMuted ? 'Muted' : 'Mic',
                        onTap: () => setState(() => _isMicMuted = !_isMicMuted),
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
                color: colors.black.withOpacity(.42),
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
        color: colors.black.withOpacity(.48),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withOpacity(.16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: _pickAndUploadImage,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Container(
                    width: 86,
                    height: 112,
                    color: Colors.white.withOpacity(.12),
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
                    fillColor: colors.white.withOpacity(.10),
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
              onPressed: _isUploading || _isCountingDown ? null : _startLive,
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
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(.45),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.white.withOpacity(.16)),
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
    );
  }
}
