import 'dart:convert';
import 'dart:io';

import 'package:africaonlinestores/features/shorts/create_short/domain/pending_short_publication.dart';
import 'package:path_provider/path_provider.dart';

class PendingShortPublicationRepository {
  const PendingShortPublicationRepository();

  Future<void> save(PendingShortPublication job) async {
    final directory = await _directory();
    final target = File(
      _join(directory.path, '${_safeFileComponent(job.sessionId)}.json'),
    );
    final temporary = File('${target.path}.tmp');
    await temporary.writeAsString(jsonEncode(job.toJson()), flush: true);
    if (target.existsSync()) {
      await target.delete();
    }
    await temporary.rename(target.path);
  }

  Future<List<PendingShortPublication>> loadAll({String? ownerId}) async {
    final directory = await _directory();
    final jobs = <PendingShortPublication>[];
    await for (final entity in directory.list(followLinks: false)) {
      if (entity is! File || !entity.path.endsWith('.json')) continue;
      try {
        final decoded = jsonDecode(await entity.readAsString());
        if (decoded is! Map<Object?, Object?>) continue;
        final job = PendingShortPublication.fromJson(
          Map<String, dynamic>.from(decoded),
        );
        final cleanOwner = ownerId?.trim();
        final ownerMatches =
            cleanOwner == null ||
            cleanOwner.isEmpty ||
            job.ownerId == cleanOwner;
        if (job.sessionId.isNotEmpty &&
            job.shortId.isNotEmpty &&
            ownerMatches) {
          jobs.add(job);
        }
      } catch (_) {
        await entity.delete();
      }
    }
    return jobs;
  }

  Future<void> delete(String sessionId) async {
    final directory = await _directory();
    final file = File(
      _join(directory.path, '${_safeFileComponent(sessionId)}.json'),
    );
    if (file.existsSync()) {
      await file.delete();
    }
  }

  Future<Directory> _directory() async {
    final support = await getApplicationSupportDirectory();
    final directory = Directory(
      _join(support.path, 'shorts_pending_publications'),
    );
    await directory.create(recursive: true);
    return directory;
  }
}

String _join(String a, String b) => '$a${Platform.pathSeparator}$b';

String _safeFileComponent(String value) {
  return value.trim().replaceAll(RegExp('[^A-Za-z0-9._-]'), '_');
}
