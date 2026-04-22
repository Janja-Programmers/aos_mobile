import 'package:africaonlinestores/features/shorts/shared/domain/entities/short.dart';
import 'package:africaonlinestores/features/shorts/shared/domain/policies/short_playability_policy.dart';
import 'package:africaonlinestores/features/shorts/shared/domain/policies/short_retry_policy.dart';
import 'package:africaonlinestores/features/shorts/shared/domain/policies/short_visibility_policy.dart';

class ShortAggregate {
  final Short short;

  const ShortAggregate(this.short);

  final _playability = const ShortPlayabilityPolicy();
  final _retry = const ShortRetryPolicy();
  final _visibility = const ShortVisibilityPolicy();

  bool get canPlay => _playability.canPlay(short);

  bool get canRetry => _retry.canRetry(short);

  bool get isVisible => _visibility.canShow(short);
}
