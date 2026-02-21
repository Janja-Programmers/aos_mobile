import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import 'package:africaonlinestores/core/providers.dart';
import 'package:africaonlinestores/core/api/failure.dart';
import 'package:africaonlinestores/core/utils/either.dart';

import 'package:africaonlinestores/features/ads/domain/ad_draft.dart';

class AdDraftController extends StateNotifier<AsyncValue<AdDraft>> {
  AdDraftController(this._ref) : super(const AsyncValue.data(AdDraft())) {
    _draft = const AdDraft();
  }

  final Ref _ref;
  late AdDraft _draft;

  AdDraft get draft => _draft;

  // ================= BASIC =================

  void updateTitle(String v) {
    _draft = _draft.copyWith(title: v);
    state = AsyncValue.data(_draft);
  }

  void setLocation({required String id, required String label}) {
    _draft = _draft.copyWith(locationId: id, locationLabel: label);
    state = AsyncValue.data(_draft);
  }

  void setCountry(String? id) {
    _draft = _draft.copyWith(countryId: id);
    state = AsyncValue.data(_draft);
  }

  void setCategory({required String id, required String label}) {
    _draft = _draft.copyWith(
      categoryId: id,
      categoryLabel: label,
      attributes: const <String, dynamic>{},
      priceType: null,
      price: null,
      priceUnit: null,
    );
    state = AsyncValue.data(_draft);
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

    _draft = _draft.copyWith(attributes: next);
    state = AsyncValue.data(_draft);
  }

  // ================= PRICING =================

  void setPriceType(String? v) {
    _draft = _draft.copyWith(
      priceType: (v == null || v.trim().isEmpty) ? null : v,
    );
    state = AsyncValue.data(_draft);
  }

  void setCurrency(String? v) {
    _draft = _draft.copyWith(
      currency: (v == null || v.trim().isEmpty) ? null : v,
    );
    state = AsyncValue.data(_draft);
  }

  void setPrice(double? v) {
    _draft = _draft.copyWith(price: v);
    state = AsyncValue.data(_draft);
  }

  void setPriceUnit(String? v) {
    _draft = _draft.copyWith(
      priceUnit: (v == null || v.trim().isEmpty) ? null : v,
    );
    state = AsyncValue.data(_draft);
  }

  void clearPricing() {
    _draft = _draft.copyWith(priceType: null, price: null, priceUnit: null);
    state = AsyncValue.data(_draft);
  }

  void setOfferPrice(double? value) {
    state = state.whenData((draft) {
      return draft.copyWith(offerPrice: value);
    });
  }

  void setOfferStart(DateTime? value) {
    state = state.whenData((draft) {
      return draft.copyWith(offerStart: value);
    });
  }

  void setOfferEnd(DateTime? value) {
    state = state.whenData((draft) {
      return draft.copyWith(offerEnd: value);
    });
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

  void removeImage(int index) {
    if (index < 0 || index >= _draft.images.length) return;

    final next = List<AdMediaImage>.from(_draft.images)..removeAt(index);

    replaceImages(next);
  }

  // ----------------- EDIT IMAGE -----------------
  Future<void> replaceImageAt(int index, File file) async {
    final api = _ref.read(adsApiProvider);

    final res = await api.uploadMedia(file: file);
    if (res.isLeft) return;

    final url = res.rightOrNull!;
    final images = List<AdMediaImage>.from(_draft.images);

    final isPrimary = images[index].isPrimary;

    images[index] = AdMediaImage(url: url, isPrimary: isPrimary);

    replaceImages(images);
  }

  Future<Either<Failure, String>> uploadAndAddImage(File file) async {
    final api = _ref.read(adsApiProvider);
    final res = await api.uploadMedia(file: file);

    if (res.isLeft) return Either.left(res.leftOrNull!);

    final url = res.rightOrNull!;

    final next = List<AdMediaImage>.from(_draft.images);

    next.add(AdMediaImage(url: url, isPrimary: next.isEmpty));

    replaceImages(next);

    return Either.right(url);
  }

  Future<Either<Failure, String>> uploadAndSetVideo(File file) async {
    final api = _ref.read(adsApiProvider);
    final res = await api.uploadMedia(file: file);

    if (res.isLeft) return Either.left(res.leftOrNull!);

    final url = res.rightOrNull!;

    _draft = _draft.copyWith(videoUrl: url);
    state = AsyncValue.data(_draft);

    return Either.right(url);
  }

  void clearVideo() {
    _draft = _draft.copyWith(videoUrl: null);
    state = AsyncValue.data(_draft);
  }

  // ================= RESET =================

  void reset() {
    _draft = const AdDraft();
    state = AsyncValue.data(_draft);
  }
}

final adDraftControllerProvider =
    StateNotifierProvider<AdDraftController, AsyncValue<AdDraft>>(
      (ref) => AdDraftController(ref),
    );
