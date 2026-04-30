class OnboardingProfile {
  final String id;
  final String languageCode;
  final String name;
  final String farmerType;
  final String location;
  final double? latitude;
  final double? longitude;
  final double? landSize;
  final String? landUnit;
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
    required this.farmerType,
    required this.location,
    this.latitude,
    this.longitude,
    this.landSize,
    this.landUnit,
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
      farmerType: json['farmerType'] as String? ?? 'first_time',
      location: json['location'] as String? ?? '',
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      landSize: (json['landSize'] as num?)?.toDouble(),
      landUnit: json['landUnit'] as String?,
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
      'farmerType': farmerType,
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'landSize': landSize,
      'landUnit': landUnit,
      'previousCrops': previousCrops,
      'activeCrop': activeCrop,
      'startDate': startDate?.toIso8601String(),
      'marketPreferences': marketPreferences,
      'isComplete': isComplete,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
