import 'package:africaonlinestores/features/live/domain/live_stream.dart';
import 'package:flutter/foundation.dart';

@immutable
class LiveListPage {
  const LiveListPage({
    required this.items,
    required this.nextCursor,
    required this.hasMore,
  });

  final List<LiveStream> items;
  final String? nextCursor;
  final bool hasMore;
}
