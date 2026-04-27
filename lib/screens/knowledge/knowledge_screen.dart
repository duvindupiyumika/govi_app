import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class KnowledgeScreen extends StatefulWidget {
  const KnowledgeScreen({super.key});

  @override
  State<KnowledgeScreen> createState() => _KnowledgeScreenState();
}

class _KnowledgeScreenState extends State<KnowledgeScreen> {
  String? _selectedVegetableId;
  String? _selectedVegetableName;
  String? _expandedGuideId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('බෝග දැනුම'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: const Row(
                children: [
                  Icon(Icons.school, color: Colors.green, size: 28),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'බෝග දැනුම',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        Text(
                          'බෝගයක් තෝරා ඒ යටතේ ඇති උපදෙස් බලන්න',
                          style: TextStyle(fontSize: 13, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              '🌾 බෝග වර්ග',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
            ),
            const SizedBox(height: 12),

            // Vegetable Metadata Stream
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('vegetable_metadata')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('බෝග වර්ග නැත'));
                }

                final vegetables = snapshot.data!.docs;
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: vegetables.length,
                  itemBuilder: (context, index) {
                    final doc = vegetables[index];
                    final data = doc.data() as Map<String, dynamic>;
                    final vegId = doc.id;
                    final vegName = data['common_name'] ?? vegId;
                    final isSelected = _selectedVegetableId == vegId;

                    return Column(
                      children: [
                        Card(
                          elevation: isSelected ? 2 : 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: BorderSide(
                              color: isSelected ? Colors.green : Colors.grey.shade200,
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: isSelected ? Colors.green : Colors.grey.shade200,
                              child: Text(
                                vegName[0],
                                style: TextStyle(color: isSelected ? Colors.white : Colors.grey),
                              ),
                            ),
                            title: Text(
                              vegName,
                              style: TextStyle(
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                color: isSelected ? Colors.green : Colors.black87,
                              ),
                            ),
                            subtitle: Text('වගා කාලය: ${data['growing_duration_days'] ?? "N/A"} දින'),
                            trailing: Icon(isSelected ? Icons.expand_less : Icons.chevron_right),
                            onTap: () {
                              setState(() {
                                if (_selectedVegetableId == vegId) {
                                  _selectedVegetableId = null;
                                  _expandedGuideId = null;
                                } else {
                                  _selectedVegetableId = vegId;
                                  _expandedGuideId = null;
                                }
                              });
                            },
                          ),
                        ),

                        // අලුත් Sub-collection Stream එක මෙතනින් පටන් ගන්නවා
                        if (isSelected) ...[
                          const SizedBox(height: 8),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  '📚 උපදෙස් මාලාව',
                                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.orange),
                                ),
                                const SizedBox(height: 8),

                                StreamBuilder<QuerySnapshot>(
                                  // මෙතන තමයි වැදගත්ම වෙනස - Sub-collection එකට path එක දෙන විදිහ
                                  stream: FirebaseFirestore.instance
                                      .collection('vegetable_metadata')
                                      .doc(vegId) // තෝරාගත් බෝගයේ ID එක
                                      .collection('instructions') // ඒ ඇතුළේ තියෙන sub-collection එක
                                      .snapshots(),
                                  builder: (context, guideSnapshot) {
                                    if (guideSnapshot.connectionState == ConnectionState.waiting) {
                                      return const Center(child: CircularProgressIndicator());
                                    }
                                    if (!guideSnapshot.hasData || guideSnapshot.data!.docs.isEmpty) {
                                      return const Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Text('තවම උපදෙස් ඇතුළත් කර නැත'),
                                      );
                                    }

                                    final guides = guideSnapshot.data!.docs;
                                    return ListView.builder(
                                      shrinkWrap: true,
                                      physics: const NeverScrollableScrollPhysics(),
                                      itemCount: guides.length,
                                      itemBuilder: (context, gIndex) {
                                        final guideData = guides[gIndex].data() as Map<String, dynamic>;
                                        final guideId = guides[gIndex].id;
                                        final isGuideExpanded = _expandedGuideId == guideId;

                                        return Card(
                                          margin: const EdgeInsets.only(bottom: 8),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8),
                                            side: BorderSide(color: Colors.grey.shade100),
                                          ),
                                          child: Column(
                                            children: [
                                              ListTile(
                                                leading: Icon(
                                                  _getCategoryIcon(guideData['category']),
                                                  color: _getCategoryColor(guideData['category']),
                                                  size: 20,
                                                ),
                                                title: Text(
                                                  guideData['title'] ?? 'No Title',
                                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                                                ),
                                                trailing: Icon(isGuideExpanded ? Icons.expand_less : Icons.expand_more),
                                                onTap: () {
                                                  setState(() {
                                                    _expandedGuideId = isGuideExpanded ? null : guideId;
                                                  });
                                                },
                                              ),
                                              if (isGuideExpanded)
                                                Padding(
                                                  padding: const EdgeInsets.all(12),
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      const Divider(),
                                                      Text(
                                                        guideData['description'] ?? '',
                                                        style: const TextStyle(fontSize: 12),
                                                      ),
                                                      const SizedBox(height: 10),
                                                      if (guideData['remedy'] != null)
                                                        _buildDetailRow(Icons.check_circle, 'විසඳුම', guideData['remedy'], Colors.green),
                                                    ],
                                                  ),
                                                ),
                                            ],
                                          ),
                                        );
                                      },
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                      ],
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // Helper functions
  IconData _getCategoryIcon(String? cat) {
    switch (cat?.toLowerCase()) {
      case 'disease': return Icons.coronavirus;
      case 'pest': return Icons.bug_report;
      case 'fertilizer': return Icons.eco;
      default: return Icons.info;
    }
  }

  Color _getCategoryColor(String? cat) {
    switch (cat?.toLowerCase()) {
      case 'disease': return Colors.red;
      case 'pest': return Colors.orange;
      case 'fertilizer': return Colors.green;
      default: return Colors.blue;
    }
  }

  Widget _buildDetailRow(IconData icon, String label, String value, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 8),
        Expanded(child: Text('$label: $value', style: TextStyle(fontSize: 12, color: color))),
      ],
    );
  }
}