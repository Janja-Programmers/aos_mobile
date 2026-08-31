// ignore_for_file: avoid_slow_async_io

import 'dart:convert';
import 'dart:io';

import 'package:africaonlinestores/core/media/application/media_acquisition_ports.dart';
import 'package:africaonlinestores/core/media/application/media_file_staging_service.dart';
import 'package:africaonlinestores/core/media/application/media_picker_operation_coordinator.dart';
import 'package:africaonlinestores/core/media/data/adapters/image_picker_gateway.dart';
import 'package:africaonlinestores/core/media/domain/media_asset.dart';
import 'package:africaonlinestores/core/media/domain/media_policy.dart';
import 'package:africaonlinestores/core/utils/json_utils.dart';
import 'package:africaonlinestores/core/utils/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ImagePickerMediaAdapter implements GalleryMediaAdapter {
  ImagePickerMediaAdapter({
    required MediaFileStagingService staging,
    required ImagePickerGateway gateway,
    required MediaPickerOperationCoordinator pickerOperations,
  }) : _staging = staging,
       _gateway = gateway,
       _pickerOperations = pickerOperations;

  static const String _pendingRequestKey = 'media.image_picker.pending.v2';
  static const String _recoveredBatchesKey = 'media.image_picker.recovered.v2';
  static const Duration _maxRecoveryAge = Duration(days: 1);
  static const int _maxRecoveredBatches = 4;

  final MediaFileStagingService _staging;
  final ImagePickerGateway _gateway;
  final MediaPickerOperationCoordinator _pickerOperations;

  Future<void>? _initialization;
  List<_RecoveredPickerBatch> _recoveredBatches =
      const <_RecoveredPickerBatch>[];
  _PickerRecoveryFailure? _recoveryFailure;

  @override
  Future<void> initialize() {
    final existing = _initialization;
    if (existing != null) return existing;

    final operation = _initialize();
    _initialization = operation;
    return operation;
  }

  Future<void> _initialize() async {
    try {
      final preferences = await SharedPreferences.getInstance();
      _recoveredBatches = _decodeRecoveredBatches(
        preferences.getString(_recoveredBatchesKey),
      );
      await _pruneRecoveredBatches(preferences);
      await _recoverInterruptedSelection(preferences);
    } on Object catch (error, stackTrace) {
      // Recovery is defensive and must never make the app unbootable. Every
      // selection path also remains usable when local recovery metadata fails.
      appLogger.w(
        'Media picker recovery initialization failed',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<List<AcquiredMedia>> pickImages({
    required MediaUseCase useCase,
    required bool multiple,
    required int maxItems,
  }) async {
    await initialize();
    final lease = _acquirePickerLease();
    try {
      final recovered = await _claimRecovered(
        useCase: useCase,
        kind: MediaKind.image,
        maxItems: maxItems,
      );
      if (recovered.isNotEmpty) return recovered;
      _throwRecoveryFailureIfNeeded(useCase: useCase, kind: MediaKind.image);

      final request = _PendingPickerRequest.create(
        useCase: useCase,
        kind: MediaKind.image,
        maxItems: maxItems,
      );
      final preferences = await SharedPreferences.getInstance();
      await _recordPendingRequest(preferences, request);
      try {
        final selected = <PickerGatewayFile>[];
        if (multiple) {
          selected.addAll(await _gateway.pickMultipleImages(limit: maxItems));
        } else {
          final file = await _gateway.pickSingleImage();
          if (file != null) selected.add(file);
        }
        return _stage(
          selected.take(maxItems),
          kind: MediaKind.image,
          source: MediaAcquisitionSource.gallery,
        );
      } on MediaAcquisitionException {
        rethrow;
      } on Exception catch (error) {
        throw MediaAcquisitionException(
          'The photo library could not be opened: $error',
        );
      } finally {
        await _clearPendingRequest(preferences, request);
      }
    } finally {
      lease.release();
    }
  }

  @override
  Future<AcquiredMedia?> pickVideo({required MediaUseCase useCase}) async {
    await initialize();
    final lease = _acquirePickerLease();
    try {
      final recovered = await _claimRecovered(
        useCase: useCase,
        kind: MediaKind.video,
        maxItems: 1,
      );
      if (recovered.isNotEmpty) return recovered.first;
      _throwRecoveryFailureIfNeeded(useCase: useCase, kind: MediaKind.video);

      final request = _PendingPickerRequest.create(
        useCase: useCase,
        kind: MediaKind.video,
        maxItems: 1,
      );
      final preferences = await SharedPreferences.getInstance();
      await _recordPendingRequest(preferences, request);
      try {
        final selected = await _gateway.pickSingleVideo();
        if (selected == null) return null;
        final staged = await _stage(
          <PickerGatewayFile>[selected],
          kind: MediaKind.video,
          source: MediaAcquisitionSource.gallery,
        );
        return staged.first;
      } on MediaAcquisitionException {
        rethrow;
      } on Exception catch (error) {
        throw MediaAcquisitionException(
          'The video library could not be opened: $error',
        );
      } finally {
        await _clearPendingRequest(preferences, request);
      }
    } finally {
      lease.release();
    }
  }

  MediaPickerLease _acquirePickerLease() {
    try {
      return _pickerOperations.acquire(MediaPickerOwner.photoLibrary);
    } on MediaPickerBusyException {
      throw const MediaAcquisitionException(
        'Another media selection is already in progress.',
      );
    }
  }

  Future<void> _recoverInterruptedSelection(
    SharedPreferences preferences,
  ) async {
    final pending = _decodePendingRequest(
      preferences.getString(_pendingRequestKey),
    );

    PickerGatewayLostData response;
    try {
      response = await _gateway.retrieveLostData();
    } on Exception catch (error, stackTrace) {
      appLogger.w(
        'Could not inspect interrupted media-picker result',
        error: error,
        stackTrace: stackTrace,
      );
      if (pending != null) {
        _recoveryFailure = _PickerRecoveryFailure(
          useCase: pending.useCase,
          kind: pending.kind,
          message: 'The interrupted media selection could not be recovered.',
        );
      }
      await preferences.remove(_pendingRequestKey);
      return;
    }

    await preferences.remove(_pendingRequestKey);
    if (pending == null) {
      if (response.files.isNotEmpty || response.errorDescription != null) {
        appLogger.w(
          'Discarding media-picker lost data without matching request metadata',
        );
      }
      return;
    }

    if (!_matchesCurrentPolicy(pending)) {
      appLogger.w(
        'Discarding media-picker recovery with invalid local policy metadata',
      );
      return;
    }

    final age = DateTime.now().difference(pending.startedAt);
    if (age > _maxRecoveryAge) {
      appLogger.i(
        'Discarding stale media-picker recovery for ${pending.useCase.name}',
      );
      return;
    }

    if (response.errorDescription != null) {
      _recoveryFailure = _PickerRecoveryFailure(
        useCase: pending.useCase,
        kind: pending.kind,
        message: 'The interrupted media selection could not be recovered.',
      );
      return;
    }
    if (response.files.isEmpty) return;

    try {
      final staged = await _stage(
        response.files.take(pending.maxItems),
        kind: pending.kind,
        source: MediaAcquisitionSource.gallery,
      );
      if (staged.isEmpty) return;

      final recovered = _RecoveredPickerBatch(
        useCase: pending.useCase,
        kind: pending.kind,
        recoveredAt: DateTime.now(),
        files: staged
            .map(
              (media) => _RecoveredPickerFile(
                path: media.path,
                originalName: media.originalName,
              ),
            )
            .toList(growable: false),
      );
      _recoveredBatches = <_RecoveredPickerBatch>[
        ..._recoveredBatches,
        recovered,
      ];
      await _trimRecoveredQueue();
      await _persistRecoveredBatches(preferences);
      appLogger.i(
        'Recovered interrupted ${pending.kind.name} selection for '
        '${pending.useCase.name}',
      );
    } on Object catch (error, stackTrace) {
      appLogger.w(
        'Interrupted media selection could not be staged',
        error: error,
        stackTrace: stackTrace,
      );
      _recoveryFailure = _PickerRecoveryFailure(
        useCase: pending.useCase,
        kind: pending.kind,
        message: 'The interrupted media selection could not be recovered.',
      );
    }
  }

  bool _matchesCurrentPolicy(_PendingPickerRequest request) {
    final policy = MediaPolicies.forUseCase(request.useCase);
    return policy.allowedKinds.contains(request.kind) &&
        request.maxItems >= 1 &&
        request.maxItems <= policy.maxItems;
  }

  Future<List<AcquiredMedia>> _claimRecovered({
    required MediaUseCase useCase,
    required MediaKind kind,
    required int maxItems,
  }) async {
    final index = _recoveredBatches.indexWhere(
      (batch) => batch.useCase == useCase && batch.kind == kind,
    );
    if (index < 0) return const <AcquiredMedia>[];

    final batch = _recoveredBatches[index];
    final files = <AcquiredMedia>[];
    for (final recovered in batch.files.take(maxItems)) {
      final file = File(recovered.path);
      if (!await file.exists()) continue;
      files.add(
        AcquiredMedia(
          file: file,
          kind: kind,
          source: MediaAcquisitionSource.gallery,
          originalName: recovered.originalName,
          ownedByApp: true,
        ),
      );
    }

    for (final extra in batch.files.skip(maxItems)) {
      await _deleteRecoveredFile(extra.path);
    }

    _recoveredBatches = <_RecoveredPickerBatch>[
      ..._recoveredBatches.take(index),
      ..._recoveredBatches.skip(index + 1),
    ];
    try {
      final preferences = await SharedPreferences.getInstance();
      await _persistRecoveredBatches(preferences);
    } on Object catch (error, stackTrace) {
      appLogger.w(
        'Could not persist consumed media-picker recovery',
        error: error,
        stackTrace: stackTrace,
      );
    }
    return files;
  }

  void _throwRecoveryFailureIfNeeded({
    required MediaUseCase useCase,
    required MediaKind kind,
  }) {
    final failure = _recoveryFailure;
    if (failure == null || failure.useCase != useCase || failure.kind != kind) {
      return;
    }
    _recoveryFailure = null;
    throw MediaAcquisitionException(failure.message);
  }

  Future<List<AcquiredMedia>> _stage(
    Iterable<PickerGatewayFile> files, {
    required MediaKind kind,
    required MediaAcquisitionSource source,
  }) async {
    final staged = <AcquiredMedia>[];
    try {
      for (final file in files) {
        if (file.path.trim().isEmpty) continue;
        staged.add(
          await _staging.stageFile(
            sourceFile: File(file.path),
            kind: kind,
            source: source,
            originalName: file.name,
          ),
        );
      }
      return staged;
    } on Object {
      for (final media in staged) {
        await media.discard();
      }
      rethrow;
    }
  }

  Future<void> _recordPendingRequest(
    SharedPreferences preferences,
    _PendingPickerRequest request,
  ) async {
    try {
      await preferences.setString(
        _pendingRequestKey,
        jsonEncode(request.toJson()),
      );
    } on Object catch (error, stackTrace) {
      appLogger.w(
        'Could not persist pending media-picker request',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> _clearPendingRequest(
    SharedPreferences preferences,
    _PendingPickerRequest request,
  ) async {
    try {
      final current = _decodePendingRequest(
        preferences.getString(_pendingRequestKey),
      );
      if (current == null || current.id == request.id) {
        await preferences.remove(_pendingRequestKey);
      }
    } on Object catch (error, stackTrace) {
      appLogger.w(
        'Could not clear pending media-picker request',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> _pruneRecoveredBatches(SharedPreferences preferences) async {
    final now = DateTime.now();
    final retained = <_RecoveredPickerBatch>[];
    for (final batch in _recoveredBatches) {
      final stale = now.difference(batch.recoveredAt) > _maxRecoveryAge;
      final validFiles = <_RecoveredPickerFile>[];
      for (final recovered in batch.files) {
        final exists = await File(recovered.path).exists();
        if (!stale && exists) {
          validFiles.add(recovered);
        } else if (exists) {
          await _deleteRecoveredFile(recovered.path);
        }
      }
      if (!stale && validFiles.isNotEmpty) {
        retained.add(batch.copyWith(files: validFiles));
      }
    }
    _recoveredBatches = retained;
    await _trimRecoveredQueue();
    await _persistRecoveredBatches(preferences);
  }

  Future<void> _trimRecoveredQueue() async {
    if (_recoveredBatches.length <= _maxRecoveredBatches) return;
    final removeCount = _recoveredBatches.length - _maxRecoveredBatches;
    final removed = _recoveredBatches.take(removeCount).toList(growable: false);
    _recoveredBatches = _recoveredBatches
        .skip(removeCount)
        .toList(growable: false);
    for (final batch in removed) {
      for (final file in batch.files) {
        await _deleteRecoveredFile(file.path);
      }
    }
  }

  Future<void> _persistRecoveredBatches(SharedPreferences preferences) async {
    if (_recoveredBatches.isEmpty) {
      await preferences.remove(_recoveredBatchesKey);
      return;
    }
    await preferences.setString(
      _recoveredBatchesKey,
      jsonEncode(
        _recoveredBatches
            .map((batch) => batch.toJson())
            .toList(growable: false),
      ),
    );
  }

  Future<void> _deleteRecoveredFile(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) await file.delete();
    } on FileSystemException catch (error, stackTrace) {
      appLogger.w(
        'Recovered media cleanup failed',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  _PendingPickerRequest? _decodePendingRequest(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;
    try {
      final Object? decoded = jsonDecode(raw);
      return _PendingPickerRequest.fromJson(decoded);
    } on FormatException {
      return null;
    }
  }

  List<_RecoveredPickerBatch> _decodeRecoveredBatches(String? raw) {
    if (raw == null || raw.trim().isEmpty) {
      return const <_RecoveredPickerBatch>[];
    }
    try {
      final Object? decoded = jsonDecode(raw);
      return asJsonList(decoded)
          .map(_RecoveredPickerBatch.fromJson)
          .whereType<_RecoveredPickerBatch>()
          .toList(growable: false);
    } on FormatException {
      return const <_RecoveredPickerBatch>[];
    }
  }
}

class _PendingPickerRequest {
  const _PendingPickerRequest({
    required this.id,
    required this.useCase,
    required this.kind,
    required this.maxItems,
    required this.startedAt,
  });

  factory _PendingPickerRequest.create({
    required MediaUseCase useCase,
    required MediaKind kind,
    required int maxItems,
  }) {
    final now = DateTime.now();
    return _PendingPickerRequest(
      id: '${now.microsecondsSinceEpoch}-${useCase.name}-${kind.name}',
      useCase: useCase,
      kind: kind,
      maxItems: maxItems,
      startedAt: now,
    );
  }

  factory _PendingPickerRequest.fromJson(Object? value) {
    final map = asJsonMap(value);
    final id = asNullableString(map['id']);
    final useCase = _mediaUseCaseByName(asNullableString(map['use_case']));
    final kind = _mediaKindByName(asNullableString(map['kind']));
    final maxItems = asInt(map['max_items']);
    final startedAtMillis = asInt(map['started_at_ms']);
    if (id == null ||
        useCase == null ||
        kind == null ||
        maxItems <= 0 ||
        startedAtMillis <= 0) {
      throw const FormatException('Invalid pending media-picker request.');
    }
    return _PendingPickerRequest(
      id: id,
      useCase: useCase,
      kind: kind,
      maxItems: maxItems,
      startedAt: DateTime.fromMillisecondsSinceEpoch(startedAtMillis),
    );
  }

  final String id;
  final MediaUseCase useCase;
  final MediaKind kind;
  final int maxItems;
  final DateTime startedAt;

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'id': id,
      'use_case': useCase.name,
      'kind': kind.name,
      'max_items': maxItems,
      'started_at_ms': startedAt.millisecondsSinceEpoch,
    };
  }
}

class _RecoveredPickerFile {
  const _RecoveredPickerFile({required this.path, required this.originalName});

  factory _RecoveredPickerFile.fromJson(Object? value) {
    final map = asJsonMap(value);
    final path = asNullableString(map['path']);
    final originalName = asNullableString(map['original_name']);
    if (path == null || originalName == null) {
      throw const FormatException('Invalid recovered media file.');
    }
    return _RecoveredPickerFile(path: path, originalName: originalName);
  }

  final String path;
  final String originalName;

  Map<String, Object?> toJson() {
    return <String, Object?>{'path': path, 'original_name': originalName};
  }
}

class _RecoveredPickerBatch {
  const _RecoveredPickerBatch({
    required this.useCase,
    required this.kind,
    required this.recoveredAt,
    required this.files,
  });

  static _RecoveredPickerBatch? fromJson(Object? value) {
    try {
      final map = asJsonMap(value);
      final useCase = _mediaUseCaseByName(asNullableString(map['use_case']));
      final kind = _mediaKindByName(asNullableString(map['kind']));
      final recoveredAtMillis = asInt(map['recovered_at_ms']);
      final files = asJsonList(
        map['files'],
      ).map(_RecoveredPickerFile.fromJson).toList(growable: false);
      if (useCase == null ||
          kind == null ||
          recoveredAtMillis <= 0 ||
          files.isEmpty) {
        return null;
      }
      return _RecoveredPickerBatch(
        useCase: useCase,
        kind: kind,
        recoveredAt: DateTime.fromMillisecondsSinceEpoch(recoveredAtMillis),
        files: files,
      );
    } on FormatException {
      return null;
    }
  }

  final MediaUseCase useCase;
  final MediaKind kind;
  final DateTime recoveredAt;
  final List<_RecoveredPickerFile> files;

  _RecoveredPickerBatch copyWith({List<_RecoveredPickerFile>? files}) {
    return _RecoveredPickerBatch(
      useCase: useCase,
      kind: kind,
      recoveredAt: recoveredAt,
      files: files ?? this.files,
    );
  }

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'use_case': useCase.name,
      'kind': kind.name,
      'recovered_at_ms': recoveredAt.millisecondsSinceEpoch,
      'files': files.map((file) => file.toJson()).toList(growable: false),
    };
  }
}

class _PickerRecoveryFailure {
  const _PickerRecoveryFailure({
    required this.useCase,
    required this.kind,
    required this.message,
  });

  final MediaUseCase useCase;
  final MediaKind kind;
  final String message;
}

MediaUseCase? _mediaUseCaseByName(String? name) {
  if (name == null) return null;
  for (final value in MediaUseCase.values) {
    if (value.name == name) return value;
  }
  return null;
}

MediaKind? _mediaKindByName(String? name) {
  if (name == null) return null;
  for (final value in MediaKind.values) {
    if (value.name == name) return value;
  }
  return null;
}
