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
  int _loadGeneration = 0;

  AdDraft get draft => _draft;
  final _deletingMedia = <String>{};

  // ================= SETUP =================

  void createNew() {
    _loadGeneration += 1;
    _setDraft(const AdDraft(source: DraftSource.create));
  }

  Future<void> loadFromDraft(String draftId) async {
    final generation = _beginLoad();
    final api = _ref.read(adsApiProvider);
    final res = await api.getMyAdDraft(draftId: draftId);

    if (!_isCurrentLoad(generation)) return;

    if (res.isLeft) {
      state = AsyncValue.error(res.leftOrNull!, StackTrace.current);
      return;
    }

    try {
      final response = res.rightOrNull!;
      final data = asJsonMap(response['data']);
      final item = asJsonMap(data['item']);
      if (item.isEmpty) {
        throw const FormatException('Missing draft item');
      }
      final draft = AdDraft.fromDraft(item);

      if (!_isCurrentLoad(generation)) return;

      _draft = draft.copyWith(source: DraftSource.draft, draftId: draftId);
      state = AsyncValue.data(_draft);
    } catch (_, stackTrace) {
      if (!_isCurrentLoad(generation)) return;
      state = AsyncValue.error(
        const Failure('Failed to load ad draft.'),
        stackTrace,
      );
    }
  }

  Future<void> loadFromAd(String adId) async {
    final generation = _beginLoad();
    final api = _ref.read(adsApiProvider);
    final res = await api.getAd(adId: adId);

    if (!_isCurrentLoad(generation)) return;

    if (res.isLeft) {
      state = AsyncValue.error(res.leftOrNull!, StackTrace.current);
      return;
    }

    try {
      final response = res.rightOrNull!;
      final data = asJsonMap(response['data']);
      final item = asJsonMap(data['item']);
      final draft = AdDraft.fromAd(item);

      if (!_isCurrentLoad(generation)) return;

      _draft = draft.copyWith(source: DraftSource.edit, adId: adId);
      state = AsyncValue.data(_draft);
    } catch (_, stackTrace) {
      if (!_isCurrentLoad(generation)) return;
      state = AsyncValue.error(
        const Failure('Failed to load ad details.'),
        stackTrace,
      );
    }
  }

  Future<void> loadFromMyAd(String adId) async {
    final generation = _beginLoad();
    final api = _ref.read(adsApiProvider);
    final res = await api.getMyAd(adId: adId);

    if (!_isCurrentLoad(generation)) return;

    if (res.isLeft) {
      state = AsyncValue.error(res.leftOrNull!, StackTrace.current);
      return;
    }

    try {
      final response = res.rightOrNull!;
      final data = asJsonMap(response['data']);
      final item = asJsonMap(data['item']);
      final draft = AdDraft.fromAd(item);

      if (!_isCurrentLoad(generation)) return;

      _draft = draft.copyWith(source: DraftSource.edit, adId: adId);
      state = AsyncValue.data(_draft);
    } catch (_, stackTrace) {
      if (!_isCurrentLoad(generation)) return;
      state = AsyncValue.error(
        const Failure('Failed to load ad details.'),
        stackTrace,
      );
    }
  }

  int _beginLoad() {
    final generation = ++_loadGeneration;
    state = const AsyncValue.loading();
    return generation;
  }

  bool _isCurrentLoad(int generation) => generation == _loadGeneration;

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
    _setDraft(
      v == null ? _draft.copyWith(clearPrice: true) : _draft.copyWith(price: v),
    );
  }

  void setPriceUnit(String? v) {
    final clean = v?.trim() ?? '';
    _setDraft(
      clean.isEmpty
          ? _draft.copyWith(clearPriceUnit: true)
          : _draft.copyWith(priceUnit: clean),
    );
  }

  void clearPricing() {
    _setDraft(_draft.copyWith(clearPricing: true, scheduleOfferDates: false));
  }

  void setPriceType(String? v) {
    final type = (v == null || v.trim().isEmpty) ? null : v.trim();

    if (type == null) {
      _setDraft(
        _draft.copyWith(
          clearPriceType: true,
          scheduleOfferDates: false,
          clearAllOffer: true,
        ),
      );
      return;
    }

    if (type == 'Contact for price' || type == 'Free') {
      _setDraft(
        _draft.copyWith(
          priceType: type,
          clearPrice: true,
          clearPriceUnit: true,
          scheduleOfferDates: false,
          clearAllOffer: true,
        ),
      );
      return;
    }

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
          clearOfferPrice: true,
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

  void replaceImages(List<AdMediaImage> images) {
    if (images.isEmpty) {
      _setDraft(_draft.copyWith(images: []));
      return;
    }

    final normalized = <AdMediaImage>[];

    for (int i = 0; i < images.length; i++) {
      normalized.add(images[i].copyWith(isPrimary: i == 0));
    }

    _setDraft(_draft.copyWith(images: normalized));
  }

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
    if (mediaId.trim().isEmpty || _deletingMedia.contains(mediaId)) return;

    _deletingMedia.add(mediaId);
    final api = _ref.read(mediaUploadApiProvider);

    try {
      await api.deleteMedia(mediaId: mediaId);
    } on Object {
      return;
    } finally {
      _deletingMedia.remove(mediaId);
    }
  }

  Future<Either<Failure, AdMediaImage>> requestImageBackgroundRemoval(
    int index,
  ) async {
    if (index < 0 || index >= _draft.images.length) {
      return Either.left(const Failure('Invalid image index'));
    }

    final image = _draft.images[index];
    if (image.fileId.trim().isEmpty) {
      return Either.left(const Failure('Image has no media ID'));
    }

    final res = await _ref
        .read(mediaUploadApiProvider)
        .removeBackground(
          mediaId: image.fileId,
          resultPurpose: MediaUploadPurpose.adImage,
        );

    if (res.isLeft) {
      return Either.left(res.leftOrNull!);
    }

    final uploaded = res.rightOrNull!;
    return Either.right(AdMediaImage.fromUpload(uploaded));
  }

  Future<Either<Failure, AdMediaImage>> replaceImageAt(
    int index,
    File file,
  ) async {
    if (index < 0 || index >= _draft.images.length) {
      return Either.left(const Failure('Invalid image index'));
    }

    final old = _draft.images[index];
    final res = await _ref
        .read(mediaUploadCoordinatorProvider)
        .uploadFile(file: file, useCase: MediaUseCase.adImage);

    if (res.isLeft) {
      return Either.left(res.leftOrNull!);
    }

    final uploaded = AdMediaImage.fromUpload(res.rightOrNull!);
    final images = List<AdMediaImage>.from(_draft.images);
    final replacement = uploaded.copyWith(isPrimary: images[index].isPrimary);

    images[index] = replacement;
    replaceImages(images);

    if (old.fileId.trim().isNotEmpty) {
      unawaited(deleteMediaSilently(old.fileId));
    }

    return Either.right(replacement);
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
    _loadGeneration += 1;
    _setDraft(const AdDraft(source: DraftSource.create));
  }

  AdDraft get safeDraft => state.value ?? _draft;
}
