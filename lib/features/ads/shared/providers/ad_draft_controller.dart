import 'dart:async';
import 'dart:io';

import 'package:africaonlinestores/core/api/failure.dart';
import 'package:africaonlinestores/core/media/application/media_services_provider.dart';
import 'package:africaonlinestores/core/media/data/media_upload_api_provider.dart';
import 'package:africaonlinestores/core/media/domain/media_asset.dart';
import 'package:africaonlinestores/core/media/domain/media_policy.dart';
import 'package:africaonlinestores/core/media/domain/media_upload_purpose.dart';
import 'package:africaonlinestores/core/utils/either.dart';
import 'package:africaonlinestores/core/utils/json_utils.dart';
import 'package:africaonlinestores/features/ads/domain/ad_draft.dart';
import 'package:africaonlinestores/features/ads/shared/providers/ads_api_provider.dart';
import 'package:africaonlinestores/shared/enums/ads.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

final adDraftControllerProvider =
    StateNotifierProvider<AdDraftController, AsyncValue<AdDraft>>(
      AdDraftController.new,
    );

class AdDraftController extends StateNotifier<AsyncValue<AdDraft>> {
  AdDraftController(this._ref)
    : _draft = const AdDraft(source: DraftSource.create),
      super(const AsyncValue.data(AdDraft(source: DraftSource.create)));

  final Ref _ref;

  AdDraft _draft;

  AdDraft get draft => _draft;
  final _deletingMedia = <String>{};

  // ================= SETUP =================

  void createNew() {
    _setDraft(const AdDraft(source: DraftSource.create));
  }

  Future<void> loadFromDraft(String draftId) async {
    final api = _ref.read(adsApiProvider);

    state = const AsyncValue.loading();

    final res = await api.getAdDraft(draftId: draftId);

    if (res.isLeft) {
      state = AsyncValue.error(res.leftOrNull!, StackTrace.current);
      return;
    }

    final raw = res.rightOrNull!;
    final draftData = raw['data'];

    final draft = AdDraft.fromDraft(asJsonMap(draftData));

    _draft = draft.copyWith(source: DraftSource.draft, draftId: draftId);

    state = AsyncValue.data(_draft);
  }

  Future<void> loadFromAd(String adId) async {
    final api = _ref.read(adsApiProvider);

    state = const AsyncValue.loading();

    final res = await api.getAd(adId: adId);

    if (res.isLeft) {
      state = AsyncValue.error(res.leftOrNull!, StackTrace.current);
      return;
    }

    final draft = AdDraft.fromAd(res.rightOrNull!);

    _draft = draft.copyWith(source: DraftSource.edit, adId: adId);

    state = AsyncValue.data(_draft);
  }

  Future<void> loadFromMyAd(String adId) async {
    final api = _ref.read(adsApiProvider);

    state = const AsyncValue.loading();

    final res = await api.getMyAd(adId: adId);

    if (res.isLeft) {
      state = AsyncValue.error(res.leftOrNull!, StackTrace.current);
      return;
    }

    final response = res.rightOrNull!;

    final data = asJsonMap(response['data']);
    final item = asJsonMap(data['item']);

    final draft = AdDraft.fromAd(item);

    _draft = draft.copyWith(source: DraftSource.edit, adId: adId);

    state = AsyncValue.data(_draft);
  }

  // ================= BASIC =================

  void updateTitle(String v) {
    _setDraft(_draft.copyWith(title: v));
  }

  void setLocation({required String id, required String label}) {
    _setDraft(_draft.copyWith(locationId: id, locationLabel: label));
  }

  void setCountry(String? id) {
    _setDraft(_draft.copyWith(countryId: id));
  }

  void setCategory({required String id, required String label}) {
    _setDraft(
      _draft.copyWith(
        categoryId: id,
        categoryLabel: label,
        attributes: <String, dynamic>{},
      ),
    );
  }

  // ================= DETAILS =================

  void setAttribute(String key, Object? value) {
    final next = Map<String, dynamic>.of(_draft.attributes);

    if (value == null || (value is String && value.trim().isEmpty)) {
      next.remove(key);
    } else {
      next[key] = value;
    }

    _setDraft(_draft.copyWith(attributes: next));
  }

  void setDescription(String v) {
    _setDraft(_draft.copyWith(description: v));
  }

  // ================= PRICING =================

  void setPrice(double? v) {
    _setDraft(_draft.copyWith(price: v));
  }

  void setPriceUnit(String? v) {
    _setDraft(
      _draft.copyWith(priceUnit: (v == null || v.trim().isEmpty) ? null : v),
    );
  }

  void clearPricing() {
    _setDraft(_draft.copyWith());
  }

  void setPriceType(String? v) {
    final type = (v == null || v.trim().isEmpty) ? null : v;

    if (type != 'Fixed') {
      _setDraft(
        _draft.copyWith(
          priceType: type,
          scheduleOfferDates: false,
          clearAllOffer: true,
        ),
      );
      return;
    }

    _setDraft(_draft.copyWith(priceType: type));
  }

  void setOfferPrice(double? value) {
    if (value == null || value <= 0) {
      _setDraft(
        _draft.copyWith(
          scheduleOfferDates: false,
          clearOfferStart: true,
          clearOfferEnd: true,
        ),
      );
      return;
    }

    _setDraft(_draft.copyWith(offerPrice: value));
  }

  void setOfferStart(DateTime? value) {
    if (_draft.scheduleOfferDates != true) return;

    if (value == null) {
      _setDraft(_draft.copyWith(clearOfferStart: true));
      return;
    }

    _setDraft(_draft.copyWith(offerStart: value));
  }

  void setOfferEnd(DateTime? value) {
    if (_draft.scheduleOfferDates != true) return;

    if (value == null) {
      _setDraft(_draft.copyWith(clearOfferEnd: true));
      return;
    }

    _setDraft(_draft.copyWith(offerEnd: value));
  }

  void setScheduleOfferDates(bool v) {
    if (!v || _draft.offerPrice == null) {
      _setDraft(
        _draft.copyWith(
          scheduleOfferDates: false,
          clearOfferStart: true,
          clearOfferEnd: true,
        ),
      );
      return;
    }

    _setDraft(_draft.copyWith(scheduleOfferDates: true));
  }

  void setFreeConsultation(bool v) {
    _setDraft(_draft.copyWith(freeConsultation: v));
  }

  void setRequiresDeposit(bool v) {
    _setDraft(_draft.copyWith(requiresDeposit: v));
  }

  // ================= MEDIA =================

  /// Replace entire image list safely
  void replaceImages(List<AdMediaImage> images) {
    if (images.isEmpty) {
      _setDraft(_draft.copyWith(images: []));
      return;
    }

    // Ensure first image is primary
    final normalized = <AdMediaImage>[];

    for (int i = 0; i < images.length; i++) {
      normalized.add(images[i].copyWith(isPrimary: i == 0));
    }

    _setDraft(_draft.copyWith(images: normalized));
  }

  /// Reorder and set primary
  void setPrimaryImage(int index) {
    if (index < 0 || index >= _draft.images.length) return;
    if (index == 0) return;

    final images = List<AdMediaImage>.from(_draft.images);

    final selected = images.removeAt(index);
    images.insert(0, selected);

    replaceImages(images);
  }

  Future<void> removeImage(int index) async {
    if (index < 0 || index >= _draft.images.length) return;

    final image = _draft.images[index];

    final next = List<AdMediaImage>.from(_draft.images)..removeAt(index);
    replaceImages(next);
    if (image.fileId.trim().isNotEmpty) {
      unawaited(deleteMediaSilently(image.fileId));
    }
  }

  Future<void> deleteMediaSilently(String mediaId) async {
    if (_deletingMedia.contains(mediaId)) return;

    _deletingMedia.add(mediaId);

    final api = _ref.read(mediaUploadApiProvider);

    await api.deleteMedia(mediaId: mediaId);

    _deletingMedia.remove(mediaId);
  }

  Future<Either<Failure, String>> removeImageBackground(int index) async {
    if (index < 0 || index >= _draft.images.length) {
      return Either.left(const Failure('Invalid image index'));
    }

    final api = _ref.read(mediaUploadApiProvider);

    final image = _draft.images[index];

    if (image.fileId.isEmpty) {
      return Either.left(const Failure('Image has no media ID'));
    }

    final res = await api.removeBackground(
      mediaId: image.fileId,
      resultPurpose: MediaUploadPurpose.adImage,
    );

    if (res.isLeft) {
      return Either.left(res.leftOrNull!);
    }

    final uploaded = res.rightOrNull!;

    final newImage = image.copyWith(
      fileId: uploaded.mediaId,
      url: uploaded.url,
    );

    final images = List<AdMediaImage>.from(_draft.images);

    images[index] = newImage;

    replaceImages(images);

    unawaited(deleteMediaSilently(image.fileId));

    return Either.right(uploaded.url);
  }

  // ----------------- EDIT IMAGE -----------------
  Future<void> replaceImageAt(int index, File file) async {
    if (index < 0 || index >= _draft.images.length) return;

    final old = _draft.images[index];

    final res = await _ref
        .read(mediaUploadCoordinatorProvider)
        .uploadFile(file: file, useCase: MediaUseCase.adImage);
    if (res.isLeft) return;

    final uploadedFile = res.rightOrNull!;
    final uploaded = AdMediaImage.fromUpload(uploadedFile);

    final images = List<AdMediaImage>.from(_draft.images);

    final isPrimary = images[index].isPrimary;

    images[index] = uploaded.copyWith(isPrimary: isPrimary);

    replaceImages(images);

    if (old.fileId.isNotEmpty) {
      unawaited(deleteMediaSilently(old.fileId));
    }
  }

  Future<Either<Failure, String>> uploadAndAddImage(
    AcquiredMedia acquired,
  ) async {
    final res = await _ref
        .read(mediaUploadCoordinatorProvider)
        .upload(
          media: acquired,
          useCase: MediaUseCase.adImage,
          discardSourceWhenDone: true,
        );
    if (res.isLeft) {
      await acquired.discard();
      return Either.left(res.leftOrNull!);
    }

    final uploadedFile = res.rightOrNull!;
    final image = AdMediaImage.fromUpload(uploadedFile);

    final next = List<AdMediaImage>.from(_draft.images);

    next.add(image.copyWith(isPrimary: next.isEmpty));

    replaceImages(next);

    return Either.right(image.url);
  }

  Future<Either<Failure, String>> uploadAndSetVideo(
    AcquiredMedia acquired,
  ) async {
    final res = await _ref
        .read(mediaUploadCoordinatorProvider)
        .upload(
          media: acquired,
          useCase: MediaUseCase.adVideo,
          discardSourceWhenDone: true,
        );

    if (res.isLeft) {
      await acquired.discard();
      return Either.left(res.leftOrNull!);
    }

    final uploaded = res.rightOrNull!;

    final url = uploaded.url;
    final mediaId = uploaded.mediaId;

    _setDraft(_draft.copyWith(videoUrl: url, videoFileId: mediaId));

    return Either.right(url);
  }

  Future<void> clearVideo() async {
    final mediaId = _draft.videoFileId;

    _setDraft(_draft.copyWith());

    if (mediaId != null && mediaId.isNotEmpty) {
      unawaited(deleteMediaSilently(mediaId));
    }
  }

  // ================= INTERNAL =================

  void _setDraft(AdDraft next) {
    _draft = next;
    state = AsyncValue.data(next);
  }

  void reset() {
    _setDraft(const AdDraft(source: DraftSource.create));
  }

  AdDraft get safeDraft => state.value ?? _draft;
}
