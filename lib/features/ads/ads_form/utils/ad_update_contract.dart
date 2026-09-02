import 'package:africaonlinestores/core/api/failure.dart';
import 'package:africaonlinestores/core/utils/either.dart';

class AdUpdateContract {
  const AdUpdateContract._();

  static const Set<String> activeEditableFields = <String>{
    'title',
    'description',
    'price_type',
    'price',
    'price_unit',
    'offer_price',
    'offer_start_date',
    'offer_end_date',
  };

  static const Set<String> fullEditableFields = <String>{
    'title',
    'location',
    'category',
    'description',
    'details',
    'images',
    'price_type',
    'price',
    'price_unit',
    'offer_price',
    'offer_start_date',
    'offer_end_date',
    'video_media',
    'video_media_id',
    'video',
  };

  static const Set<String> fullEditStatuses = <String>{'Reviewing', 'Declined'};

  static const Set<String> blockedEditStatuses = <String>{
    'Sold',
    'Expired',
    'Deleted',
    'Suspended',
  };

  static Either<Failure, Map<String, dynamic>> payloadForStatus({
    required String status,
    required Map<String, dynamic> candidate,
  }) {
    final normalized = status.trim();

    if (normalized == 'Active') {
      final payload = _only(candidate, activeEditableFields);
      if (payload.isEmpty) {
        return Either.left(
          const Failure(
            'There are no editable changes to save.',
            statusCode: 422,
            type: FailureType.validation,
            error: 'INVALID_AD_INPUT',
          ),
        );
      }
      return Either.right(payload);
    }

    if (fullEditStatuses.contains(normalized)) {
      return Either.right(_only(candidate, fullEditableFields));
    }

    return Either.left(
      Failure(
        editBlockedMessage(normalized),
        statusCode: 409,
        type: FailureType.validation,
        error: 'INVALID_AD_STATE',
      ),
    );
  }

  static String editBlockedMessage(String status) {
    switch (status.trim()) {
      case 'Sold':
        return 'Sold listings cannot be edited. Mark the listing as available before editing it.';
      case 'Expired':
        return 'Expired listings cannot be edited. Renew the listing before editing it.';
      case 'Deleted':
        return 'Deleted listings cannot be edited.';
      case 'Suspended':
        return 'Suspended listings cannot be edited while the suspension is active.';
      default:
        return 'This listing cannot be edited in its current state. Refresh the listing and try again.';
    }
  }

  static Map<String, dynamic> _only(
    Map<String, dynamic> source,
    Set<String> allowed,
  ) {
    return <String, dynamic>{
      for (final entry in source.entries)
        if (allowed.contains(entry.key)) entry.key: entry.value,
    };
  }
}
