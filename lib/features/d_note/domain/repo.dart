import 'package:dartz/dartz.dart';

import '/core/errors/failures.dart';

import 'delivery_note.dart';

abstract class DeliveryNoteRepo {
  Future<Either<Failure, List<DeliveryNote>>> getAll();
}
