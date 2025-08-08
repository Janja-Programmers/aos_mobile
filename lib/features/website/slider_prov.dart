import 'package:flutter/material.dart';

import '/core/constants/const.dart';
import '/core/utils/api_client.dart';

class SliderProv with ChangeNotifier {
  final APIClient _apiClient;
  bool isLoading = false;
  String? error;
  List<String> images = [];
  final slideshowEndpoint = ApiRoutes.slideshowEndpoint;

  SliderProv(this._apiClient);

  Future<void> loadSlider() async {
    isLoading = true;
    error = null;
    images = [];
    notifyListeners();

    try {
      final res = await _apiClient.client.get(
        slideshowEndpoint,
        queryParameters: {'name': 'Slideshow'},
      );

      final message = res.data['message'];
      if (message != null && message['items'] is List) {
        final data = message['items'] as List;
        images =
            data
                .map((e) => e['image'] as String?)
                .where((path) => path != null && path.trim().isNotEmpty)
                .cast<String>()
                .toList();
      } else {
        error = "Invalid slideshow data format";
      }
    } catch (e) {
      error = e.toString();
    }

    isLoading = false;
    notifyListeners();
  }
}
