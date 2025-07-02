import 'package:dartz/dartz.dart';

import '/core/errors/failures.dart';

import 'entity/delivery_note.dart';
import 'repo.dart';

class GetAllDeliveryNotes {
  final DeliveryNoteRepo repo;

  GetAllDeliveryNotes(this.repo);

  Future<Either<Failure, List<DeliveryNote>>> call() async {
    return await repo.getAll();
  }
}

class GetDeliveryNoteById {
  final DeliveryNoteRepo repo;

  GetDeliveryNoteById(this.repo);

  Future<Either<Failure, DeliveryNote>> call(String id) async {
    return await repo.getById(id);
  }
}
