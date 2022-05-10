import 'package:flutter/material.dart' show BuildContext;
import 'package:flutter_gen/gen_l10n/app_localizations.dart'
    show AppLocalizations;

extension Localization on BuildContext {
  // * Haetaan contextin lokaalisaatio jota käytetään oikean kielen käyttämiseen applikaatiossa
  AppLocalizations get loc => AppLocalizations.of(this)!;
}
