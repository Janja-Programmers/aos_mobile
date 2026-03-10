import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import 'package:africaonlinestores/core/api/failure.dart';
import 'package:africaonlinestores/core/utils/either.dart';

import 'package:africaonlinestores/features/ads/domain/ad_draft.dart';
import 'package:africaonlinestores/features/ads/shared/providers/ads_api_provider.dart';
import 'package:africaonlinestores/shared/utils/enums.dart';

final adDraftControllerProvider =
    StateNotifierProvider<AdDraftController, AsyncValue<AdDraft>>(
      (ref) => AdDraftController(ref),
    );

class AdDraftController extends StateNotifier<AsyncValue<AdDraft>> {
  AdDraftController(this._ref)
    : _draft = const AdDraft(source: DraftSource.newAd),
      super(const AsyncValue.data(AdDraft(source: DraftSource.newAd)));

  final Ref _ref;
  AdDraft _draft;

  AdDraft get draft => _draft;
  final _deletingFiles = <String>{};

  // ================= SETUP =================

  void createNew() {
    _draft = const AdDraft(source: DraftSource.newAd);
    state = AsyncValue.data(_draft);
  }

  Future<void> loadFromDraft(String draftId) async {
    final api = _ref.read(adsApiProvider);

    state = const AsyncValue.loading();

    final res = await api.getAdDraft(draftId: draftId);

    if (res.isLeft) {
      state = AsyncValue.error(res.leftOrNull!, StackTrace.current);
      return;
    }

    final draft = AdDraft.fromDraft(res.rightOrNull!);

    _draft = draft.copyWith(
      source: DraftSource.adDraft,
      draftId: draftId,
      adId: null,
    );

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

    _draft = draft.copyWith(
      source: DraftSource.existingAd,
      adId: adId,
      draftId: null,
    );

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
        attributes: const <String, dynamic>{},
        priceType: null,
        price: null,
        priceUnit: null,
      ),
    );
  }

  void setDescription(String v) {
    _draft = _draft.copyWith(description: v);
    state = AsyncValue.data(_draft);
  }

  // ================= DETAILS =================

  void setAttribute(String key, dynamic value) {
    final next = Map<String, dynamic>.from(_draft.attributes);

    if (value == null || (value is String && value.trim().isEmpty)) {
      next.remove(key);
    } else {
      next[key] = value;
    }

    _setDraft(_draft.copyWith(attributes: next));
  }

  // ================= PRICING =================

  void setPriceType(String? v) {
    _setDraft(
      _draft.copyWith(priceType: (v == null || v.trim().isEmpty) ? null : v),
    );
  }

  void setCurrency(String? v) {
    _setDraft(
      _draft.copyWith(currency: (v == null || v.trim().isEmpty) ? null : v),
    );
  }

  void setPrice(double? v) {
    _setDraft(_draft.copyWith(price: v));
  }

  void setPriceUnit(String? v) {
    _setDraft(
      _draft.copyWith(priceUnit: (v == null || v.trim().isEmpty) ? null : v),
    );
  }

  void clearPricing() {
    _setDraft(_draft.copyWith(priceType: null, price: null, priceUnit: null));
  }

  void setOfferPrice(double? value) {
    _setDraft(_draft.copyWith(offerPrice: value));
  }

  void setOfferStart(DateTime? value) {
    _setDraft(_draft.copyWith(offerStart: value));
  }

  void setOfferEnd(DateTime? value) {
    _setDraft(_draft.copyWith(offerEnd: value));
  }

  // ================= MEDIA =================

  /// Replace entire image list safely
  void replaceImages(List<AdMediaImage> images) {
    if (images.isEmpty) {
      _draft = _draft.copyWith(images: []);
      state = AsyncValue.data(_draft);
      return;
    }

    // Ensure first image is primary
    final normalized = <AdMediaImage>[];

    for (int i = 0; i < images.length; i++) {
      normalized.add(images[i].copyWith(isPrimary: i == 0));
    }

    _draft = _draft.copyWith(images: normalized);
    state = AsyncValue.data(_draft);
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
      unawaited(deleteFileSilently(image.fileId));
    }
  }

  Future<void> deleteFileSilently(String fileId) async {
    if (_deletingFiles.contains(fileId)) return;

    _deletingFiles.add(fileId);

    final api = _ref.read(adsApiProvider);

    final res = await api.deleteFile(fileId: fileId);

    if (res.isLeft) {}

    _deletingFiles.remove(fileId);
  }

  // ----------------- EDIT IMAGE -----------------
  Future<void> replaceImageAt(int index, File file) async {
    final api = _ref.read(adsApiProvider);

    final old = _draft.images[index];

    final res = await api.uploadMedia(file: file);
    if (res.isLeft) return;

    final uploaded = AdMediaImage.fromUpload(res.rightOrNull!);

    final images = List<AdMediaImage>.from(_draft.images);

    final isPrimary = images[index].isPrimary;

    images[index] = uploaded.copyWith(isPrimary: isPrimary);

    replaceImages(images);

    if (old.fileId.isNotEmpty) {
      unawaited(deleteFileSilently(old.fileId));
    }
  }

  Future<Either<Failure, String>> uploadAndAddImage(File file) async {
    final api = _ref.read(adsApiProvider);
    final res = await api.uploadMedia(file: file);

    if (res.isLeft) return Either.left(res.leftOrNull!);

    final media = AdMediaImage.fromUpload(res.rightOrNull!);

    final next = List<AdMediaImage>.from(_draft.images);

    next.add(media.copyWith(isPrimary: next.isEmpty));

    replaceImages(next);

    return Either.right(media.url);
  }

  Future<Either<Failure, String>> uploadAndSetVideo(File file) async {
    final api = _ref.read(adsApiProvider);
    final res = await api.uploadMedia(file: file);

    if (res.isLeft) return Either.left(res.leftOrNull!);

    final media = res.rightOrNull!;

    final url = media['url']!;
    final fileId = media['fileId']!;

    _setDraft(_draft.copyWith(videoUrl: url, videoFileId: fileId));

    return Either.right(url);
  }

  Future<void> clearVideo() async {
    final fileId = _draft.videoFileId;

    _setDraft(_draft.copyWith(videoUrl: null, videoFileId: null));

    if (fileId != null && fileId.isNotEmpty) {
      unawaited(deleteFileSilently(fileId));
    }
  }

  // ================= PRICING =================

  void setFreeConsultation(bool v) {
    state = state.whenData((d) => d.copyWith(freeConsultation: v));
  }

  void setRequiresDeposit(bool v) {
    state = state.whenData((d) => d.copyWith(requiresDeposit: v));
  }

  // ================= RESET =================
  void _setDraft(AdDraft next) {
    _draft = next;
    state = AsyncValue.data(next);
  }

  void reset() {
    _setDraft(const AdDraft(source: DraftSource.newAd));
  }
}
