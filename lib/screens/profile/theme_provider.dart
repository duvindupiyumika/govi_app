import 'package:flutter/material.dart';

import '../../features/profile/data/profile_repository.dart';
import '../../features/profile/domain/local_profile.dart';
import '../../features/settings/data/app_settings_repository.dart';
import '../../features/settings/domain/app_settings.dart';

class ThemeProvider extends ChangeNotifier {
  final AppSettingsRepository _settingsRepository;
  final ProfileRepository _profileRepository;

  late AppSettings _settings;
  late LocalProfile _profile;

  ThemeProvider({
    AppSettingsRepository? settingsRepository,
    ProfileRepository? profileRepository,
  }) : _settingsRepository = settingsRepository ?? AppSettingsRepository(),
       _profileRepository = profileRepository ?? ProfileRepository() {
    _settings = _loadSettings();
    _profile = _loadProfile();
  }

  ThemeMode get themeMode =>
      _settings.themeMode == 'dark' ? ThemeMode.dark : ThemeMode.light;

  bool get isDarkMode => themeMode == ThemeMode.dark;
  String get languageCode => _settings.languageCode;
  Locale get locale =>
      languageCode == 'ta' ? const Locale('ta') : const Locale('en');
  bool get onboardingComplete => _settings.onboardingComplete;
  LocalProfile get profile => _profile;

  String get languageName {
    switch (languageCode) {
      case 'en':
        return 'English';
      case 'ta':
        return 'தமிழ்';
      case 'si':
      default:
        return 'සිංහල';
    }
  }

  void toggleTheme(bool isOn) {
    setThemeMode(isOn ? ThemeMode.dark : ThemeMode.light);
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    final value = mode == ThemeMode.dark ? 'dark' : 'light';
    _settings = _settings.copyWith(themeMode: value, updatedAt: DateTime.now());
    _profile = _profile.copyWith(themeMode: value, updatedAt: DateTime.now());
    await _settingsRepository.save(_settings.id, _settings, queueSync: false);
    await _profileRepository.save(_profile.id, _profile, queueSync: false);
    notifyListeners();
  }

  Future<void> setLanguage(String languageCode) async {
    _settings = _settings.copyWith(
      languageCode: languageCode,
      updatedAt: DateTime.now(),
    );
    _profile = _profile.copyWith(
      languageCode: languageCode,
      updatedAt: DateTime.now(),
    );
    await _settingsRepository.save(_settings.id, _settings, queueSync: false);
    await _profileRepository.save(_profile.id, _profile, queueSync: false);
    notifyListeners();
  }

  Future<void> setOnboardingComplete(bool isComplete) async {
    _settings = _settings.copyWith(
      onboardingComplete: isComplete,
      updatedAt: DateTime.now(),
    );
    await _settingsRepository.save(_settings.id, _settings, queueSync: false);
    notifyListeners();
  }

  Future<void> updateProfile({
    required String name,
    String? email,
    String? phoneNumber,
    String? location,
    double? landSize,
    String? farmerType,
    String? profileImagePath,
  }) async {
    _profile = LocalProfile(
      id: _profile.id,
      name: name,
      email: email,
      phoneNumber: phoneNumber,
      location: location,
      landSize: landSize,
      farmerType: farmerType ?? _profile.farmerType,
      languageCode: languageCode,
      themeMode: _settings.themeMode,
      profileImagePath: profileImagePath,
      updatedAt: DateTime.now(),
    );
    await _profileRepository.save(_profile.id, _profile, queueSync: false);
    notifyListeners();
  }

  AppSettings _loadSettings() {
    try {
      return _settingsRepository.getById('default') ?? AppSettings.defaults();
    } catch (_) {
      return AppSettings.defaults();
    }
  }

  LocalProfile _loadProfile() {
    try {
      return _profileRepository.getById('local') ?? LocalProfile.empty();
    } catch (_) {
      return LocalProfile.empty();
    }
  }
}

// 🔥 මෙන්න මේ කෑල්ල අනිවාර්යයෙන්ම theme_provider.dart එකේ තියෙන්න ඕනේ
class MyThemes {
  static final darkTheme = ThemeData(
    scaffoldBackgroundColor: const Color(0xFF131314), // Gemini Dark
    primaryColor: Colors.green[700],
    colorScheme: const ColorScheme.dark(
      primary: Colors.green,
      surface: Color(0xFF1E1E1F),
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.white),
      bodyMedium: TextStyle(color: Colors.white70),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF131314),
      foregroundColor: Colors.white,
    ),
  );

  static final lightTheme = ThemeData(
    scaffoldBackgroundColor: Colors.white,
    primaryColor: Colors.green[700],
    colorScheme: const ColorScheme.light(primary: Colors.green),
  );
}
