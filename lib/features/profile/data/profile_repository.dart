import '../../../core/storage/hive_box_names.dart';
import '../../../core/storage/json_box_repository.dart';
import '../domain/local_profile.dart';

class ProfileRepository extends JsonBoxRepository<LocalProfile> {
  ProfileRepository({super.syncManager})
    : super(
        boxName: HiveBoxNames.profiles,
        entityType: 'profile',
        fromJson: LocalProfile.fromJson,
        toJson: (profile) => profile.toJson(),
      );
}
