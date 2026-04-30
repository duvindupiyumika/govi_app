import '../../../core/storage/hive_box_names.dart';
import '../../../core/storage/json_box_repository.dart';
import '../domain/crop_activity.dart';

class CropActivityRepository extends JsonBoxRepository<CropActivity> {
  CropActivityRepository({super.syncManager})
    : super(
        boxName: HiveBoxNames.cropActivities,
        entityType: 'crop_activity',
        fromJson: CropActivity.fromJson,
        toJson: (activity) => activity.toJson(),
      );
}
