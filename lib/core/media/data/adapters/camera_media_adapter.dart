// ignore_for_file: avoid_slow_async_io

import 'dart:async';
import 'dart:io';

import 'package:africaonlinestores/core/media/application/media_acquisition_ports.dart';
import 'package:africaonlinestores/core/media/application/media_camera_resource_coordinator.dart';
import 'package:africaonlinestores/core/media/application/media_file_staging_service.dart';
import 'package:africaonlinestores/core/media/domain/media_asset.dart';
import 'package:africaonlinestores/core/media/domain/media_policy.dart';
import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/core/utils/logger.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class InAppCameraMediaAdapter implements CameraMediaAdapter {
  const InAppCameraMediaAdapter({
    required MediaFileStagingService staging,
    required MediaCameraResourceCoordinator cameraResources,
  }) : _staging = staging,
       _cameraResources = cameraResources;

  final MediaFileStagingService _staging;
  final MediaCameraResourceCoordinator _cameraResources;

  @override
  Future<AcquiredMedia?> capture({
    required BuildContext context,
    required MediaUseCase useCase,
    required MediaCaptureMode mode,
    required MediaCameraFacing facing,
    Duration? maxDuration,
  }) async {
    final path = await Navigator.of(context, rootNavigator: true).push<String>(
      MaterialPageRoute<String>(
        fullscreenDialog: true,
        builder: (_) => _SharedCameraCaptureScreen(
          mode: mode,
          initialFacing: facing,
          maxDuration: maxDuration,
          cameraResources: _cameraResources,
        ),
      ),
    );
    if (path == null || path.trim().isEmpty) return null;

    final kind = mode == MediaCaptureMode.photo
        ? MediaKind.image
        : MediaKind.video;
    try {
      return await _staging.stageFile(
        sourceFile: File(path),
        kind: kind,
        source: mode == MediaCaptureMode.photo
            ? MediaAcquisitionSource.camera
            : MediaAcquisitionSource.recorder,
      );
    } finally {
      await _deleteCaptureCache(path);
    }
  }

  Future<void> _deleteCaptureCache(String path) async {
    try {
      final captureCache = File(path);
      if (await captureCache.exists()) await captureCache.delete();
    } on FileSystemException catch (error, stackTrace) {
      appLogger.w(
        'Shared camera cache cleanup failed',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }
}

class _SharedCameraCaptureScreen extends StatefulWidget {
  const _SharedCameraCaptureScreen({
    required this.mode,
    required this.initialFacing,
    required this.maxDuration,
    required this.cameraResources,
  });

  final MediaCaptureMode mode;
  final MediaCameraFacing initialFacing;
  final Duration? maxDuration;
  final MediaCameraResourceCoordinator cameraResources;

  @override
  State<_SharedCameraCaptureScreen> createState() =>
      _SharedCameraCaptureScreenState();
}

class _SharedCameraCaptureScreenState extends State<_SharedCameraCaptureScreen>
    with WidgetsBindingObserver {
  CameraController? _controller;
  MediaCameraLease? _lease;
  Future<void>? _videoStopFuture;
  List<CameraDescription> _cameras = const <CameraDescription>[];
  MediaCameraFacing? _facing;
  Timer? _limitTimer;
  String? _capturedPath;
  String? _errorMessage;
  bool _initializing = false;
  bool _recording = false;
  bool _flashEnabled = false;
  bool _disposed = false;
  bool _captureTransferred = false;
  int _generation = 0;

  @override
  void initState() {
    super.initState();
    _facing = widget.initialFacing;
    WidgetsBinding.instance.addObserver(this);
    unawaited(_initialize());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_disposed || _capturedPath != null) return;
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      unawaited(_releaseCamera(discardRecording: true));
      return;
    }
    if (state == AppLifecycleState.resumed) unawaited(_initialize());
  }

  Future<void> _initialize() async {
    if (_disposed || _initializing || _capturedPath != null) return;
    final generation = ++_generation;
    if (mounted) {
      setState(() {
        _initializing = true;
        _errorMessage = null;
      });
    }

    try {
      _lease ??= widget.cameraResources.acquire(MediaCameraOwner.sharedCapture);
      _cameras = await availableCameras();
      if (_disposed || generation != _generation) return;
      if (_cameras.isEmpty) {
        throw const MediaAcquisitionException('No camera is available.');
      }

      final selected = _cameraForFacing(_facing ?? widget.initialFacing);
      final previous = _controller;
      _controller = null;
      await previous?.dispose();

      final controller = CameraController(
        selected,
        ResolutionPreset.high,
        enableAudio: widget.mode == MediaCaptureMode.video,
      );
      await controller.initialize();
      if (_disposed || generation != _generation) {
        await controller.dispose();
        return;
      }

      _controller = controller;
      if (mounted) {
        setState(() {
          _initializing = false;
          _flashEnabled = false;
        });
      }
    } on Object catch (error, stackTrace) {
      appLogger.e(
        'Shared camera initialization failed',
        error: error,
        stackTrace: stackTrace,
      );
      await _releaseCamera(discardRecording: true);
      if (!_disposed && mounted && _generation == generation + 1) {
        setState(() {
          _initializing = false;
          _errorMessage = error is MediaCameraBusyException
              ? 'The camera is currently in use. Close the other camera and retry.'
              : 'The camera could not be started. Check camera permission and retry.';
        });
      }
    }
  }

  CameraDescription _cameraForFacing(MediaCameraFacing facing) {
    final direction = facing == MediaCameraFacing.front
        ? CameraLensDirection.front
        : CameraLensDirection.back;
    for (final camera in _cameras) {
      if (camera.lensDirection == direction) return camera;
    }
    return _cameras.first;
  }

  Future<void> _capturePhoto() async {
    final controller = _controller;
    if (controller == null ||
        !controller.value.isInitialized ||
        controller.value.isTakingPicture) {
      return;
    }

    try {
      final captured = await controller.takePicture();
      if (!mounted || _disposed) {
        await _deleteCapture(captured.path);
        return;
      }
      await _releaseCamera(discardRecording: false);
      if (!mounted || _disposed) return;
      setState(() => _capturedPath = captured.path);
    } on Object catch (error, stackTrace) {
      appLogger.e(
        'Shared camera photo capture failed',
        error: error,
        stackTrace: stackTrace,
      );
      if (mounted) {
        setState(() => _errorMessage = 'The photo could not be captured.');
      }
    }
  }

  Future<void> _toggleVideoRecording() async {
    if (_recording) {
      await _stopVideo(discard: false);
      return;
    }

    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;
    try {
      await controller.startVideoRecording();
      if (!mounted || _disposed) return;
      setState(() => _recording = true);
      final limit = widget.maxDuration;
      if (limit != null) {
        _limitTimer?.cancel();
        _limitTimer = Timer(limit, () => unawaited(_stopVideo(discard: false)));
      }
    } on Object catch (error, stackTrace) {
      appLogger.e(
        'Shared camera video start failed',
        error: error,
        stackTrace: stackTrace,
      );
      if (mounted) {
        setState(() => _errorMessage = 'Video recording could not be started.');
      }
    }
  }

  Future<void> _stopVideo({required bool discard}) async {
    final activeStop = _videoStopFuture;
    if (activeStop != null) {
      await activeStop;
      return;
    }

    final operation = _performVideoStop(discard: discard);
    _videoStopFuture = operation;
    try {
      await operation;
    } finally {
      if (identical(_videoStopFuture, operation)) _videoStopFuture = null;
    }
    if (!discard) {
      await _releaseCamera(discardRecording: false, waitForVideoStop: false);
    }
  }

  Future<void> _performVideoStop({required bool discard}) async {
    final controller = _controller;
    _limitTimer?.cancel();
    _limitTimer = null;
    if (controller == null || !controller.value.isRecordingVideo) {
      if (mounted) setState(() => _recording = false);
      return;
    }

    try {
      final captured = await controller.stopVideoRecording();
      if (discard) {
        await _deleteCapture(captured.path);
      } else if (mounted && !_disposed) {
        setState(() {
          _recording = false;
          _capturedPath = captured.path;
        });
      } else {
        await _deleteCapture(captured.path);
      }
    } on Object catch (error, stackTrace) {
      appLogger.e(
        'Shared camera video stop failed',
        error: error,
        stackTrace: stackTrace,
      );
      if (!discard && mounted) {
        setState(() => _errorMessage = 'The video could not be saved.');
      }
    } finally {
      if (mounted && !discard) setState(() => _recording = false);
    }
  }

  Future<void> _flipCamera() async {
    if (_recording || _initializing || _cameras.length < 2) return;
    _facing = _facing == MediaCameraFacing.front
        ? MediaCameraFacing.rear
        : MediaCameraFacing.front;
    await _initialize();
  }

  Future<void> _toggleFlash() async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized || _recording) {
      return;
    }
    final enabled = !_flashEnabled;
    try {
      await controller.setFlashMode(enabled ? FlashMode.torch : FlashMode.off);
      if (mounted) setState(() => _flashEnabled = enabled);
    } on CameraException {
      if (mounted) setState(() => _errorMessage = 'Flash is unavailable.');
    }
  }

  Future<void> _retake() async {
    final path = _capturedPath;
    _capturedPath = null;
    if (path != null) await _deleteCapture(path);
    if (mounted) setState(() {});
    await _initialize();
  }

  void _useCapture() {
    final path = _capturedPath;
    if (path == null) return;
    _captureTransferred = true;
    Navigator.of(context).pop(path);
  }

  Future<void> _deleteCapture(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) await file.delete();
    } on FileSystemException catch (error, stackTrace) {
      appLogger.w(
        'Shared camera capture cleanup failed',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> _releaseCamera({
    required bool discardRecording,
    bool waitForVideoStop = true,
  }) async {
    _generation += 1;
    _limitTimer?.cancel();
    _limitTimer = null;
    if (waitForVideoStop) {
      final activeStop = _videoStopFuture;
      if (activeStop != null) await activeStop;
    }
    final controller = _controller;
    _controller = null;
    if (discardRecording && (controller?.value.isRecordingVideo ?? false)) {
      try {
        final captured = await controller!.stopVideoRecording();
        await _deleteCapture(captured.path);
      } on Object catch (error, stackTrace) {
        appLogger.w(
          'Interrupted shared-camera recording cleanup failed',
          error: error,
          stackTrace: stackTrace,
        );
      }
    }
    try {
      await controller?.dispose();
    } finally {
      _recording = false;
      _flashEnabled = false;
      _initializing = false;
      _lease?.release();
      _lease = null;
    }
  }

  @override
  void dispose() {
    _disposed = true;
    WidgetsBinding.instance.removeObserver(this);
    final capturedPath = _capturedPath;
    if (!_captureTransferred && capturedPath != null) {
      unawaited(_deleteCapture(capturedPath));
    }
    unawaited(_releaseCamera(discardRecording: true));
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final capturedPath = _capturedPath;
    return PopScope<Object?>(
      canPop: !_recording,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              if (capturedPath != null)
                _CapturedMediaPreview(path: capturedPath, mode: widget.mode)
              else
                _cameraPreview(),
              Positioned(
                left: 8,
                right: 8,
                top: 4,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    IconButton(
                      tooltip: MaterialLocalizations.of(
                        context,
                      ).closeButtonTooltip,
                      color: Colors.white,
                      onPressed: _recording
                          ? null
                          : () {
                              unawaited(Navigator.of(context).maybePop());
                            },
                      icon: const Icon(Icons.close),
                    ),
                    if (capturedPath == null)
                      Row(
                        children: <Widget>[
                          IconButton(
                            tooltip: 'Flash',
                            color: Colors.white,
                            onPressed: _toggleFlash,
                            icon: Icon(
                              _flashEnabled
                                  ? Icons.flash_on_rounded
                                  : Icons.flash_off_rounded,
                            ),
                          ),
                          IconButton(
                            tooltip: 'Flip camera',
                            color: Colors.white,
                            onPressed: _flipCamera,
                            icon: const Icon(Icons.flip_camera_android_rounded),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              if (_errorMessage case final String message)
                Positioned(
                  left: 20,
                  right: 20,
                  top: 64,
                  child: Material(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(
                        message,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              Positioned(
                left: 24,
                right: 24,
                bottom: 24,
                child: capturedPath == null
                    ? _captureControls()
                    : _reviewControls(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _cameraPreview() {
    final controller = _controller;
    if (_initializing ||
        controller == null ||
        !controller.value.isInitialized) {
      return Center(
        child: _errorMessage == null
            ? const CircularProgressIndicator(color: Colors.white)
            : FilledButton(
                onPressed: _initialize,
                child: const Text('Retry camera'),
              ),
      );
    }

    return Center(
      child: ClipRect(
        child: SizedBox.expand(
          child: FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width: controller.value.previewSize?.height ?? 1,
              height: controller.value.previewSize?.width ?? 1,
              child: CameraPreview(controller),
            ),
          ),
        ),
      ),
    );
  }

  Widget _captureControls() {
    final isPhoto = widget.mode == MediaCaptureMode.photo;
    return Center(
      child: Semantics(
        button: true,
        label: isPhoto
            ? 'Take photo'
            : (_recording ? 'Stop recording' : 'Start recording'),
        child: InkResponse(
          radius: 44,
          onTap: _initializing
              ? null
              : isPhoto
              ? _capturePhoto
              : _toggleVideoRecording,
          child: Container(
            width: 78,
            height: 78,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _recording ? Colors.red : Colors.white,
              border: Border.all(color: Colors.white70, width: 5),
            ),
            child: _recording
                ? const Icon(Icons.stop_rounded, color: Colors.white, size: 38)
                : null,
          ),
        ),
      ),
    );
  }

  Widget _reviewControls() {
    return Row(
      children: <Widget>[
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _retake,
            style: OutlinedButton.styleFrom(foregroundColor: Colors.white),
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Retake'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: FilledButton.icon(
            onPressed: _useCapture,
            icon: const Icon(Icons.check_rounded, color: Colors.white),
            label: Text('Use', style: AppTextStylesX(context).button),
          ),
        ),
      ],
    );
  }
}

class _CapturedMediaPreview extends StatelessWidget {
  const _CapturedMediaPreview({required this.path, required this.mode});

  final String path;
  final MediaCaptureMode mode;

  @override
  Widget build(BuildContext context) {
    if (mode == MediaCaptureMode.photo) {
      return Image.file(File(path), fit: BoxFit.contain, cacheWidth: 1920);
    }
    return const ColoredBox(
      color: Colors.black,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(Icons.check_circle_rounded, color: Colors.white, size: 72),
            SizedBox(height: 12),
            Text('Video captured', style: TextStyle(color: Colors.white)),
          ],
        ),
      ),
    );
  }
}
