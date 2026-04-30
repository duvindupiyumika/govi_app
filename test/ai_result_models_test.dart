import 'package:flutter_test/flutter_test.dart';
import 'package:govi_app/features/ai/domain/crop_suggestion_result.dart';
import 'package:govi_app/features/ai/domain/disease_detection_result.dart';

void main() {
  group('AI result models', () {
    test('parses crop suggestion result with bounded confidence', () {
      final result = CropSuggestionResult.fromJson({
        'recommendedCrop': 'Brinjal',
        'confidence': 120,
        'reasonSummary': 'Good fit for local conditions.',
        'marketRisk': 'Medium',
        'weatherFit': 'Good',
        'soilRotationNote': 'Avoid repeating same family.',
        'expectedHarvestWindow': '70 days',
        'actions': ['Prepare nursery', 'Check prices'],
        'warnings': ['Confirm water availability'],
      });

      expect(result.recommendedCrop, 'Brinjal');
      expect(result.confidence, 100);
      expect(result.actions, hasLength(2));
    });

    test('parses disease detection result with safe defaults', () {
      final result = DiseaseDetectionResult.fromJson({
        'likelyDisease': 'Leaf curl',
        'confidence': -5,
        'severity': 'medium',
        'observedSymptoms': ['Curled leaves'],
        'immediateAction': 'Isolate affected plants.',
        'prevention': 'Control vectors.',
        'expertHelpTrigger': 'If spreading quickly.',
      });

      expect(result.likelyDisease, 'Leaf curl');
      expect(result.confidence, 0);
      expect(result.warnings, isEmpty);
    });
  });
}
