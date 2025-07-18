import 'package:dartz/dartz.dart';

import '/core/errors/failures.dart';
import 'webitem.dart';

abstract class WebsiteRepo {
  Future<Either<Failure, List<WebsiteItem>>> getAllItems({required int start});
  Future<Either<Failure, WebsiteItem>> getOne(String id);
}
