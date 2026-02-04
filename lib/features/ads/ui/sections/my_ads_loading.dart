import 'package:flutter/material.dart';

class MyAdsLoadingView extends StatelessWidget {
  const MyAdsLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}
