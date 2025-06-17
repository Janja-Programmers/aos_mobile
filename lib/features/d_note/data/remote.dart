import 'package:dartz/dartz.dart';

import '/core/constants/const.dart';
import '/core/errors/exception.dart';
import '/core/errors/failures.dart';
import '/core/utils/api_client.dart';

import 'model.dart';

class DeliveryNoteRemoteDS {
  final APIClient _client;
  DeliveryNoteRemoteDS(this._client);

  /// Fetches *full* Delivery Note records and returns DTOs.
  Future<Either<Failure, List<DeliveryNoteModel>>> getAll() async {
    try {
      // 1️⃣‑ list endpoint (names only)
      final res = await _client.client.get(DELIVERY_NOTE_ENDPOINT);
      final List<dynamic> list = res.data['data'];

      // 2️⃣‑ fetch each full record in parallel
      final futures =
          list
              .map(
                (e) =>
                    _client.client.get('$DELIVERY_NOTE_ENDPOINT/${e['name']}'),
              )
              .toList();

      final responses = await Future.wait(futures);

      // 3️⃣‑ map JSON → DTO
      final models =
          responses
              .map((resp) => DeliveryNoteModel.fromJson(resp.data['data']))
              .toList();

      return Right(models);
    } catch (e) {
      return Left(handleException(e));
    }
  }
}
