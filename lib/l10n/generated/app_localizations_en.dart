// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'GOVI';

  @override
  String get startupFirebaseError =>
      'GOVI could not connect to Firebase. Please check configuration and try again.';

  @override
  String get navHome => 'Home';

  @override
  String get navTrack => 'Track';

  @override
  String get navAi => 'AI';

  @override
  String get navMarket => 'Market';

  @override
  String get navLearn => 'Learn';

  @override
  String get navProfile => 'Profile';

  @override
  String get back => 'Back';

  @override
  String get next => 'Next';

  @override
  String get finishSetup => 'Finish setup';

  @override
  String get skip => 'Skip';

  @override
  String get welcomeTitle => 'Welcome to GOVI';

  @override
  String get welcomeSubtitle =>
      'Let us set up farming guidance in your language.';

  @override
  String get chooseLanguage => 'Choose your language';

  @override
  String get farmerTypeTitle => 'What best describes your farming?';

  @override
  String get farmerTypeSubtitle => 'This helps GOVI adjust guidance for you.';

  @override
  String get farmerFirstTime => 'First-time farmer';

  @override
  String get farmerSmallScale => 'Home garden / small scale';

  @override
  String get farmerCommercial => 'Commercial farmer';

  @override
  String get locationTitle => 'Where is your farm?';

  @override
  String get locationSubtitle =>
      'Location helps weather, soil, and AI guidance.';

  @override
  String get useGpsLocation => 'Use current GPS location';

  @override
  String get manualLocation => 'Or enter nearest town';

  @override
  String get landSize => 'Land size';

  @override
  String get cropTitle => 'Know what you are planting?';

  @override
  String get cropSubtitle => 'Optional. You can add crops later from Home.';

  @override
  String get currentCrop => 'Current crop';

  @override
  String get previousCrop => 'Previous crop';

  @override
  String get startDate => 'Start date';

  @override
  String get pickDate => 'Pick date';

  @override
  String get marketTitle => 'Choose markets to watch';

  @override
  String get marketSubtitle => 'Optional. Market prices can be changed later.';

  @override
  String get doneTitle => 'Your farm is ready';

  @override
  String get doneSubtitle => 'You can now learn, track crops, and ask GOVI AI.';

  @override
  String get locationRequired => 'Location is required to continue.';

  @override
  String get gpsFailed => 'Could not get GPS. Enter nearest town instead.';

  @override
  String get profileTitle => 'Profile';

  @override
  String get profileAccount => 'Account';

  @override
  String get profileManage => 'Manage Profile';

  @override
  String get profileNotifications => 'Notifications';

  @override
  String get profileLanguage => 'Language';

  @override
  String get profilePreferences => 'Preferences';

  @override
  String get profileAbout => 'About Us';

  @override
  String get profileDarkMode => 'Dark Mode';

  @override
  String get profileSupport => 'Support';

  @override
  String get profileHelp => 'Help Center';

  @override
  String get profileEmailEmpty => 'Email not set';

  @override
  String get profileLocationEmpty => 'Location not set';

  @override
  String get onboardingNameTitle => 'What should we call you?';

  @override
  String get onboardingNameSubtitle =>
      'Your name shows in the app and helps GOVI feel personal.';

  @override
  String get onboardingYourName => 'Your name';

  @override
  String get onboardingNameRequired => 'Please enter your name to continue.';

  @override
  String get onboardingPreferencesTitle => 'Your farming profile';

  @override
  String get onboardingPreferencesSubtitle =>
      'Optional. You can change this anytime in Profile.';

  @override
  String get onboardingJourneyTitle => 'Choose your journey';

  @override
  String get onboardingJourneySubtitle =>
      'Pick the path that matches you right now. You can always change crops later.';

  @override
  String get onboardingJourneyKnownTitle => 'I know what I\'m planting';

  @override
  String get onboardingJourneyKnownBody =>
      'Tell GOVI what you grow so tracking and reminders can start right away.';

  @override
  String get onboardingJourneyHelpTitle => 'Help me decide what to plant';

  @override
  String get onboardingJourneyHelpBody =>
      'Skip crop details for now — GOVI AI can recommend crops using your farm location and land size.';

  @override
  String get onboardingJourneyRequired =>
      'Please choose how you want to get started.';

  @override
  String get onboardingCompleteTitle => 'You\'re ready to grow';

  @override
  String get onboardingCompleteSubtitle =>
      'Your farm basics are saved. Tap below to enter GOVI.';

  @override
  String get onboardingEnterApp => 'Enter GOVI';

  @override
  String get landUnitAcres => 'Acres';

  @override
  String get landUnitPerches => 'Perches';

  @override
  String get languageRegionLk => 'Sri Lanka';

  @override
  String get languageRegionIntl => 'International';

  @override
  String get homeGreetingMorning => 'Good morning';

  @override
  String get homeGreetingAfternoon => 'Good afternoon';

  @override
  String get homeGreetingEvening => 'Good evening';

  @override
  String get homeQuickActions => 'Quick Actions';

  @override
  String get homeQuickActionAddCrop => 'Add Crop';

  @override
  String get homeQuickActionAskAi => 'Ask GOVI AI';

  @override
  String get homeQuickActionMarketPrices => 'Market Prices';

  @override
  String get homeQuickActionLearn => 'Learn';

  @override
  String get homeRecentActivities => 'Recent Activities';

  @override
  String get homeNoRecentActivityYet => 'No recent activity yet.';

  @override
  String get homeEmptyCropTitle => 'Start tracking your first crop';

  @override
  String get homeEmptyCropDescription =>
      'Add a crop when you are ready. GOVI will create a harvest progress tracker and timeline tasks.';

  @override
  String get homeEmptyAddCropCta => 'Add Crop';

  @override
  String homeHarvestOn(String date) {
    return 'Harvest $date';
  }

  @override
  String get homeAllTasksDone => 'All tasks done';

  @override
  String homeNextTask(String taskTitle) {
    return 'Next: $taskTitle';
  }

  @override
  String homeRelativeDaysAgo(int count) {
    return '$count days ago';
  }

  @override
  String homeRelativeHoursAgo(int count) {
    return '$count hours ago';
  }

  @override
  String homeRelativeMinutesAgo(int count) {
    return '$count minutes ago';
  }

  @override
  String get homeJustNow => 'Just now';

  @override
  String get marketScreenTitle => 'Market prices';

  @override
  String get marketRefreshTooltip => 'Refresh';

  @override
  String get marketSearchHint => 'Search vegetables…';

  @override
  String marketHeaderForMarket(String marketName) {
    return '$marketName market';
  }

  @override
  String get marketStatusSyncing => 'Syncing…';

  @override
  String get marketStatusOfflineNoCache => 'Offline – no cache';

  @override
  String get marketStatusOfflineCache => 'Offline cache';

  @override
  String get marketStatusNoCachedData => 'No cached data';

  @override
  String get marketStatusCachedStale => 'Cached – stale';

  @override
  String get marketStatusCachedFresh => 'Cached – fresh';

  @override
  String get marketEmptyNoSearchResults => 'No matching search results.';

  @override
  String get marketEmptyNoDataYet => 'No price data yet.';

  @override
  String get marketSyncPrices => 'Sync prices';

  @override
  String marketPriceRupee(String price) {
    return 'Rs. $price';
  }

  @override
  String marketUpdatedOn(String date) {
    return 'Updated $date';
  }

  @override
  String marketUnitSlash(String unit) {
    return '/$unit';
  }

  @override
  String get marketCropInitialFallback => '?';
}
