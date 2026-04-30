class CropPlan {
  final String id;
  final String cropName;
  final String? cropNameSinhala;
  final String location;
  final double? landSize;
  final DateTime startDate;
  final DateTime expectedHarvestDate;
  final double? expectedYieldKg;
  final DateTime updatedAt;

  const CropPlan({
    required this.id,
    required this.cropName,
    this.cropNameSinhala,
    required this.location,
    this.landSize,
    required this.startDate,
    required this.expectedHarvestDate,
    this.expectedYieldKg,
    required this.updatedAt,
  });

  factory CropPlan.fromJson(Map<String, dynamic> json) {
    return CropPlan(
      id: json['id'] as String,
      cropName: json['cropName'] as String,
      cropNameSinhala: json['cropNameSinhala'] as String?,
      location: json['location'] as String? ?? '',
      landSize: (json['landSize'] as num?)?.toDouble(),
      startDate: DateTime.parse(json['startDate'] as String),
      expectedHarvestDate: DateTime.parse(
        json['expectedHarvestDate'] as String,
      ),
      expectedYieldKg: (json['expectedYieldKg'] as num?)?.toDouble(),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cropName': cropName,
      'cropNameSinhala': cropNameSinhala,
      'location': location,
      'landSize': landSize,
      'startDate': startDate.toIso8601String(),
      'expectedHarvestDate': expectedHarvestDate.toIso8601String(),
      'expectedYieldKg': expectedYieldKg,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
