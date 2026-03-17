import 'package:flutter/material.dart';

import 'package:africaonlinestores/features/ads/ads_form/presentation/screens/ad_form_screen.dart';
import 'package:africaonlinestores/shared/enums/ads.dart';

class EditAdScreen extends StatelessWidget {
  final String adId;

  const EditAdScreen({super.key, required this.adId});

  @override
  Widget build(BuildContext context) {
    return AdFormScreen(mode: AdFormMode.edit, adId: adId);
  }
}
