import 'package:flutter_test/flutter_test.dart';
import 'package:govi_app/l10n/generated/app_localizations_en.dart';
import 'package:govi_app/l10n/generated/app_localizations_si.dart';
import 'package:govi_app/l10n/generated/app_localizations_ta.dart';

void main() {
  group('generated app localizations', () {
    test('provide navigation labels for supported app languages', () {
      expect(AppLocalizationsEn().navHome, 'Home');
      expect(AppLocalizationsSi().navMarket, 'මිල ගණන්');
      expect(AppLocalizationsTa().navProfile, 'சுயவிவரம்');
    });

    test('provide onboarding and profile strings', () {
      expect(AppLocalizationsEn().welcomeTitle, contains('GOVI'));
      expect(AppLocalizationsSi().profileLanguage, 'භාෂාව');
      expect(AppLocalizationsTa().locationRequired, isNotEmpty);
      expect(AppLocalizationsEn().onboardingEnterApp, contains('GOVI'));
      expect(AppLocalizationsEn().marketScreenTitle.toLowerCase(),
          contains('market'));
      expect(AppLocalizationsEn().homeQuickActions, 'Quick Actions');
    });
  });
}
