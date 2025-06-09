import 'package:dartz/dartz.dart';

import '../../../core/errors/failures.dart';
import 'item.dart';

abstract class WebsiteRepo {
  Future<Either<Failure, List<WebsiteItem>>> getAllItems();
}
