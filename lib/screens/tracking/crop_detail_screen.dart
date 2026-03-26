import 'package:flutter/material.dart';

class CropDetailScreen extends StatelessWidget {
  final Map<String, dynamic> crop;

  const CropDetailScreen({super.key, required this.crop});

  @override
  Widget build(BuildContext context) {
    // Calculate progress percentage based on planted date and harvest date
    // For demo, we use static dates; in real app, these would come from crop data
    final DateTime planted = DateTime.parse(crop['planted']); // e.g., '2026-03-01'
    final DateTime harvest = DateTime.parse(crop['harvest']); // e.g., '2026-04-25'
    final int totalDays = harvest.difference(planted).inDays;
    final int daysPassed = DateTime.now().difference(planted).inDays;
    final double progress = (daysPassed / totalDays).clamp(0.0, 1.0);
    final int percent = (progress * 100).round();

    return Scaffold(
      appBar: AppBar(
        title: Text(crop['name']),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top stats row (temperature/humidity simulation)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem('🌡️', '28°C', 'Temp'),
                  _buildStatItem('💧', '65%', 'Humidity'),
                  _buildStatItem('☀️', '8h', 'Sun'),
                  _buildStatItem('🌱', crop['growthStage'], 'Stage'),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Crop image placeholder + name
            Center(
              child: Column(
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.green[100],
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.green.shade400, width: 3),
                    ),
                    child: Icon(
                      Icons.eco,
                      size: 60,
                      color: Colors.green[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    crop['name'],
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    crop['sinhalaName'],
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Progress bar with percentage
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Growth Progress',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey[800]),
                      ),
                      Text(
                        '$percent%',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 12,
                      backgroundColor: Colors.grey[300],
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF2E7D32)),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Planted: ${crop['planted']}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      Text('Harvest: ${crop['harvest']}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$daysPassed of $totalDays days',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Disease alerts and remedies
            const Text(
              'Disease Alerts & Remedies',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildAlertCard(
              icon: Icons.warning_amber,
              title: 'Leaf Curl',
              description: 'Possible in next 3 days.',
              remedy: 'Apply neem oil spray.',
              color: Colors.orange,
            ),
            _buildAlertCard(
              icon: Icons.bug_report,
              title: 'Aphids',
              description: 'Spotted on lower leaves.',
              remedy: 'Use insecticidal soap.',
              color: Colors.red,
            ),
            _buildAlertCard(
              icon: Icons.spa,
              title: 'Fertilizer',
              description: 'NPK 12:12:17 due in 2 days.',
              remedy: 'Apply 100kg/acre.',
              color: Colors.blue,
            ),
            const SizedBox(height: 24),

            // Quick action grid (matching image: Trea, Price, Protest, n.nolege)
            const Text(
              'Quick Actions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.5,
              children: [
                _buildActionCard('Treatment', Icons.medical_services, Colors.purple),
                _buildActionCard('Market Price', Icons.attach_money, Colors.blue),
                _buildActionCard('Protection', Icons.shield, Colors.orange),
                _buildActionCard('Knowledge', Icons.menu_book, Colors.teal),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // Helper to build stat items
  Widget _buildStatItem(String emoji, String value, String label) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 24)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  // Helper to build alert cards
  Widget _buildAlertCard({
    required IconData icon,
    required String title,
    required String description,
    required String remedy,
    required Color color,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: color)),
                  const SizedBox(height: 2),
                  Text(description, style: const TextStyle(fontSize: 13)),
                  const SizedBox(height: 4),
                  Text('💡 Remedy: $remedy', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper to build quick action cards
  Widget _buildActionCard(String label, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () {
          // TODO: Navigate to respective screens
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 4),
              Text(label, style: const TextStyle(fontSize: 12), textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}