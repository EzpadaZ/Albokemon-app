import 'package:albokemon_app/l10n/app_localizations.dart';
import 'package:flutter/cupertino.dart';

import 'package:flutter/widgets.dart';

extension I18nX on BuildContext {
  AppLocalizations get i18n => AppLocalizations.of(this)!;
}