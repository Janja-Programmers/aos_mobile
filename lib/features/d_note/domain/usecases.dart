import 'package:dartz/dartz.dart';

import '/core/errors/failures.dart';

import 'delivery_note.dart';
import 'repo.dart';

class GetAllDeliveryNotes {
  final DeliveryNoteRepo repo;

  GetAllDeliveryNotes(this.repo);

  Future<Either<Failure, List<DeliveryNote>>> call() async {
    return await repo.getAll();
  }
}
