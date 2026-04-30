import 'package:flutter/material.dart';

import '../../features/tracking/data/crop_plan_repository.dart';
import '../../features/tracking/domain/crop_lifecycle_service.dart';
import '../../features/tracking/domain/crop_plan.dart';
import 'add_crop_screen.dart';
import 'crop_detail_screen.dart';

class TrackingScreen extends StatelessWidget {
  const TrackingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final planRepository = CropPlanRepository();
    final lifecycleService = CropLifecycleService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Crops'),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddCropScreen()),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Crop'),
      ),
      body: StreamBuilder<List<CropPlan>>(
        stream: planRepository.watchAll(),
        builder: (context, snapshot) {
          final plans = snapshot.data ?? planRepository.getAll();

          if (plans.isEmpty) {
            return _EmptyTrackingState(
              onAddCrop: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddCropScreen(),
                  ),
                );
              },
            );
          }

          plans.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
            itemCount: plans.length,
            itemBuilder: (context, index) {
              final plan = plans[index];
              final progress = lifecycleService.progressFor(
                plan,
                DateTime.now(),
              );
              final percent = (progress * 100).round();

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CropDetailScreen(plan: plan),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: Colors.green[100],
                              child: Text(
                                plan.cropName.isEmpty ? '?' : plan.cropName[0],
                                style: const TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    plan.cropName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 17,
                                    ),
                                  ),
                                  Text(
                                    plan.location,
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              '$percent%',
                              style: const TextStyle(
                                color: Color(0xFF2E7D32),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 10,
                            backgroundColor: Colors.grey[200],
                            valueColor: const AlwaysStoppedAnimation(
                              Color(0xFF2E7D32),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Harvest: ${_formatDate(plan.expectedHarvestDate)}',
                          style: const TextStyle(fontSize: 13),
                        ),
                        if (plan.expectedYieldKg != null)
                          Text(
                            'Expected yield: ${plan.expectedYieldKg!.toStringAsFixed(0)} kg',
                            style: const TextStyle(fontSize: 13),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}

class _EmptyTrackingState extends StatelessWidget {
  final VoidCallback onAddCrop;

  const _EmptyTrackingState({required this.onAddCrop});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.eco_outlined, size: 80, color: Colors.green[300]),
            const SizedBox(height: 16),
            const Text(
              'No crops tracked yet',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Add your first crop when you are ready. GOVI will build a harvest timeline and task list locally.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: onAddCrop,
              icon: const Icon(Icons.add),
              label: const Text('Add Crop'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
