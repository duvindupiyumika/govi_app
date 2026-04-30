class OnboardingProfile {
  final String id;
  final String languageCode;
  final String name;
  final String location;
  final double? landSize;
  final List<String> previousCrops;
  final String? activeCrop;
  final DateTime? startDate;
  final List<String> marketPreferences;
  final bool isComplete;
  final DateTime updatedAt;

  const OnboardingProfile({
    required this.id,
    required this.languageCode,
    required this.name,
    required this.location,
    this.landSize,
    this.previousCrops = const [],
    this.activeCrop,
    this.startDate,
    this.marketPreferences = const [],
    required this.isComplete,
    required this.updatedAt,
  });

  factory OnboardingProfile.fromJson(Map<String, dynamic> json) {
    return OnboardingProfile(
      id: json['id'] as String,
      languageCode: json['languageCode'] as String? ?? 'si',
      name: json['name'] as String? ?? 'Farmer',
      location: json['location'] as String? ?? '',
      landSize: (json['landSize'] as num?)?.toDouble(),
      previousCrops: List<String>.from(json['previousCrops'] as List? ?? []),
      activeCrop: json['activeCrop'] as String?,
      startDate: json['startDate'] == null
          ? null
          : DateTime.parse(json['startDate'] as String),
      marketPreferences: List<String>.from(
        json['marketPreferences'] as List? ?? [],
      ),
      isComplete: json['isComplete'] as bool? ?? false,
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'languageCode': languageCode,
      'name': name,
      'location': location,
      'landSize': landSize,
      'previousCrops': previousCrops,
      'activeCrop': activeCrop,
      'startDate': startDate?.toIso8601String(),
      'marketPreferences': marketPreferences,
      'isComplete': isComplete,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
