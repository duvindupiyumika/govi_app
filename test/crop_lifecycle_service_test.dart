import 'package:flutter_test/flutter_test.dart';
import 'package:govi_app/features/tracking/domain/crop_lifecycle_service.dart';
import 'package:govi_app/features/tracking/domain/crop_plan.dart';

void main() {
  group('CropLifecycleService', () {
    final service = CropLifecycleService();

    test('calculates expected harvest date from crop defaults', () {
      final start = DateTime(2026, 1, 1);

      expect(service.harvestDateFor('Brinjal', start), DateTime(2026, 3, 12));
    });

    test('calculates progress safely between start and harvest', () {
      final plan = CropPlan(
        id: 'crop-1',
        cropName: 'Beans',
        location: 'Kandy',
        startDate: DateTime(2026, 1, 1),
        expectedHarvestDate: DateTime(2026, 1, 31),
        updatedAt: DateTime(2026, 1, 1),
      );

      expect(service.progressFor(plan, DateTime(2026, 1, 16)), 0.5);
      expect(service.progressFor(plan, DateTime(2025, 12, 1)), 0);
      expect(service.progressFor(plan, DateTime(2026, 2, 10)), 1);
    });

    test('generates starter timeline tasks for crop plan', () {
      final plan = CropPlan(
        id: 'crop-1',
        cropName: 'Tomato',
        location: 'Galle',
        startDate: DateTime(2026, 1, 1),
        expectedHarvestDate: DateTime(2026, 3, 17),
        updatedAt: DateTime(2026, 1, 1),
      );

      final tasks = service.generateTasks(plan);

      expect(tasks, hasLength(4));
      expect(tasks.every((task) => task.cropPlanId == plan.id), isTrue);
      expect(tasks.map((task) => task.title), contains('Apply fertilizer'));
    });
  });
}
