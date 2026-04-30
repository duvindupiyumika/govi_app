class CropSuggestionResult {
  final String recommendedCrop;
  final int confidence;
  final String reasonSummary;
  final String marketRisk;
  final String weatherFit;
  final String soilRotationNote;
  final String expectedHarvestWindow;
  final List<String> actions;
  final List<String> warnings;

  const CropSuggestionResult({
    required this.recommendedCrop,
    required this.confidence,
    required this.reasonSummary,
    required this.marketRisk,
    required this.weatherFit,
    required this.soilRotationNote,
    required this.expectedHarvestWindow,
    required this.actions,
    required this.warnings,
  });

  factory CropSuggestionResult.fromJson(Map<String, dynamic> json) {
    return CropSuggestionResult(
      recommendedCrop: json['recommendedCrop'] as String? ?? 'Unknown',
      confidence: (json['confidence'] as num?)?.round().clamp(0, 100) ?? 0,
      reasonSummary: json['reasonSummary'] as String? ?? '',
      marketRisk: json['marketRisk'] as String? ?? '',
      weatherFit: json['weatherFit'] as String? ?? '',
      soilRotationNote: json['soilRotationNote'] as String? ?? '',
      expectedHarvestWindow: json['expectedHarvestWindow'] as String? ?? '',
      actions: List<String>.from(json['actions'] as List? ?? []),
      warnings: List<String>.from(json['warnings'] as List? ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'recommendedCrop': recommendedCrop,
      'confidence': confidence,
      'reasonSummary': reasonSummary,
      'marketRisk': marketRisk,
      'weatherFit': weatherFit,
      'soilRotationNote': soilRotationNote,
      'expectedHarvestWindow': expectedHarvestWindow,
      'actions': actions,
      'warnings': warnings,
    };
  }
}
