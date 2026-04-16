import 'package:flutter_riverpod/legacy.dart';

enum FeedTab { inspiration, following, saved }

enum FeedFilter { all, live, photos, shorts }

/// Current selected tab
final feedTabProvider = StateProvider<FeedTab>((ref) => FeedTab.inspiration);

/// Current selected filter
final feedFilterProvider = StateProvider<FeedFilter>((ref) => FeedFilter.all);
