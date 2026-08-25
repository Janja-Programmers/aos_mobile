// ignore_for_file: avoid_slow_async_io

import 'dart:io';

import 'package:africaonlinestores/core/media/application/media_camera_resource_coordinator.dart';
import 'package:africaonlinestores/core/media/application/media_file_staging_service.dart';
import 'package:africaonlinestores/core/media/domain/media_asset.dart';
import 'package:africaonlinestores/core/utils/logger.dart';
import 'package:africaonlinestores/features/shorts/create_short/application/controllers/short_recorder_controller.dart';
import 'package:camera/camera.dart';
import 'package:flutter/widgets.dart';

class PluginShortCameraDriver implements ShortCameraDriver {
  PluginShortCameraDriver({
    required MediaCameraResourceCoordinator cameraResources,
    required MediaFileStagingService staging,
  }) : _cameraResources = cameraResources,
       _staging = staging;

  final MediaCameraResourceCoordinator _cameraResources;
  final MediaFileStagingService _staging;
  List<CameraDescription> _cameras = const <CameraDescription>[];
  CameraController? _controller;
  MediaCameraLease? _lease;

  @override
  Widget? get previewWidget {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return null;
    return CameraPreview(controller);
  }

  @override
  Size? get previewSize => _controller?.value.previewSize;

  @override
  bool get isRecording => _controller?.value.isRecordingVideo ?? false;

  @override
  int get cameraCount => _cameras.length;

  @override
  Future<void> initialize(int cameraIndex) async {
    _lease ??= _cameraResources.acquire(MediaCameraOwner.shorts);
    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        throw const ShortCameraDriverException(
          message: 'No camera is available.',
        );
      }
      final boundedIndex = cameraIndex.clamp(0, _cameras.length - 1).toInt();
      final previous = _controller;
      _controller = null;
      await previous?.dispose();

      final controller = CameraController(
        _cameras[boundedIndex],
        ResolutionPreset.high,
      );
      _controller = controller;
      await controller.initialize();
    } on CameraException catch (error) {
      await dispose();
      final code = error.code.toLowerCase();
      throw ShortCameraDriverException(
        message: error.description ?? 'Could not initialize the camera.',
        permissionDenied:
            code.contains('accessdenied') || code.contains('permission'),
      );
    } on ShortCameraDriverException {
      await dispose();
      rethrow;
    } on Object {
      await dispose();
      rethrow;
    }
  }

  @override
  Future<String> startRecording() async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) {
      throw const ShortCameraDriverException(message: 'Camera is not ready.');
    }
    if (controller.value.isRecordingVideo) {
      throw const ShortCameraDriverException(
        message: 'A recording is already active.',
      );
    }
    await controller.startVideoRecording();
    return '';
  }

  @override
  Future<String> stopRecording() async {
    final controller = _controller;
    if (controller == null || !controller.value.isRecordingVideo) {
      throw const ShortCameraDriverException(
        message: 'No recording is active.',
      );
    }
    final captured = await controller.stopVideoRecording();
    try {
      final staged = await _staging.stageFile(
        sourceFile: File(captured.path),
        kind: MediaKind.video,
        source: MediaAcquisitionSource.recorder,
        originalName: captured.name,
      );
      return staged.path;
    } finally {
      try {
        final source = File(captured.path);
        if (await source.exists()) await source.delete();
      } on FileSystemException catch (error, stackTrace) {
        appLogger.w(
          'Short camera cache cleanup failed',
          error: error,
          stackTrace: stackTrace,
        );
      }
    }
  }

  @override
  Future<void> setFlash(bool enabled) async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;
    await controller.setFlashMode(enabled ? FlashMode.torch : FlashMode.off);
  }

  @override
  Future<void> dispose() async {
    final controller = _controller;
    _controller = null;
    try {
      await controller?.dispose();
    } finally {
      _lease?.release();
      _lease = null;
    }
  }
}
