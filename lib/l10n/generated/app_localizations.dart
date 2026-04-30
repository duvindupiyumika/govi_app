import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_si.dart';
import 'app_localizations_ta.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('si'),
    Locale('ta'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'GOVI'**
  String get appTitle;

  /// No description provided for @startupFirebaseError.
  ///
  /// In en, this message translates to:
  /// **'GOVI could not connect to Firebase. Please check configuration and try again.'**
  String get startupFirebaseError;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navTrack.
  ///
  /// In en, this message translates to:
  /// **'Track'**
  String get navTrack;

  /// No description provided for @navAi.
  ///
  /// In en, this message translates to:
  /// **'AI'**
  String get navAi;

  /// No description provided for @navMarket.
  ///
  /// In en, this message translates to:
  /// **'Market'**
  String get navMarket;

  /// No description provided for @navLearn.
  ///
  /// In en, this message translates to:
  /// **'Learn'**
  String get navLearn;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @finishSetup.
  ///
  /// In en, this message translates to:
  /// **'Finish setup'**
  String get finishSetup;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @welcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to GOVI'**
  String get welcomeTitle;

  /// No description provided for @welcomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Let us set up farming guidance in your language.'**
  String get welcomeSubtitle;

  /// No description provided for @chooseLanguage.
  ///
  /// In en, this message translates to:
  /// **'Choose your language'**
  String get chooseLanguage;

  /// No description provided for @farmerTypeTitle.
  ///
  /// In en, this message translates to:
  /// **'What best describes your farming?'**
  String get farmerTypeTitle;

  /// No description provided for @farmerTypeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'This helps GOVI adjust guidance for you.'**
  String get farmerTypeSubtitle;

  /// No description provided for @farmerFirstTime.
  ///
  /// In en, this message translates to:
  /// **'First-time farmer'**
  String get farmerFirstTime;

  /// No description provided for @farmerSmallScale.
  ///
  /// In en, this message translates to:
  /// **'Home garden / small scale'**
  String get farmerSmallScale;

  /// No description provided for @farmerCommercial.
  ///
  /// In en, this message translates to:
  /// **'Commercial farmer'**
  String get farmerCommercial;

  /// No description provided for @locationTitle.
  ///
  /// In en, this message translates to:
  /// **'Where is your farm?'**
  String get locationTitle;

  /// No description provided for @locationSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Location helps weather, soil, and AI guidance.'**
  String get locationSubtitle;

  /// No description provided for @useGpsLocation.
  ///
  /// In en, this message translates to:
  /// **'Use current GPS location'**
  String get useGpsLocation;

  /// No description provided for @manualLocation.
  ///
  /// In en, this message translates to:
  /// **'Or enter nearest town'**
  String get manualLocation;

  /// No description provided for @landSize.
  ///
  /// In en, this message translates to:
  /// **'Land size'**
  String get landSize;

  /// No description provided for @cropTitle.
  ///
  /// In en, this message translates to:
  /// **'Know what you are planting?'**
  String get cropTitle;

  /// No description provided for @cropSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Optional. You can add crops later from Home.'**
  String get cropSubtitle;

  /// No description provided for @currentCrop.
  ///
  /// In en, this message translates to:
  /// **'Current crop'**
  String get currentCrop;

  /// No description provided for @previousCrop.
  ///
  /// In en, this message translates to:
  /// **'Previous crop'**
  String get previousCrop;

  /// No description provided for @startDate.
  ///
  /// In en, this message translates to:
  /// **'Start date'**
  String get startDate;

  /// No description provided for @pickDate.
  ///
  /// In en, this message translates to:
  /// **'Pick date'**
  String get pickDate;

  /// No description provided for @marketTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose markets to watch'**
  String get marketTitle;

  /// No description provided for @marketSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Optional. Market prices can be changed later.'**
  String get marketSubtitle;

  /// No description provided for @doneTitle.
  ///
  /// In en, this message translates to:
  /// **'Your farm is ready'**
  String get doneTitle;

  /// No description provided for @doneSubtitle.
  ///
  /// In en, this message translates to:
  /// **'You can now learn, track crops, and ask GOVI AI.'**
  String get doneSubtitle;

  /// No description provided for @locationRequired.
  ///
  /// In en, this message translates to:
  /// **'Location is required to continue.'**
  String get locationRequired;

  /// No description provided for @gpsFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not get GPS. Enter nearest town instead.'**
  String get gpsFailed;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// No description provided for @profileAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get profileAccount;

  /// No description provided for @profileManage.
  ///
  /// In en, this message translates to:
  /// **'Manage Profile'**
  String get profileManage;

  /// No description provided for @profileNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get profileNotifications;

  /// No description provided for @profileLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get profileLanguage;

  /// No description provided for @profilePreferences.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get profilePreferences;

  /// No description provided for @profileAbout.
  ///
  /// In en, this message translates to:
  /// **'About Us'**
  String get profileAbout;

  /// No description provided for @profileDarkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get profileDarkMode;

  /// No description provided for @profileSupport.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get profileSupport;

  /// No description provided for @profileHelp.
  ///
  /// In en, this message translates to:
  /// **'Help Center'**
  String get profileHelp;

  /// No description provided for @profileEmailEmpty.
  ///
  /// In en, this message translates to:
  /// **'Email not set'**
  String get profileEmailEmpty;

  /// No description provided for @profileLocationEmpty.
  ///
  /// In en, this message translates to:
  /// **'Location not set'**
  String get profileLocationEmpty;

  /// No description provided for @onboardingNameTitle.
  ///
  /// In en, this message translates to:
  /// **'What should we call you?'**
  String get onboardingNameTitle;

  /// No description provided for @onboardingNameSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your name shows in the app and helps GOVI feel personal.'**
  String get onboardingNameSubtitle;

  /// No description provided for @onboardingYourName.
  ///
  /// In en, this message translates to:
  /// **'Your name'**
  String get onboardingYourName;

  /// No description provided for @onboardingNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your name to continue.'**
  String get onboardingNameRequired;

  /// No description provided for @onboardingPreferencesTitle.
  ///
  /// In en, this message translates to:
  /// **'Your farming profile'**
  String get onboardingPreferencesTitle;

  /// No description provided for @onboardingPreferencesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Optional. You can change this anytime in Profile.'**
  String get onboardingPreferencesSubtitle;

  /// No description provided for @onboardingJourneyTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose your journey'**
  String get onboardingJourneyTitle;

  /// No description provided for @onboardingJourneySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Pick the path that matches you right now. You can always change crops later.'**
  String get onboardingJourneySubtitle;

  /// No description provided for @onboardingJourneyKnownTitle.
  ///
  /// In en, this message translates to:
  /// **'I know what I\'m planting'**
  String get onboardingJourneyKnownTitle;

  /// No description provided for @onboardingJourneyKnownBody.
  ///
  /// In en, this message translates to:
  /// **'Tell GOVI what you grow so tracking and reminders can start right away.'**
  String get onboardingJourneyKnownBody;

  /// No description provided for @onboardingJourneyHelpTitle.
  ///
  /// In en, this message translates to:
  /// **'Help me decide what to plant'**
  String get onboardingJourneyHelpTitle;

  /// No description provided for @onboardingJourneyHelpBody.
  ///
  /// In en, this message translates to:
  /// **'Skip crop details for now — GOVI AI can recommend crops using your farm location and land size.'**
  String get onboardingJourneyHelpBody;

  /// No description provided for @onboardingJourneyRequired.
  ///
  /// In en, this message translates to:
  /// **'Please choose how you want to get started.'**
  String get onboardingJourneyRequired;

  /// No description provided for @onboardingCompleteTitle.
  ///
  /// In en, this message translates to:
  /// **'You\'re ready to grow'**
  String get onboardingCompleteTitle;

  /// No description provided for @onboardingCompleteSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your farm basics are saved. Tap below to enter GOVI.'**
  String get onboardingCompleteSubtitle;

  /// No description provided for @onboardingEnterApp.
  ///
  /// In en, this message translates to:
  /// **'Enter GOVI'**
  String get onboardingEnterApp;

  /// No description provided for @landUnitAcres.
  ///
  /// In en, this message translates to:
  /// **'Acres'**
  String get landUnitAcres;

  /// No description provided for @landUnitPerches.
  ///
  /// In en, this message translates to:
  /// **'Perches'**
  String get landUnitPerches;

  /// No description provided for @languageRegionLk.
  ///
  /// In en, this message translates to:
  /// **'Sri Lanka'**
  String get languageRegionLk;

  /// No description provided for @languageRegionIntl.
  ///
  /// In en, this message translates to:
  /// **'International'**
  String get languageRegionIntl;

  /// No description provided for @homeGreetingMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning'**
  String get homeGreetingMorning;

  /// No description provided for @homeGreetingAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon'**
  String get homeGreetingAfternoon;

  /// No description provided for @homeGreetingEvening.
  ///
  /// In en, this message translates to:
  /// **'Good evening'**
  String get homeGreetingEvening;

  /// No description provided for @homeQuickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get homeQuickActions;

  /// No description provided for @homeQuickActionAddCrop.
  ///
  /// In en, this message translates to:
  /// **'Add Crop'**
  String get homeQuickActionAddCrop;

  /// No description provided for @homeQuickActionAskAi.
  ///
  /// In en, this message translates to:
  /// **'Ask GOVI AI'**
  String get homeQuickActionAskAi;

  /// No description provided for @homeQuickActionMarketPrices.
  ///
  /// In en, this message translates to:
  /// **'Market Prices'**
  String get homeQuickActionMarketPrices;

  /// No description provided for @homeQuickActionLearn.
  ///
  /// In en, this message translates to:
  /// **'Learn'**
  String get homeQuickActionLearn;

  /// No description provided for @homeRecentActivities.
  ///
  /// In en, this message translates to:
  /// **'Recent Activities'**
  String get homeRecentActivities;

  /// No description provided for @homeNoRecentActivityYet.
  ///
  /// In en, this message translates to:
  /// **'No recent activity yet.'**
  String get homeNoRecentActivityYet;

  /// No description provided for @homeEmptyCropTitle.
  ///
  /// In en, this message translates to:
  /// **'Start tracking your first crop'**
  String get homeEmptyCropTitle;

  /// No description provided for @homeEmptyCropDescription.
  ///
  /// In en, this message translates to:
  /// **'Add a crop when you are ready. GOVI will create a harvest progress tracker and timeline tasks.'**
  String get homeEmptyCropDescription;

  /// No description provided for @homeEmptyAddCropCta.
  ///
  /// In en, this message translates to:
  /// **'Add Crop'**
  String get homeEmptyAddCropCta;

  /// No description provided for @homeHarvestOn.
  ///
  /// In en, this message translates to:
  /// **'Harvest {date}'**
  String homeHarvestOn(String date);

  /// No description provided for @homeAllTasksDone.
  ///
  /// In en, this message translates to:
  /// **'All tasks done'**
  String get homeAllTasksDone;

  /// No description provided for @homeNextTask.
  ///
  /// In en, this message translates to:
  /// **'Next: {taskTitle}'**
  String homeNextTask(String taskTitle);

  /// No description provided for @homeRelativeDaysAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} days ago'**
  String homeRelativeDaysAgo(int count);

  /// No description provided for @homeRelativeHoursAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} hours ago'**
  String homeRelativeHoursAgo(int count);

  /// No description provided for @homeRelativeMinutesAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} minutes ago'**
  String homeRelativeMinutesAgo(int count);

  /// No description provided for @homeJustNow.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get homeJustNow;

  /// No description provided for @marketScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Market prices'**
  String get marketScreenTitle;

  /// No description provided for @marketRefreshTooltip.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get marketRefreshTooltip;

  /// No description provided for @marketSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search vegetables…'**
  String get marketSearchHint;

  /// No description provided for @marketHeaderForMarket.
  ///
  /// In en, this message translates to:
  /// **'{marketName} market'**
  String marketHeaderForMarket(String marketName);

  /// No description provided for @marketStatusSyncing.
  ///
  /// In en, this message translates to:
  /// **'Syncing…'**
  String get marketStatusSyncing;

  /// No description provided for @marketStatusOfflineNoCache.
  ///
  /// In en, this message translates to:
  /// **'Offline – no cache'**
  String get marketStatusOfflineNoCache;

  /// No description provided for @marketStatusOfflineCache.
  ///
  /// In en, this message translates to:
  /// **'Offline cache'**
  String get marketStatusOfflineCache;

  /// No description provided for @marketStatusNoCachedData.
  ///
  /// In en, this message translates to:
  /// **'No cached data'**
  String get marketStatusNoCachedData;

  /// No description provided for @marketStatusCachedStale.
  ///
  /// In en, this message translates to:
  /// **'Cached – stale'**
  String get marketStatusCachedStale;

  /// No description provided for @marketStatusCachedFresh.
  ///
  /// In en, this message translates to:
  /// **'Cached – fresh'**
  String get marketStatusCachedFresh;

  /// No description provided for @marketEmptyNoSearchResults.
  ///
  /// In en, this message translates to:
  /// **'No matching search results.'**
  String get marketEmptyNoSearchResults;

  /// No description provided for @marketEmptyNoDataYet.
  ///
  /// In en, this message translates to:
  /// **'No price data yet.'**
  String get marketEmptyNoDataYet;

  /// No description provided for @marketSyncPrices.
  ///
  /// In en, this message translates to:
  /// **'Sync prices'**
  String get marketSyncPrices;

  /// No description provided for @marketPriceRupee.
  ///
  /// In en, this message translates to:
  /// **'Rs. {price}'**
  String marketPriceRupee(String price);

  /// No description provided for @marketUpdatedOn.
  ///
  /// In en, this message translates to:
  /// **'Updated {date}'**
  String marketUpdatedOn(String date);

  /// No description provided for @marketUnitSlash.
  ///
  /// In en, this message translates to:
  /// **'/{unit}'**
  String marketUnitSlash(String unit);

  /// No description provided for @marketCropInitialFallback.
  ///
  /// In en, this message translates to:
  /// **'?'**
  String get marketCropInitialFallback;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'si', 'ta'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'si':
      return AppLocalizationsSi();
    case 'ta':
      return AppLocalizationsTa();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
