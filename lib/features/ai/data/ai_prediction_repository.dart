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
}
