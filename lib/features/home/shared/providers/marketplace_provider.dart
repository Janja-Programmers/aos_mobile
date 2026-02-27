import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:africaonlinestores/features/home/data/market_context_controller.dart';
import 'package:africaonlinestores/features/home/domain/market_place.dart';

final marketContextProvider =
    AsyncNotifierProvider<MarketContextController, MarketContext>(
      MarketContextController.new,
    );
