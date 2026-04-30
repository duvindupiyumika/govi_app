import 'crop_plan.dart';
import 'crop_task.dart';

class CropLifecycleService {
  static const _growthDays = {
    'Brinjal': 70,
    'Chilli': 90,
    'Pumpkin': 100,
    'Carrot': 80,
    'Tomato': 75,
    'Beans': 60,
    'Bitter Gourd': 70,
  };

  static const _yieldPerAcre = {
    'Brinjal': 8000.0,
    'Chilli': 5000.0,
    'Pumpkin': 10000.0,
    'Carrot': 9000.0,
    'Tomato': 10000.0,
    'Beans': 4500.0,
    'Bitter Gourd': 6500.0,
  };

  int growingDaysFor(String cropName) => _growthDays[cropName] ?? 75;

  DateTime harvestDateFor(String cropName, DateTime startDate) {
    return startDate.add(Duration(days: growingDaysFor(cropName)));
  }

  double? expectedYieldFor(String cropName, double? landSize) {
    if (landSize == null) return null;
    return (_yieldPerAcre[cropName] ?? 6000) * landSize;
  }

  double progressFor(CropPlan plan, DateTime now) {
    final totalDays = plan.expectedHarvestDate
        .difference(plan.startDate)
        .inDays;
    if (totalDays <= 0) return 1;

    final daysPassed = now.difference(plan.startDate).inDays;
    return (daysPassed / totalDays).clamp(0.0, 1.0);
  }

  int daysRemaining(CropPlan plan, DateTime now) {
    return plan.expectedHarvestDate.difference(now).inDays.clamp(0, 9999);
  }

  List<CropTask> generateTasks(CropPlan plan) {
    final now = DateTime.now();
    return [
      CropTask(
        id: '${plan.id}_soil',
        cropPlanId: plan.id,
        title: 'Check soil moisture',
        description: 'Inspect soil moisture and water if the soil is dry.',
        dueDate: plan.startDate.add(const Duration(days: 3)),
        updatedAt: now,
      ),
      CropTask(
        id: '${plan.id}_fertilizer',
        cropPlanId: plan.id,
        title: 'Apply fertilizer',
        description: 'Apply recommended fertilizer based on crop stage.',
        dueDate: plan.startDate.add(const Duration(days: 15)),
        updatedAt: now,
      ),
      CropTask(
        id: '${plan.id}_pest',
        cropPlanId: plan.id,
        title: 'Inspect for pests',
        description: 'Check leaves and stems for pest or disease symptoms.',
        dueDate: plan.startDate.add(const Duration(days: 30)),
        updatedAt: now,
      ),
      CropTask(
        id: '${plan.id}_harvest',
        cropPlanId: plan.id,
        title: 'Prepare for harvest',
        description: 'Review expected harvest window and market price trends.',
        dueDate: plan.expectedHarvestDate.subtract(const Duration(days: 7)),
        updatedAt: now,
      ),
    ];
  }
}
