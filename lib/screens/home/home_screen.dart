import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../features/tracking/data/crop_activity_repository.dart';
import '../../features/tracking/data/crop_plan_repository.dart';
import '../../features/tracking/data/crop_task_repository.dart';
import '../../features/tracking/domain/crop_activity.dart';
import '../../features/tracking/domain/crop_lifecycle_service.dart';
import '../../features/tracking/domain/crop_plan.dart';
import '../../features/tracking/domain/crop_task.dart';
import '../profile/theme_provider.dart';
import '../tracking/add_crop_screen.dart';
import '../tracking/crop_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  final Function(int) onNavigate;
  final Function(String) onPushRoute;

  const HomeScreen({
    super.key,
    required this.onNavigate,
    required this.onPushRoute,
  });

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ThemeProvider>().profile;
    final planRepository = CropPlanRepository();
    final activityRepository = CropActivityRepository();

    return Scaffold(
      body: SafeArea(
        child: StreamBuilder<List<CropPlan>>(
          stream: planRepository.watchAll(),
          builder: (context, snapshot) {
            final plans = snapshot.data ?? planRepository.getAll();
            plans.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 10),
                    child: _buildHeader(context, profile.name),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: plans.isEmpty
                        ? _buildEmptyCropCard(context)
                        : _ActiveCropCarousel(plans: plans),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                    child: Text(
                      'Quick Actions',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 1.35,
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 14,
                        ),
                    delegate: SliverChildListDelegate([
                      _QuickActionCard(
                        icon: Icons.add_circle_outline,
                        title: 'Add Crop',
                        color: Colors.green,
                        onTap: () => _openAddCrop(context),
                      ),
                      _QuickActionCard(
                        icon: Icons.psychology,
                        title: 'Ask GOVI AI',
                        color: Colors.teal,
                        onTap: () => onNavigate(2),
                      ),
                      _QuickActionCard(
                        icon: Icons.storefront,
                        title: 'Market Prices',
                        color: Colors.blue,
                        onTap: () => onNavigate(3),
                      ),
                      _QuickActionCard(
                        icon: Icons.menu_book,
                        title: 'Learn',
                        color: Colors.orange,
                        onTap: () => onNavigate(4),
                      ),
                    ]),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                    child: Text(
                      'Recent Activities',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                ),
                StreamBuilder<List<CropActivity>>(
                  stream: activityRepository.watchAll(),
                  builder: (context, activitySnapshot) {
                    final activities =
                        activitySnapshot.data ?? activityRepository.getAll();
                    activities.sort(
                      (a, b) => b.createdAt.compareTo(a.createdAt),
                    );
                    final visible = activities.take(5).toList();

                    if (visible.isEmpty) {
                      return const SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: Text('No recent activity yet.'),
                        ),
                      );
                    }

                    return SliverList.builder(
                      itemCount: visible.length,
                      itemBuilder: (context, index) {
                        final activity = visible[index];
                        return ListTile(
                          leading: const CircleAvatar(
                            backgroundColor: Color(0xFFE8F5E9),
                            child: Icon(Icons.check, color: Colors.green),
                          ),
                          title: Text(activity.title),
                          subtitle: Text(_relativeDate(activity.createdAt)),
                        );
                      },
                    );
                  },
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 24)),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String farmerName) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _greeting(),
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
              const SizedBox(height: 4),
              Text(
                farmerName,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2E7D32),
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () => onNavigate(5),
          icon: const Icon(Icons.person_outline),
        ),
      ],
    );
  }

  Widget _buildEmptyCropCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green[50]!, Colors.lightGreen[50]!],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.green.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.eco, color: Color(0xFF2E7D32), size: 42),
          const SizedBox(height: 14),
          const Text(
            'Start tracking your first crop',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Add a crop when you are ready. GOVI will create a harvest progress tracker and timeline tasks.',
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => _openAddCrop(context),
            icon: const Icon(Icons.add),
            label: const Text('Add Crop'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D32),
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  void _openAddCrop(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddCropScreen()),
    );
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'සුභ උදෑසනක්';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  String _relativeDate(DateTime date) {
    final difference = DateTime.now().difference(date);
    if (difference.inDays > 0) return '${difference.inDays} days ago';
    if (difference.inHours > 0) return '${difference.inHours} hours ago';
    if (difference.inMinutes > 0) return '${difference.inMinutes} minutes ago';
    return 'Just now';
  }
}

class _ActiveCropCarousel extends StatelessWidget {
  final List<CropPlan> plans;

  const _ActiveCropCarousel({required this.plans});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 230,
      child: PageView.builder(
        itemCount: plans.length,
        controller: PageController(viewportFraction: 0.92),
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: _ActiveCropCard(plan: plans[index]),
          );
        },
      ),
    );
  }
}

class _ActiveCropCard extends StatelessWidget {
  final CropPlan plan;

  const _ActiveCropCard({required this.plan});

  @override
  Widget build(BuildContext context) {
    final lifecycleService = CropLifecycleService();
    final taskRepository = CropTaskRepository();
    final progress = lifecycleService.progressFor(plan, DateTime.now());
    final percent = (progress * 100).round();

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => CropDetailScreen(plan: plan)),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(20),
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
                const Icon(Icons.eco, color: Colors.white, size: 32),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    plan.cropName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
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
            const SizedBox(height: 18),
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
              'Harvest ${_formatDate(plan.expectedHarvestDate)}',
              style: const TextStyle(color: Colors.white70),
            ),
            const Spacer(),
            StreamBuilder<List<CropTask>>(
              stream: taskRepository.watchAll(),
              builder: (context, snapshot) {
                final tasks =
                    (snapshot.data ?? taskRepository.getAll())
                        .where(
                          (task) =>
                              task.cropPlanId == plan.id &&
                              task.status == CropTaskStatus.pending,
                        )
                        .toList()
                      ..sort((a, b) => a.dueDate.compareTo(b.dueDate));

                return Text(
                  tasks.isEmpty
                      ? 'All tasks done'
                      : 'Next: ${tasks.first.title}',
                  style: const TextStyle(color: Colors.white),
                  overflow: TextOverflow.ellipsis,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 30),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
