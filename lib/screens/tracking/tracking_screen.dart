import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../../logic/user_provider.dart';
import 'crop_detail_screen.dart';

class TrackingScreen extends StatelessWidget {
  const TrackingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final farmerId = userProvider.currentFarmerId;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Crops', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color(0xFF2E7D32),
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('crops').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return const Center(child: Text('Something went wrong! ❌'));
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: Colors.green));

          final docs = snapshot.data!.docs;
          if (docs.isEmpty) return const Center(child: Text('No crops found. 🌱'));

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final crop = docs[index].data() as Map<String, dynamic>;
              String cropName = (crop['name'] ?? 'brinjal').toString().toLowerCase().trim();

              return FutureBuilder<DocumentSnapshot>(
                // 🔥 vegetable_metadata එකෙන් image එක ගන්නවා
                future: FirebaseFirestore.instance.collection('vegetable_metadata').doc(cropName).get(),
                builder: (context, metaSnap) {
                  String? imageUrl;
                  if (metaSnap.hasData && metaSnap.data!.exists) {
                    var metaData = metaSnap.data!.data() as Map<String, dynamic>;
                    imageUrl = metaData['imageUrl'] ?? metaData['image'];
                  }

                  // Internet Fallback Images
                  String fallbackUrl = "https://images.unsplash.com/photo-1518843875459-f738682238a6?q=80&w=200&auto=format&fit=crop";
                  if (cropName.contains('brinjal')) fallbackUrl = "https://images.unsplash.com/photo-1590333746438-283fd638131e?q=80&w=200&auto=format&fit=crop";
                  if (cropName.contains('pumpkin')) fallbackUrl = "https://images.unsplash.com/photo-1506806732259-39c2d4612173?q=80&w=200&auto=format&fit=crop";

                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    elevation: 3,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          imageUrl ?? fallbackUrl,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          errorBuilder: (c, e, s) => Container(
                            width: 60,
                            height: 60,
                            color: Colors.green[100],
                            child: const Icon(Icons.eco, color: Colors.green),
                          ),
                        ),
                      ),
                      title: Text(
                        crop['name'] ?? 'Unknown Crop',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          'Planted: ${crop['planted'] ?? 'N/A'}\nExpected: ${crop['expectedYield'] ?? '0'} kg',
                          style: TextStyle(color: Colors.grey[600], fontSize: 13),
                        ),
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.green),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => CropDetailScreen(crop: crop)),
                        );
                      },
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
