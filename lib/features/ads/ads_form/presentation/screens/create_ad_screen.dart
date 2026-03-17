import 'package:flutter/material.dart';

import 'package:africaonlinestores/features/ads/ads_form/presentation/screens/ad_form_screen.dart';
import 'package:africaonlinestores/shared/enums/ads.dart';

class CreateAdScreen extends StatelessWidget {
  const CreateAdScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AdFormScreen(mode: AdFormMode.create);
  }
}
