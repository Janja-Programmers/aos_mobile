import 'package:dartz/dartz.dart';

import '/core/errors/failures.dart';

import 'entity/delivery_note.dart';

abstract class DeliveryNoteRepo {
  Future<Either<Failure, List<DeliveryNote>>> getAll();
  Future<Either<Failure, DeliveryNote>> getById(String id);
}
