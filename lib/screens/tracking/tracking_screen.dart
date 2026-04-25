import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // 🔥 Firestore import එක අනිවාර්යයි
import 'crop_detail_screen.dart';

class TrackingScreen extends StatelessWidget {
  const TrackingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Crops'),
        backgroundColor: const Color(0xFF2E7D32), // ගොවි ඇප් එකට ගැලපෙන කොළ පාට
      ),
      // 🔥 StreamBuilder පාවිච්චි කරන්නේ Firebase එකේ දත්ත වෙනස් වුණ ගමන් App එකේ ඉබේම පේන්නයි
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('crops').snapshots(),
        builder: (context, snapshot) {
          // 1. Error එකක් ආවොත් පෙන්වන විදිහ
          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong! ❌'));
          }

          // 2. Data ටික ලෝඩ් වෙනකම් Loading එකක් පෙන්වනවා
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.green));
          }

          // 3. Firestore එකෙන් එන දත්ත ටික List එකකට ගන්නවා
          final docs = snapshot.data!.docs;

          // දත්ත කිසිවක් නැතිනම් (Collection එක හිස් නම්)
          if (docs.isEmpty) {
            return const Center(child: Text('No crops found. Add some in Firebase! 🌱'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              // එක Document එකක දත්ත Map එකක් විදිහට ගන්නවා
              final crop = docs[index].data() as Map<String, dynamic>;

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.green[100],
                    child: Text(
                      crop['name'] != null ? crop['name'][0] : '?',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                    ),
                  ),
                  title: Text(
                    crop['name'] ?? 'Unknown Crop',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Planted: ${crop['planted'] ?? 'N/A'}'),
                      Text('Expected: ${crop['expectedYield'] ?? '0'} kg'),
                      Text('Harvest: ${crop['harvest'] ?? 'N/A'}'),
                      // Alerts (Firestore එකේ Array එකක් විදිහට තිබ්බොත් විතරක් පෙන්වන්න)
                      if (crop['alerts'] != null && (crop['alerts'] as List).isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Row(
                            children: [
                              const Icon(Icons.warning, color: Colors.red, size: 16),
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
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    // 🔥 මෙතනදී තමයි Detail Screen එකට දත්ත ටික පාස් වෙන්නේ
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
          );
        },
      ),
    );
  }
}