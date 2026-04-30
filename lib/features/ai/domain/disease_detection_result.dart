class DiseaseDetectionResult {
  final String likelyDisease;
  final int confidence;
  final String severity;
  final List<String> observedSymptoms;
  final String immediateAction;
  final String prevention;
  final String expertHelpTrigger;
  final List<String> warnings;

  const DiseaseDetectionResult({
    required this.likelyDisease,
    required this.confidence,
    required this.severity,
    required this.observedSymptoms,
    required this.immediateAction,
    required this.prevention,
    required this.expertHelpTrigger,
    required this.warnings,
  });

  factory DiseaseDetectionResult.fromJson(Map<String, dynamic> json) {
    return DiseaseDetectionResult(
      likelyDisease: json['likelyDisease'] as String? ?? 'Unknown',
      confidence: (json['confidence'] as num?)?.round().clamp(0, 100) ?? 0,
      severity: json['severity'] as String? ?? 'unknown',
      observedSymptoms: List<String>.from(
        json['observedSymptoms'] as List? ?? [],
      ),
      immediateAction: json['immediateAction'] as String? ?? '',
      prevention: json['prevention'] as String? ?? '',
      expertHelpTrigger: json['expertHelpTrigger'] as String? ?? '',
      warnings: List<String>.from(json['warnings'] as List? ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'likelyDisease': likelyDisease,
      'confidence': confidence,
      'severity': severity,
      'observedSymptoms': observedSymptoms,
      'immediateAction': immediateAction,
      'prevention': prevention,
      'expertHelpTrigger': expertHelpTrigger,
      'warnings': warnings,
    };
  }
}
