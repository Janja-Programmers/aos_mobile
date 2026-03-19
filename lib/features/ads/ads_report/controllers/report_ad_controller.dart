import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import 'package:africaonlinestores/core/api/failure.dart';
import 'package:africaonlinestores/core/utils/either.dart';

import 'package:africaonlinestores/features/ads/ads_report/controllers/report_ad_state.dart';
import 'package:africaonlinestores/features/ads/ads_report/data/report_ad_api_provider.dart';

final reportAdControllerProvider =
    StateNotifierProvider<ReportAdController, ReportAdState>(
      (ref) => ReportAdController(ref),
    );

class ReportAdController extends StateNotifier<ReportAdState> {
  ReportAdController(this.ref) : super(const ReportAdState());

  final Ref ref;

  /// 🔹 Load reasons
  Future<void> loadReasons() async {
    state = state.copyWith(loading: true, errorMessage: null);

    final res = await ref.read(reportAdApiProvider).listReportReasons();

    res.fold(
      (f) => state = state.copyWith(loading: false, errorMessage: f.message),
      (data) => state = state.copyWith(
        loading: false,
        reasons: data,
        errorMessage: null,
      ),
    );
  }

  /// 🔹 Submit report
  Future<Either<Failure, void>> submit({
    required String adId,
    required String reason,
    required String details,
  }) async {
    if (state.submitting) {
      return const Right(null);
    }

    state = state.copyWith(submitting: true);

    final res = await ref
        .read(reportAdApiProvider)
        .reportAd(adId: adId, reason: reason, details: details);

    state = state.copyWith(submitting: false);
    return res;
  }
}
