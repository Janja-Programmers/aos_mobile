import 'package:africaonlinestores/features/ads/ads_report/models/report_reason.dart';

class ReportAdState {
  final List<ReportReason> reasons;
  final bool loading;
  final bool submitting;
  final String? errorMessage;

  const ReportAdState({
    this.reasons = const [],
    this.loading = false,
    this.submitting = false,
    this.errorMessage,
  });

  ReportAdState copyWith({
    List<ReportReason>? reasons,
    bool? loading,
    bool? submitting,
    String? errorMessage,
  }) {
    return ReportAdState(
      reasons: reasons ?? this.reasons,
      loading: loading ?? this.loading,
      submitting: submitting ?? this.submitting,
      errorMessage: errorMessage,
    );
  }
}
