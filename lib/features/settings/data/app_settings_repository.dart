import '../../../core/storage/hive_box_names.dart';
import '../../../core/storage/json_box_repository.dart';
import '../domain/app_settings.dart';

class AppSettingsRepository extends JsonBoxRepository<AppSettings> {
  AppSettingsRepository()
    : super(
        boxName: HiveBoxNames.appSettings,
        entityType: 'app_settings',
        fromJson: AppSettings.fromJson,
        toJson: (settings) => settings.toJson(),
      );
}
