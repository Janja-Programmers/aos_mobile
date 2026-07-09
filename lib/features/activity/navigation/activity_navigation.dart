import 'package:africaonlinestores/core/routing/helpers/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ActivityNavigation {
  const ActivityNavigation._();

  static void toActivityCenter(BuildContext context) {
    context.pushNamed(AppRoutes.nActivityCenter);
  }
}
