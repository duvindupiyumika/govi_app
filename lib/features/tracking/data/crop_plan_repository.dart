import '../../../core/storage/hive_box_names.dart';
import '../../../core/storage/json_box_repository.dart';
import '../domain/crop_plan.dart';

class CropPlanRepository extends JsonBoxRepository<CropPlan> {
  CropPlanRepository({super.syncManager})
    : super(
        boxName: HiveBoxNames.cropPlans,
        entityType: 'crop_plan',
        fromJson: CropPlan.fromJson,
        toJson: (plan) => plan.toJson(),
      );
}
