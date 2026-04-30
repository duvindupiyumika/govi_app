import '../../../core/storage/hive_box_names.dart';
import '../../../core/storage/json_box_repository.dart';
import '../domain/ai_prediction.dart';

class AiPredictionRepository extends JsonBoxRepository<AiPrediction> {
  AiPredictionRepository({super.syncManager})
    : super(
        boxName: HiveBoxNames.aiPredictions,
        entityType: 'ai_prediction',
        fromJson: AiPrediction.fromJson,
        toJson: (prediction) => prediction.toJson(),
      );

  AiPrediction? latestByType(String type) {
    final predictions = getAll().where((item) => item.type == type).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return predictions.isEmpty ? null : predictions.first;
  }
}
