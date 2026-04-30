import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../screens/profile/theme_provider.dart';
import 'generated/app_localizations.dart';
import 'generated/app_localizations_en.dart';
import 'generated/app_localizations_si.dart';
import 'generated/app_localizations_ta.dart';

extension GoviLocalizationsX on BuildContext {
  AppLocalizations get l10n {
    final languageCode = watch<ThemeProvider>().languageCode;
    return switch (languageCode) {
      'si' => AppLocalizationsSi(),
      'ta' => AppLocalizationsTa(),
      'en' => AppLocalizationsEn(),
      _ => AppLocalizationsEn(),
    };
  }

  AppLocalizations get readL10n {
    final languageCode = read<ThemeProvider>().languageCode;
    return switch (languageCode) {
      'si' => AppLocalizationsSi(),
      'ta' => AppLocalizationsTa(),
      'en' => AppLocalizationsEn(),
      _ => AppLocalizationsEn(),
    };
  }
}
