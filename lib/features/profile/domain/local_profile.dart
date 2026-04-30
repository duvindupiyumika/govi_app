class LocalProfile {
  final String id;
  final String name;
  final String? email;
  final String? phoneNumber;
  final String? location;
  final double? landSize;
  final String languageCode;
  final String themeMode;
  final String? profileImagePath;
  final DateTime updatedAt;

  const LocalProfile({
    required this.id,
    required this.name,
    this.email,
    this.phoneNumber,
    this.location,
    this.landSize,
    this.languageCode = 'si',
    this.themeMode = 'light',
    this.profileImagePath,
    required this.updatedAt,
  });

  factory LocalProfile.empty() {
    return LocalProfile(
      id: 'local',
      name: 'Farmer',
      languageCode: 'si',
      themeMode: 'light',
      updatedAt: DateTime.now(),
    );
  }

  factory LocalProfile.fromJson(Map<String, dynamic> json) {
    return LocalProfile(
      id: json['id'] as String,
      name: json['name'] as String? ?? 'Farmer',
      email: json['email'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      location: json['location'] as String?,
      landSize: (json['landSize'] as num?)?.toDouble(),
      languageCode: json['languageCode'] as String? ?? 'si',
      themeMode: json['themeMode'] as String? ?? 'light',
      profileImagePath: json['profileImagePath'] as String?,
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'location': location,
      'landSize': landSize,
      'languageCode': languageCode,
      'themeMode': themeMode,
      'profileImagePath': profileImagePath,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  LocalProfile copyWith({
    String? name,
    String? email,
    String? phoneNumber,
    String? location,
    double? landSize,
    String? languageCode,
    String? themeMode,
    String? profileImagePath,
    DateTime? updatedAt,
  }) {
    return LocalProfile(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      location: location ?? this.location,
      landSize: landSize ?? this.landSize,
      languageCode: languageCode ?? this.languageCode,
      themeMode: themeMode ?? this.themeMode,
      profileImagePath: profileImagePath ?? this.profileImagePath,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
