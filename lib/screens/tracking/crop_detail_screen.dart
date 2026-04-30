import 'package:flutter/material.dart';

import '../../features/tracking/data/crop_activity_repository.dart';
import '../../features/tracking/data/crop_task_repository.dart';
import '../../features/tracking/domain/crop_activity.dart';
import '../../features/tracking/domain/crop_lifecycle_service.dart';
import '../../features/tracking/domain/crop_plan.dart';
import '../../features/tracking/domain/crop_task.dart';

class CropDetailScreen extends StatelessWidget {
  final CropPlan plan;

  const CropDetailScreen({super.key, required this.plan});

  @override
  Widget build(BuildContext context) {
    final taskRepository = CropTaskRepository();
    final lifecycleService = CropLifecycleService();
    final progress = lifecycleService.progressFor(plan, DateTime.now());
    final percent = (progress * 100).round();
    final daysRemaining = lifecycleService.daysRemaining(plan, DateTime.now());

    return Scaffold(
      appBar: AppBar(
        title: Text(plan.cropName),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeroCard(context, percent, progress, daysRemaining),
            const SizedBox(height: 20),
            _buildTimeline(taskRepository),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroCard(
    BuildContext context,
    int percent,
    double progress,
    int daysRemaining,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2E7D32), Color(0xFF66BB6A)],
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.eco, color: Colors.white, size: 34),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      plan.cropName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      plan.location,
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Growth Progress',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '$percent%',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 12,
              backgroundColor: Colors.white.withValues(alpha: 0.25),
              valueColor: const AlwaysStoppedAnimation(Colors.white),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            '$daysRemaining days until expected harvest',
            style: const TextStyle(color: Colors.white),
          ),
          const SizedBox(height: 4),
          Text(
            'Started ${_formatDate(plan.startDate)} • Harvest ${_formatDate(plan.expectedHarvestDate)}',
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
          if (plan.expectedYieldKg != null) ...[
            const SizedBox(height: 4),
            Text(
              'Expected yield: ${plan.expectedYieldKg!.toStringAsFixed(0)} kg',
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTimeline(CropTaskRepository taskRepository) {
    return StreamBuilder<List<CropTask>>(
      stream: taskRepository.watchAll(),
      builder: (context, snapshot) {
        final tasks =
            (snapshot.data ?? taskRepository.getAll())
                .where((task) => task.cropPlanId == plan.id)
                .toList()
              ..sort((a, b) => a.dueDate.compareTo(b.dueDate));

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Timeline Tasks',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            if (tasks.isEmpty)
              const Text('No tasks generated for this crop yet.')
            else
              ...tasks.map((task) => _TaskTile(task: task)),
          ],
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}

class _TaskTile extends StatefulWidget {
  final CropTask task;

  const _TaskTile({required this.task});

  @override
  State<_TaskTile> createState() => _TaskTileState();
}

class _TaskTileState extends State<_TaskTile> {
  final _taskRepository = CropTaskRepository();
  final _activityRepository = CropActivityRepository();

  Future<void> _toggleComplete(bool? value) async {
    final status = value == true
        ? CropTaskStatus.completed
        : CropTaskStatus.pending;
    final updatedTask = widget.task.copyWith(
      status: status,
      updatedAt: DateTime.now(),
    );
    await _taskRepository.save(updatedTask.id, updatedTask);

    if (status == CropTaskStatus.completed) {
      final activityId =
          '${updatedTask.id}_${DateTime.now().millisecondsSinceEpoch}';
      await _activityRepository.save(
        activityId,
        CropActivity(
          id: activityId,
          cropPlanId: updatedTask.cropPlanId,
          title: 'Completed task: ${updatedTask.title}',
          createdAt: DateTime.now(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDone = widget.task.status == CropTaskStatus.completed;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: CheckboxListTile(
        value: isDone,
        onChanged: _toggleComplete,
        activeColor: const Color(0xFF2E7D32),
        title: Text(
          widget.task.title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            decoration: isDone ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: Text(
          '${widget.task.description}\nDue ${_formatDate(widget.task.dueDate)}',
        ),
        isThreeLine: true,
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
