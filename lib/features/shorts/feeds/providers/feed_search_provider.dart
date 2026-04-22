import 'package:flutter_riverpod/legacy.dart';

/// Current search query

final feedSearchQueryProvider = StateProvider<String>((ref) => '');

/// Debounced query (important)

final debouncedSearchProvider = StateProvider<String>((ref) => '');
