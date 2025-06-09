import 'package:dartz/dartz.dart';

import '../../../core/errors/failures.dart';
import 'webitem.dart';

abstract class WebsiteRepo {
  Future<Either<Failure, List<WebsiteItem>>> getAllItems();
}
