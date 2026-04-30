import '../../../core/storage/hive_box_names.dart';
import '../../../core/storage/json_box_repository.dart';
import '../domain/onboarding_profile.dart';

class OnboardingRepository extends JsonBoxRepository<OnboardingProfile> {
  OnboardingRepository({super.syncManager})
    : super(
        boxName: HiveBoxNames.onboarding,
        entityType: 'onboarding',
        fromJson: OnboardingProfile.fromJson,
        toJson: (profile) => profile.toJson(),
      );
}
