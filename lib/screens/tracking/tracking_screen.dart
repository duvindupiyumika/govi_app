import 'package:flutter/material.dart';
import 'crop_detail_screen.dart'; // new import

class TrackingScreen extends StatelessWidget {
  const TrackingScreen({super.key});

  // Dummy list of crops – in a real app this would come from a database
  final List<Map<String, dynamic>> crops = const [
    {
      'name': 'Brinjal',
      'sinhalaName': 'වම්බටු',
      'planted': '2026-03-01',
      'expectedYield': 5000,
      'harvest': '2026-04-25',
      'growthStage': 'Flowering',
      'health': 'Good',
      'alerts': ['Fertilizer due in 2 days'],
    },
    {
      'name': 'Chilli',
      'sinhalaName': 'මිරිස්',
      'planted': '2026-03-05',
      'expectedYield': 3000,
      'harvest': '2026-05-10',
      'growthStage': 'Fruiting',
      'health': 'Watch for aphids',
      'alerts': ['Aphids spotted – spray neem oil'],
    },
    {
      'name': 'Pumpkin',
      'sinhalaName': 'විවිටක්කා',
      'planted': '2026-03-10',
      'expectedYield': 8000,
      'harvest': '2026-05-25',
      'growthStage': 'Vegetative',
      'health': 'Excellent',
      'alerts': [],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Crops'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: crops.length,
        itemBuilder: (context, index) {
          final crop = crops[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.green[100],
                child: Text(
                  crop['name'][0],
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                ),
              ),
              title: Text(
                crop['name'],
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Planted: ${crop['planted']}'),
                  Text('Expected: ${crop['expectedYield']} kg'),
                  Text('Harvest: ${crop['harvest']}'),
                  if (crop['alerts'].isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Row(
                        children: [
                          Icon(Icons.warning, color: Colors.red, size: 16),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              crop['alerts'][0],
                              style: const TextStyle(color: Colors.red, fontSize: 12),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                // Navigate to detail screen, passing crop data
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CropDetailScreen(crop: crop),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}