import 'package:dartz/dartz.dart';

import '/core/errors/failures.dart';
import '../domain/delivery_note.dart';
import '../domain/repo.dart';
import 'remote.dart';

class DeliveryNoteRepoImpl implements DeliveryNoteRepo {
  final DeliveryNoteRemoteDS remote;
  DeliveryNoteRepoImpl({required this.remote});

  @override
  Future<Either<Failure, List<DeliveryNote>>> getAll() async {
    final result = await remote.getAll();
    // Each DTO extends the entity, so a simple cast is safe:
    return result.map((models) => models.cast<DeliveryNote>());
  }
}
