class AppSettings {
  final String id;
  final String languageCode;
  final String themeMode;
  final bool onboardingComplete;
  final DateTime updatedAt;

  const AppSettings({
    required this.id,
    this.languageCode = 'si',
    this.themeMode = 'light',
    this.onboardingComplete = false,
    required this.updatedAt,
  });

  factory AppSettings.defaults() {
    return AppSettings(id: 'default', updatedAt: DateTime.now());
  }

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      id: json['id'] as String? ?? 'default',
      languageCode: json['languageCode'] as String? ?? 'si',
      themeMode: json['themeMode'] as String? ?? 'light',
      onboardingComplete: json['onboardingComplete'] as bool? ?? false,
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'languageCode': languageCode,
      'themeMode': themeMode,
      'onboardingComplete': onboardingComplete,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  AppSettings copyWith({
    String? languageCode,
    String? themeMode,
    bool? onboardingComplete,
    DateTime? updatedAt,
  }) {
    return AppSettings(
      id: id,
      languageCode: languageCode ?? this.languageCode,
      themeMode: themeMode ?? this.themeMode,
      onboardingComplete: onboardingComplete ?? this.onboardingComplete,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
