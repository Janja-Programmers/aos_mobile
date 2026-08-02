import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:africaonlinestores/features/shorts/create_short/data/short_draft_repository.dart';
import 'package:africaonlinestores/features/shorts/create_short/data/short_video_exporter.dart';
import 'package:africaonlinestores/features/shorts/create_short/domain/short_creation_models.dart';
import 'package:africaonlinestores/features/shorts/create_short/domain/short_draft.dart';
import 'package:africaonlinestores/features/shorts/music/domain/short_sound.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:uuid/uuid.dart';
import 'package:video_player/video_player.dart';

class ShortEditorController extends StateNotifier<ShortEditorState> {
  ShortEditorController({
    required ShortEditorSeed seed,
    required ShortDraftRepository draftRepository,
    required ShortVideoExporter exporter,
  }) : _draftRepository = draftRepository,
       _exporter = exporter,
       super(ShortEditorState.initial(seed));

  final ShortDraftRepository _draftRepository;
  final ShortVideoExporter _exporter;
  final Uuid _uuid = const Uuid();
  VideoPlayerController? _player;
  bool _disposed = false;
  bool _isLoopSeekInProgress = false;

  VideoPlayerController? get player => _player;

  Future<void> initialize() async {
    if (state.isInitialized || _disposed) return;
    final source = File(state.sourcePath);
    if (!source.existsSync()) {
      _setError('The selected video is no longer available.');
      return;
    }

    try {
      final previous = _player;
      _player = null;
      if (previous != null) {
        previous.removeListener(_enforceTrimLoop);
        await previous.dispose();
      }

      final controller = VideoPlayerController.file(source);
      _player = controller;
      await controller.initialize();
      await controller.setLooping(false);
      if (_disposed) {
        await controller.dispose();
        return;
      }

      final duration = controller.value.duration;
      final size = controller.value.size;
      final proposedEnd = state.trimEnd;
      final end = proposedEnd <= Duration.zero || proposedEnd > duration
          ? duration
          : proposedEnd;
      final start = state.trimStart < end ? state.trimStart : Duration.zero;
      state = state.copyWith(
        duration: duration,
        videoSize: size.isEmpty ? const Size(1080, 1920) : size,
        trimStart: start,
        trimEnd: end,
        isInitialized: true,
        clearError: true,
      );
      controller.addListener(_enforceTrimLoop);
      await controller.seekTo(start);
      await controller.play();
    } catch (_) {
      final failedPlayer = _player;
      _player = null;
      if (failedPlayer != null) {
        failedPlayer.removeListener(_enforceTrimLoop);
        await failedPlayer.dispose();
      }
      _setError('Could not open this video for editing.');
    }
  }

  void _enforceTrimLoop() {
    final controller = _player;
    if (_disposed ||
        _isLoopSeekInProgress ||
        controller == null ||
        !controller.value.isInitialized ||
        !controller.value.isPlaying ||
        state.trimEnd <= state.trimStart) {
      return;
    }

    final position = controller.value.position;
    if (position >= state.trimEnd || position < state.trimStart) {
      _isLoopSeekInProgress = true;
      unawaited(
        controller.seekTo(state.trimStart).whenComplete(() {
          _isLoopSeekInProgress = false;
        }),
      );
    }
  }

  Future<void> togglePlayback() async {
    final controller = _player;
    if (controller == null || !controller.value.isInitialized) return;
    if (controller.value.isPlaying) {
      await controller.pause();
    } else {
      final position = controller.value.position;
      if (position < state.trimStart || position >= state.trimEnd) {
        await controller.seekTo(state.trimStart);
      }
      await controller.play();
    }
    if (!_disposed) state = state.copyWith();
  }

  Future<void> seek(Duration position) async {
    final controller = _player;
    if (controller == null || !controller.value.isInitialized) return;
    final bounded = position < state.trimStart
        ? state.trimStart
        : position > state.trimEnd
        ? state.trimEnd
        : position;
    await controller.seekTo(bounded);
  }

  Future<void> setTrim(Duration start, Duration end) async {
    if (!isValidTrim(start, end, state.duration)) return;
    state = state.copyWith(
      trimStart: start,
      trimEnd: end,
      hasUnsavedChanges: true,
      clearExportedPath: true,
      exportPhase: ShortExportPhase.idle,
    );
    await seek(start);
  }

  static bool isValidTrim(Duration start, Duration end, Duration duration) {
    return start >= Duration.zero &&
        end <= duration &&
        end > start &&
        end - start >= const Duration(milliseconds: 300);
  }

  void setSound(ShortSound sound) {
    if (sound == state.selectedSound) return;
    state = state.copyWith(
      selectedSound: sound,
      hasUnsavedChanges: true,
      clearExportedPath: true,
      exportPhase: ShortExportPhase.idle,
    );
  }

  void addText({required String text, required int colorValue}) {
    final clean = text.trim();
    if (clean.isEmpty) return;
    _addOverlay(
      ShortOverlay(
        id: _uuid.v4(),
        kind: ShortOverlayKind.text,
        content: clean,
        normalizedPosition: const Offset(.5, .32),
        colorValue: colorValue,
      ),
    );
  }

  void addSticker(String value) {
    if (value.trim().isEmpty) return;
    _addOverlay(
      ShortOverlay(
        id: _uuid.v4(),
        kind: ShortOverlayKind.sticker,
        content: value,
        normalizedPosition: const Offset(.5, .45),
      ),
    );
  }

  void setCaption(String text) {
    final clean = text.trim();
    final existing = state.overlays.where(
      (ShortOverlay item) => item.kind == ShortOverlayKind.caption,
    );
    final overlays = List<ShortOverlay>.of(state.overlays)
      ..removeWhere(
        (ShortOverlay item) => item.kind == ShortOverlayKind.caption,
      );
    if (clean.isNotEmpty) {
      final previous = existing.isEmpty ? null : existing.first;
      overlays.add(
        ShortOverlay(
          id: previous?.id ?? _uuid.v4(),
          kind: ShortOverlayKind.caption,
          content: clean,
          normalizedPosition:
              previous?.normalizedPosition ?? const Offset(.5, .84),
          colorValue: previous?.colorValue ?? 0xFFFFFFFF,
          scale: previous?.scale ?? 1,
        ),
      );
    }
    _replaceOverlays(overlays);
  }

  void updateOverlay(
    String id, {
    Offset? normalizedPosition,
    double? scale,
    String? content,
    int? colorValue,
  }) {
    final overlays = state.overlays
        .map((ShortOverlay item) {
          if (item.id != id) return item;
          final position = normalizedPosition == null
              ? item.normalizedPosition
              : Offset(
                  normalizedPosition.dx.clamp(.04, .96).toDouble(),
                  normalizedPosition.dy.clamp(.04, .96).toDouble(),
                );
          return item.copyWith(
            normalizedPosition: position,
            scale: scale?.clamp(.5, 3).toDouble(),
            content: content,
            colorValue: colorValue,
          );
        })
        .toList(growable: false);
    _replaceOverlays(overlays);
  }

  void deleteOverlay(String id) {
    _replaceOverlays(
      state.overlays
          .where((ShortOverlay item) => item.id != id)
          .toList(growable: false),
    );
  }

  Future<ShortDraft> saveDraft() async {
    final draft = await _draftRepository.save(state);
    if (!_disposed) {
      state = state.copyWith(
        sourcePath: draft.sourcePath,
        hasUnsavedChanges: false,
        isDraft: true,
      );
    }
    return draft;
  }

  Future<void> discard() async {
    await _draftRepository.delete(state.sessionId);
    if (state.deleteSourceOnDiscard) {
      final source = File(state.sourcePath);
      if (source.existsSync()) {
        await source.delete();
      }
    }
    final exported = state.exportedPath;
    if (exported != null && exported != state.sourcePath) {
      final file = File(exported);
      if (file.existsSync()) {
        await file.delete();
      }
    }
  }

  Future<String?> export() async {
    if (!state.isInitialized || state.isExporting) return null;
    if (!isValidTrim(state.trimStart, state.trimEnd, state.duration)) {
      _setError('Choose a valid video range before continuing.');
      return null;
    }

    state = state.copyWith(
      exportPhase: ShortExportPhase.exporting,
      exportProgress: 0,
      clearError: true,
    );
    try {
      final output = await _exporter.export(
        state,
        onProgress: (double progress) {
          if (_disposed) return;
          state = state.copyWith(
            exportPhase: ShortExportPhase.exporting,
            exportProgress: progress,
          );
        },
      );
      if (_disposed) return output;
      state = state.copyWith(
        exportPhase: ShortExportPhase.complete,
        exportProgress: 1,
        exportedPath: output,
        hasUnsavedChanges: false,
        clearError: true,
      );
      return output;
    } on ShortExportCancelled {
      if (!_disposed) {
        state = state.copyWith(
          exportPhase: ShortExportPhase.idle,
          exportProgress: 0,
          clearError: true,
        );
      }
      return null;
    } catch (_) {
      _setError('Could not prepare this video. Please try again.');
      state = state.copyWith(exportPhase: ShortExportPhase.error);
      return null;
    }
  }

  Future<void> cancelExport() => _exporter.cancel();

  void _addOverlay(ShortOverlay overlay) {
    _replaceOverlays(<ShortOverlay>[...state.overlays, overlay]);
  }

  void _replaceOverlays(List<ShortOverlay> overlays) {
    state = state.copyWith(
      overlays: overlays,
      hasUnsavedChanges: true,
      clearExportedPath: true,
      exportPhase: ShortExportPhase.idle,
    );
  }

  void _setError(String message) {
    if (_disposed) return;
    state = state.copyWith(
      errorMessage: message,
      exportPhase: ShortExportPhase.error,
    );
  }

  @override
  void dispose() {
    _disposed = true;
    _player?.removeListener(_enforceTrimLoop);
    unawaited(_player?.dispose());
    unawaited(_exporter.cancel());
    super.dispose();
  }
}
