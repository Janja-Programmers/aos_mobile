import 'dart:convert';
import 'dart:io';

import 'package:africaonlinestores/features/shorts/create_short/domain/short_creation_models.dart';
import 'package:africaonlinestores/features/shorts/create_short/domain/short_draft.dart';
import 'package:path_provider/path_provider.dart';

abstract interface class ShortDraftRepository {
  Future<ShortDraft> save(ShortEditorState state);
  Future<ShortDraft?> latestForOwner(String ownerId);
  Future<void> delete(String sessionId);
  Future<void> prune({Duration maxAge = const Duration(days: 30)});
}

class LocalShortDraftRepository implements ShortDraftRepository {
  const LocalShortDraftRepository();

  @override
  Future<ShortDraft> save(ShortEditorState state) async {
    final root = await _root();
    final directory = Directory(
      _join(root.path, _safeFileComponent(state.sessionId)),
    );
    await directory.create(recursive: true);

    final durableSource = await _ensureDurableSource(
      sourcePath: state.sourcePath,
      directory: directory,
    );
    final metadataFile = File(_join(directory.path, 'draft.json'));
    final existing = await _read(metadataFile);
    final now = DateTime.now().toUtc();

    final draft = ShortDraft(
      schemaVersion: ShortDraft.currentSchemaVersion,
      sessionId: state.sessionId,
      ownerId: state.ownerId,
      sourcePath: durableSource.path,
      trimStartMs: state.trimStart.inMilliseconds,
      trimEndMs: state.trimEnd.inMilliseconds,
      durationMs: state.duration.inMilliseconds,
      videoWidth: state.videoSize.width,
      videoHeight: state.videoSize.height,
      selectedSound: state.selectedSound,
      overlays: state.overlays,
      createdAt: existing?.createdAt ?? now,
      updatedAt: now,
    );

    final temporary = File('${metadataFile.path}.tmp');
    await temporary.writeAsString(jsonEncode(draft.toJson()), flush: true);
    if (metadataFile.existsSync()) {
      await metadataFile.delete();
    }
    await temporary.rename(metadataFile.path);
    return draft;
  }

  @override
  Future<ShortDraft?> latestForOwner(String ownerId) async {
    final normalizedOwner = ownerId.trim();
    if (normalizedOwner.isEmpty) return null;

    final root = await _root();
    if (!root.existsSync()) return null;

    ShortDraft? latest;
    await for (final entity in root.list(followLinks: false)) {
      if (entity is! Directory) continue;
      final draft = await _read(File(_join(entity.path, 'draft.json')));
      if (draft == null || draft.ownerId != normalizedOwner) continue;
      if (!File(draft.sourcePath).existsSync()) {
        await entity.delete(recursive: true);
        continue;
      }
      if (latest == null || draft.updatedAt.isAfter(latest.updatedAt)) {
        latest = draft;
      }
    }
    return latest;
  }

  @override
  Future<void> delete(String sessionId) async {
    final clean = sessionId.trim();
    if (clean.isEmpty) return;
    final root = await _root();
    final directory = Directory(_join(root.path, _safeFileComponent(clean)));
    if (directory.existsSync()) {
      await directory.delete(recursive: true);
    }
  }

  @override
  Future<void> prune({Duration maxAge = const Duration(days: 30)}) async {
    final root = await _root();
    if (!root.existsSync()) return;
    final cutoff = DateTime.now().toUtc().subtract(maxAge);
    await for (final entity in root.list(followLinks: false)) {
      if (entity is! Directory) continue;
      final draft = await _read(File(_join(entity.path, 'draft.json')));
      if (draft == null || draft.updatedAt.isBefore(cutoff)) {
        await entity.delete(recursive: true);
      }
    }
  }

  Future<Directory> _root() async {
    final support = await getApplicationSupportDirectory();
    final root = Directory(_join(support.path, 'shorts_drafts'));
    await root.create(recursive: true);
    return root;
  }

  Future<File> _ensureDurableSource({
    required String sourcePath,
    required Directory directory,
  }) async {
    final source = File(sourcePath);
    if (!source.existsSync()) {
      throw const FileSystemException('The draft video is missing.');
    }

    final normalizedDirectory = directory.absolute.path;
    if (source.absolute.path.startsWith(normalizedDirectory)) return source;

    final extension = _extension(source.path);
    final destination = File(
      _join(directory.path, 'source${extension.isEmpty ? '.mp4' : extension}'),
    );
    if (destination.existsSync()) {
      await destination.delete();
    }
    return source.copy(destination.path);
  }

  Future<ShortDraft?> _read(File file) async {
    try {
      if (!file.existsSync()) return null;
      final decoded = jsonDecode(await file.readAsString());
      if (decoded is! Map<Object?, Object?>) return null;
      return ShortDraft.fromJson(Map<String, dynamic>.from(decoded));
    } catch (_) {
      return null;
    }
  }
}

String _join(String a, String b) => '$a${Platform.pathSeparator}$b';

String _extension(String path) {
  final slash = path.replaceAll('\\', '/').split('/').last;
  final index = slash.lastIndexOf('.');
  return index == -1 ? '' : slash.substring(index);
}

String _safeFileComponent(String value) {
  return value.trim().replaceAll(RegExp('[^A-Za-z0-9._-]'), '_');
}
