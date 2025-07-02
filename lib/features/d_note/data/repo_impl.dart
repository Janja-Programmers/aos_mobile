import 'package:dartz/dartz.dart';

import '/core/errors/failures.dart';
import '../domain/entity/delivery_note.dart';
import '../domain/repo.dart';
import 'remote.dart';

class DeliveryNoteRepoImpl implements DeliveryNoteRepo {
  final DeliveryNoteRemoteDS remote;

  DeliveryNoteRepoImpl({required this.remote});

  @override
  Future<Either<Failure, List<DeliveryNote>>> getAll() async {
    final result = await remote.getAll();
    return result.map((models) => models.cast<DeliveryNote>());
  }

  @override
  Future<Either<Failure, DeliveryNote>> getById(String id) async {
    final result = await remote.getById(id);
    return result.map((model) => model as DeliveryNote);
  }
}
