import '../../../core/storage/hive_box_names.dart';
import '../../../core/storage/json_box_repository.dart';
import '../domain/crop_task.dart';

class CropTaskRepository extends JsonBoxRepository<CropTask> {
  CropTaskRepository({super.syncManager})
    : super(
        boxName: HiveBoxNames.cropTasks,
        entityType: 'crop_task',
        fromJson: CropTask.fromJson,
        toJson: (task) => task.toJson(),
      );
}
