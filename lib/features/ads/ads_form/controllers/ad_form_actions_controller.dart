import 'package:africaonlinestores/core/api/failure.dart';
import 'package:africaonlinestores/core/utils/either.dart';
import 'package:africaonlinestores/features/ads/ads_form/utils/ad_form_payload.dart';
import 'package:africaonlinestores/features/ads/ads_form/utils/ad_update_contract.dart';
import 'package:africaonlinestores/features/ads/ads_form/utils/cancel_action.dart';
import 'package:africaonlinestores/features/ads/data/ads_api.dart';
import 'package:africaonlinestores/features/ads/domain/ad_draft.dart';
import 'package:africaonlinestores/features/ads/domain/ad_schema.dart';
import 'package:africaonlinestores/features/ads/shared/providers/ads_api_provider.dart';
import 'package:africaonlinestores/shared/enums/ads.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final adActionsControllerProvider = Provider<AdActionsController>((ref) {
  final api = ref.read(adsApiProvider);
  return AdActionsController(api);
});

class AdActionsController {
  AdActionsController(this.api);

  final AdsApi api;
  bool _isSavingDraft = false;

  Future<Either<Failure, Map<String, dynamic>>> submitAd({
    required AdDraft draft,
    required Map<String, dynamic> payload,
  }) async {
    switch (draft.source) {
      case DraftSource.create:
        return api.createAd(payload: payload);

      case DraftSource.draft:
        if (draft.draftId == null) {
          return Either.left(
            const Failure('Draft ID is missing. Cannot submit draft.'),
          );
        }

        final saveRes = await api.upsertAdDraft(
          draftId: draft.draftId!,
          payload: payload,
        );

        if (saveRes.isLeft) return saveRes;

        return api.submitAdDraft(draftId: draft.draftId!);

      case DraftSource.edit:
        if (draft.adId == null) {
          return Either.left(
            const Failure('Ad ID is missing. Cannot update ad.'),
          );
        }

        final contract = AdUpdateContract.payloadForStatus(
          status: draft.status ?? '',
          candidate: payload,
        );
        if (contract.isLeft) {
          return Either.left(contract.leftOrNull!);
        }

        return api.updateAd(adId: draft.adId!, payload: contract.rightOrNull!);
    }
  }

  Future<Either<Failure, Map<String, dynamic>>> saveDraft({
    required AdDraft draft,
    required Map<String, dynamic> payload,
  }) async {
    if (_isSavingDraft) {
      return Either.left(const Failure('Draft save in progress'));
    }

    _isSavingDraft = true;

    try {
      switch (draft.source) {
        case DraftSource.create:
          return await api.saveAdDraft(payload: payload);

        case DraftSource.draft:
          if (draft.draftId == null) {
            return Either.left(
              const Failure('Draft ID is missing. Cannot update draft.'),
            );
          }

          return await api.upsertAdDraft(
            draftId: draft.draftId!,
            payload: payload,
          );
        case DraftSource.edit:
          return Either.right(<String, dynamic>{});
      }
    } finally {
      _isSavingDraft = false;
    }
  }

  Future<Either<Failure, void>> handleCancel({
    required AdDraft draft,
    required AdCategorySchema schema,
    required CancelAction action,
  }) async {
    if (action == CancelAction.discard) {
      return Either.right(null);
    }

    if (action == CancelAction.saveAndExit) {
      final payload = AdFormPayloadBuilder.build(d: draft, schema: schema);
      final res = await saveDraft(draft: draft, payload: payload);

      if (res.isLeft) {
        return Either.left(res.leftOrNull!);
      }

      return Either.right(null);
    }

    return Either.right(null);
  }
}
