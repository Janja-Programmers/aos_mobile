import 'package:flutter/widgets.dart';

import 'package:africaonlinestores/l10n/gen/app_localizations.dart';

extension L10n on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this)!;
}
