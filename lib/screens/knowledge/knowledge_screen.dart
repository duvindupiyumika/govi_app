import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class KnowledgeScreen extends StatefulWidget {
  const KnowledgeScreen({super.key});

  @override
  State<KnowledgeScreen> createState() => _KnowledgeScreenState();
}

class _KnowledgeScreenState extends State<KnowledgeScreen> {
  String? _selectedVegetableId; // දැනට තෝරාගෙන ඇති බෝගයේ ID එක
  String? _expandedInstructionId; // විවෘත කර ඇති රෝගයේ/උපදෙසේ ID එක

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('බෝග දැනුම හා උපදෙස්'),
        backgroundColor: Colors.green,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '🌿 බෝගයක් තෝරා උපදෙස් බලන්න',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
            ),
            const SizedBox(height: 15),

            // 1. බෝග ලැයිස්තුව ලබා ගැනීම (vegetable_metadata collection)
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('vegetable_metadata').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('බෝග දත්ත තවම ඇතුළත් කර නැත.'));
                }

                final vegetables = snapshot.data!.docs;

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: vegetables.length,
                  itemBuilder: (context, index) {
                    final vegDoc = vegetables[index];
                    final vegData = vegDoc.data() as Map<String, dynamic>;
                    final String vegId = vegDoc.id;
                    final isVegSelected = _selectedVegetableId == vegId;

                    return Column(
                      children: [
                        // බෝගයේ නම පෙන්වන Card එක
                        Card(
                          elevation: isVegSelected ? 4 : 1,
                          margin: const EdgeInsets.only(bottom: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                            side: BorderSide(color: isVegSelected ? Colors.green : Colors.transparent, width: 2),
                          ),
                          child: ListTile(
                            leading: const CircleAvatar(
                              backgroundColor: Colors.green,
                              child: Icon(Icons.eco, color: Colors.white, size: 20),
                            ),
                            title: Text(
                              vegData['common_name'] ?? vegId,
                              style: TextStyle(
                                fontWeight: isVegSelected ? FontWeight.bold : FontWeight.normal,
                                color: isVegSelected ? Colors.green.shade900 : Colors.black87,
                              ),
                            ),
                            trailing: Icon(isVegSelected ? Icons.expand_less : Icons.expand_more),
                            onTap: () {
                              setState(() {
                                _selectedVegetableId = isVegSelected ? null : vegId;
                                _expandedInstructionId = null; // බෝගය මාරු කරද්දී ඇරපු උපදෙස් වහන්න
                              });
                            },
                          ),
                        ),

                        // 2. උපදෙස් ලැයිස්තුව (Instructions Sub-collection)
                        if (isVegSelected)
                          Padding(
                            padding: const EdgeInsets.only(left: 15, right: 5, bottom: 15),
                            child: StreamBuilder<QuerySnapshot>(
                              stream: FirebaseFirestore.instance
                                  .collection('vegetable_metadata')
                                  .doc(vegId)
                                  .collection('instructions')
                                  .snapshots(),
                              builder: (context, instSnapshot) {
                                if (instSnapshot.connectionState == ConnectionState.waiting) {
                                  return const LinearProgressIndicator();
                                }
                                if (!instSnapshot.hasData || instSnapshot.data!.docs.isEmpty) {
                                  return const Text('   ⚠️ මෙම බෝගය සඳහා තවම උපදෙස් ඇතුළත් කර නැත.');
                                }

                                final instructions = instSnapshot.data!.docs;

                                return ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: instructions.length,
                                  itemBuilder: (context, iIndex) {
                                    final instDoc = instructions[iIndex];
                                    final instData = instDoc.data() as Map<String, dynamic>;
                                    final instId = instDoc.id;
                                    final isInstExpanded = _expandedInstructionId == instId;

                                    return Column(
                                      children: [
                                        // රෝගයේ/උපදෙසේ නම සහිත කොටස
                                        ListTile(
                                          contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                                          leading: Icon(
                                            instData['category'] == 'pest' ? Icons.bug_report : Icons.info_outline,
                                            color: instData['category'] == 'pest' ? Colors.red : Colors.blue,
                                          ),
                                          title: Text(
                                            instData['title'] ?? 'No Title',
                                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                                          ),
                                          trailing: Icon(isInstExpanded ? Icons.remove_circle_outline : Icons.add_circle_outline, color: Colors.orange, size: 20),
                                          onTap: () {
                                            setState(() {
                                              _expandedInstructionId = isInstExpanded ? null : instId;
                                            });
                                          },
                                        ),

                                        // 3. විසඳුම සහ විස්තරය (Instruction Details)
                                        if (isInstExpanded)
                                          Container(
                                            width: double.infinity,
                                            padding: const EdgeInsets.all(15),
                                            margin: const EdgeInsets.only(left: 10, bottom: 10),
                                            decoration: BoxDecoration(
                                              color: Colors.orange.shade50,
                                              borderRadius: BorderRadius.circular(10),
                                              border: Border.all(color: Colors.orange.shade200),
                                            ),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                const Text('📝 විස්තරය:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                                Text(instData['description'] ?? '', style: const TextStyle(fontSize: 13)),
                                                const SizedBox(height: 10),
                                                const Text('✅ විසඳුම:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.green)),
                                                Text(instData['remedy'] ?? '', style: const TextStyle(fontSize: 13, color: Colors.green)),
                                                const SizedBox(height: 8),
                                                Align(
                                                  alignment: Alignment.bottomRight,
                                                  child: Text('දිනය: ${instData['date'] ?? ""}', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                                                ),
                                              ],
                                            ),
                                          ),
                                        const Divider(height: 1),
                                      ],
                                    );
                                  },
                                );
                              },
                            ),
                          ),
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
}