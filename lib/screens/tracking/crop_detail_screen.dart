import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:govi_app/logic/user_provider.dart';

class CropDetailScreen extends StatefulWidget {
  final Map<String, dynamic> crop;
  const CropDetailScreen({super.key, required this.crop});

  @override
  State<CropDetailScreen> createState() => _CropDetailScreenState();
}

class _CropDetailScreenState extends State<CropDetailScreen> {
  String selectedLanguage = 'si';

  final Map<String, Map<String, String>> lang = {
    'en': {
      'title': 'Govi Intelligence',
      'tasks': 'Growth Roadmap',
      'desc': 'Botanical Details',
      'planted': 'PLANTED ON',
      'harvest': 'EST. HARVEST',
      'completed': 'Finished',
      'est_yield': 'Projected Yield',
      'location': 'Location',
      'live': 'ACTIVE',
    },
    'si': {
      'title': 'බෝග බුද්ධිය',
      'tasks': 'වර්ධන පියවර',
      'desc': 'බෝග විස්තරය',
      'planted': 'වගා කළ දිනය',
      'harvest': 'අස්වැන්න දිනය',
      'completed': 'අවසන්',
      'est_yield': 'අස්වැන්න',
      'location': 'ස්ථානය',
      'live': 'සක්‍රීය',
    },
    'ta': {
      'title': 'பயிர் நுண்ணறிவு',
      'tasks': 'வளர்ச்சி பாதை',
      'desc': 'விளக்கம்',
      'planted': 'நடப்பட்ட தேதி',
      'harvest': 'அறுவடை தேதி',
      'completed': 'முடிந்தது',
      'est_yield': 'மகசூல்',
      'location': 'இடம்',
      'live': 'தற்போது',
    }
  };

  DateTime _parseDate(dynamic dateValue) {
    if (dateValue == null) return DateTime.now();
    if (dateValue is Timestamp) return dateValue.toDate();
    if (dateValue is String) return DateTime.tryParse(dateValue) ?? DateTime.now();
    return DateTime.now();
  }

  Future<Map<String, dynamic>> _getMetadata() async {
    String name = (widget.crop['name'] ?? 'brinjal').toString().trim().toLowerCase();
    var doc = await FirebaseFirestore.instance.collection('vegetable_metadata').doc(name).get();
    return doc.data() ?? {};
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF1B5E20);
    const Color pureWhite = Colors.white;
    final farmerId = Provider.of<UserProvider>(context).currentFarmerId;

    return Scaffold(
      backgroundColor: pureWhite,
      body: FutureBuilder<Map<String, dynamic>>(
        future: _getMetadata(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator(color: primaryColor));
          }

          final meta = snapshot.data!;
          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildPremiumAppBar(primaryColor, meta),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 25),
                      _buildModernStatsBar(meta),
                      const SizedBox(height: 25),
                      _buildElevatedProgressCard(primaryColor),
                      const SizedBox(height: 25),
                      _buildInfoGrid(meta),
                      const SizedBox(height: 25),
                      _buildPremiumDescription(meta),
                      const SizedBox(height: 35),
                      _buildSectionHeader(lang[selectedLanguage]!['tasks']!),
                      const SizedBox(height: 15),
                      _buildWeeklyTracker(meta, farmerId, primaryColor),
                      const SizedBox(height: 60),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPremiumAppBar(Color primary, Map<String, dynamic> meta) {
    String? networkImage = meta['imageUrl'] ?? meta['image'] ?? meta['image_url'];
    String name = (widget.crop['name'] ?? 'brinjal').toString().toLowerCase();

    String fallbackUrl = "https://images.unsplash.com/photo-1518843875459-f738682238a6?q=80&w=1000&auto=format&fit=crop";
    if (name.contains('brinjal')) fallbackUrl = "https://images.unsplash.com/photo-1590333746438-283fd638131e?q=80&w=1000&auto=format&fit=crop";
    if (name.contains('pumpkin')) fallbackUrl = "https://images.unsplash.com/photo-1506806732259-39c2d4612173?q=80&w=1000&auto=format&fit=crop";

    return SliverAppBar(
      expandedHeight: 240,
      pinned: true,
      elevation: 0,
      backgroundColor: primary,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              (networkImage != null && networkImage.isNotEmpty) ? networkImage : fallbackUrl,
              fit: BoxFit.cover,
              errorBuilder: (c, e, s) => _buildPlaceholder(),
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black.withOpacity(0.2), Colors.black.withOpacity(0.8)],
                ),
              ),
            ),
            Positioned(
              bottom: 20,
              left: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(lang[selectedLanguage]!['title']!.toUpperCase(), style: TextStyle(color: Colors.greenAccent[400], fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 1.5)),
                  const SizedBox(height: 5),
                  Text(widget.crop['name'] ?? 'Crop', style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [_buildLanguageToggle()],
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: const Color(0xFF1B5E20),
      child: const Icon(Icons.eco, size: 80, color: Colors.white24),
    );
  }

  Widget _buildLanguageToggle() {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: Row(
        children: ['si', 'en', 'ta'].map((l) => GestureDetector(
          onTap: () => setState(() => selectedLanguage = l),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            margin: const EdgeInsets.symmetric(horizontal: 3),
            decoration: BoxDecoration(
              color: selectedLanguage == l ? Colors.white : Colors.white12,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(l.toUpperCase(), style: TextStyle(color: selectedLanguage == l ? Colors.black : Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildModernStatsBar(Map<String, dynamic> meta) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _statBox(Icons.thermostat_rounded, meta['idealTemp'] ?? '25-35°C', Colors.orange),
        _statBox(Icons.water_drop_rounded, meta['idealHumidity'] ?? '50-70%', Colors.blue),
        _statBox(Icons.wb_sunny_rounded, "FULL SUN", Colors.amber),
      ],
    );
  }

  Widget _statBox(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey[100]!),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 8),
        Text(text, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11)),
      ]),
    );
  }

  Widget _buildElevatedProgressCard(Color primary) {
    DateTime planted = _parseDate(widget.crop['planted']);
    DateTime harvest = _parseDate(widget.crop['harvest']);
    int total = harvest.difference(planted).inDays;
    int passed = DateTime.now().difference(planted).inDays;
    double progress = (total > 0) ? (passed / total).clamp(0.0, 1.0) : 0.0;
    String plantedDateStr = DateFormat('yyyy.MM.dd').format(planted);
    String harvestDateStr = DateFormat('yyyy.MM.dd').format(harvest);

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [BoxShadow(color: primary.withOpacity(0.08), blurRadius: 20, offset: const Offset(0, 10))],
        border: Border.all(color: primary.withOpacity(0.05)),
      ),
      child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          _dateDisplay(lang[selectedLanguage]!['planted']!, plantedDateStr, Icons.eco, Colors.green),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: primary.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
            child: Text("${(progress * 100).toInt()}%", style: TextStyle(color: primary, fontWeight: FontWeight.w900, fontSize: 16)),
          ),
          _dateDisplay(lang[selectedLanguage]!['harvest']!, harvestDateStr, Icons.emoji_events, Colors.amber),
        ]),
        const SizedBox(height: 20),
        Row(
          children: [
            const Icon(Icons.eco, color: Colors.green, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Stack(children: [
                Container(height: 10, decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(10))),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 800),
                  height: 10,
                  width: (MediaQuery.of(context).size.width - 84) * progress,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [primary, primary.withOpacity(0.7)]),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ]),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.workspace_premium, color: Colors.amber, size: 18),
          ],
        ),
      ]),
    );
  }

  Widget _dateDisplay(String label, String date, IconData icon, Color iconColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [Icon(icon, size: 12, color: iconColor), const SizedBox(width: 4), Text(label, style: const TextStyle(color: Colors.grey, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 0.5))]),
        const SizedBox(height: 4),
        Text(date, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
      ],
    );
  }

  Widget _buildInfoGrid(Map<String, dynamic> meta) {
    double landSize = double.tryParse(widget.crop['land_size']?.toString() ?? '1.0') ?? 1.0;
    int yieldPerAcre = int.tryParse(meta['average_yield_per_acre_kg']?.toString() ?? '0') ?? 0;

    return Column(children: [
      Row(children: [
        _infoTile(lang[selectedLanguage]!['est_yield']!, "${(yieldPerAcre * landSize).toInt()} kg", Icons.inventory_2_outlined, Colors.orange),
        const SizedBox(width: 15),
        _infoTile(lang[selectedLanguage]!['location']!, widget.crop['location'] ?? 'N/A', Icons.location_on_outlined, Colors.redAccent),
      ]),
      const SizedBox(height: 15),
      Row(children: [
        _infoTile("Varieties", meta['Common Varieties'] ?? 'N/A', Icons.category_outlined, Colors.blue),
        const SizedBox(width: 15),
        _infoTile("Nutrients", meta['Nutrients']?.toString().split(',')[0] ?? 'N/A', Icons.health_and_safety_outlined, Colors.green),
      ]),
    ]);
  }

  Widget _infoTile(String title, String val, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(22), border: Border.all(color: Colors.grey[100]!)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 10),
          Text(title, style: const TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
          Text(val, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15), overflow: TextOverflow.ellipsis),
        ]),
      ),
    );
  }

  Widget _buildPremiumDescription(Map<String, dynamic> meta) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.green[50]!.withOpacity(0.3), borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.green[100]!.withOpacity(0.5))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(lang[selectedLanguage]!['desc']!, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: Color(0xFF1B5E20))),
        const SizedBox(height: 10),
        Text(meta['description'] ?? "No data available", style: const TextStyle(color: Colors.black87, fontSize: 13, height: 1.6)),
      ]),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(children: [
      Container(width: 4, height: 18, decoration: BoxDecoration(color: const Color(0xFF1B5E20), borderRadius: BorderRadius.circular(10))),
      const SizedBox(width: 10),
      Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
    ]);
  }

  Widget _buildWeeklyTracker(Map<String, dynamic> meta, String farmerId, Color primary) {
    DateTime plantedDate = _parseDate(widget.crop['planted']);
    int currentWeek = (DateTime.now().difference(plantedDate).inDays / 7).floor() + 1;
    String cropName = (widget.crop['name'] ?? 'brinjal').toString().toLowerCase();

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('vegetable_metadata').doc(cropName).collection('weekly_tasks').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        var allWeeks = snapshot.data!.docs;
        allWeeks.sort((a, b) => a.id.compareTo(b.id));
        var visibleWeeks = allWeeks.where((doc) {
          int weekNum = int.tryParse(doc.id.split('_')[1]) ?? 0;
          return weekNum <= currentWeek;
        }).toList();

        return Column(children: visibleWeeks.map((weekDoc) {
          int weekNum = int.tryParse(weekDoc.id.split('_')[1]) ?? 0;
          return _buildPremiumWeekItem(weekDoc, weekNum == currentWeek, farmerId, primary);
        }).toList());
      },
    );
  }

  Widget _buildPremiumWeekItem(DocumentSnapshot weekDoc, bool isCurrent, String farmerId, Color primary) {
    List tasks = (weekDoc.data() as Map)['tasks'] ?? [];
    String weekName = "Week ${weekDoc.id.split('_')[1]}";
    String cropDocId = widget.crop['id'] ?? 'H3j3duYvevVMwS7jfOCz';

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('farmers').doc(farmerId).collection('my_crops').doc(cropDocId).collection('actions').where('week_id', isEqualTo: weekDoc.id).snapshots(),
      builder: (context, actionSnap) {
        int done = actionSnap.data?.docs.length ?? 0;
        double progress = tasks.isEmpty ? 0 : done / tasks.length;
        return Container(
          margin: const EdgeInsets.only(bottom: 15),
          decoration: BoxDecoration(color: isCurrent ? primary.withOpacity(0.03) : Colors.white, borderRadius: BorderRadius.circular(24), border: Border.all(color: isCurrent ? primary.withOpacity(0.3) : Colors.grey[200]!, width: isCurrent ? 1.5 : 1)),
          child: ExpansionTile(
            initiallyExpanded: isCurrent,
            tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            leading: _buildCircularProgress(progress, primary),
            title: Row(children: [Text(weekName, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15)), if (isCurrent) _buildLiveBadge()]),
            subtitle: Text("$done/${tasks.length} ${lang[selectedLanguage]!['completed']}", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey[600])),
            children: tasks.map((t) {
              final results = actionSnap.data?.docs.where((doc) => doc['task_name'] == t).toList();
              final bool isDone = results != null && results.isNotEmpty;
              final String? actionDocId = isDone ? results.first.id : null;
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
                decoration: BoxDecoration(color: isDone ? Colors.green[50]!.withOpacity(0.4) : Colors.grey[50], borderRadius: BorderRadius.circular(15)),
                child: CheckboxListTile(
                  value: isDone,
                  activeColor: primary,
                  title: Text(t, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: isDone ? Colors.green[800] : Colors.black87)),
                  onChanged: isCurrent ? (v) => _toggleAction(weekDoc.id, t, actionDocId, farmerId) : null,
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildCircularProgress(double val, Color primary) {
    return Stack(alignment: Alignment.center, children: [
      SizedBox(width: 42, height: 42, child: CircularProgressIndicator(value: val, strokeWidth: 4.5, backgroundColor: Colors.grey[100], color: primary)),
      Text("${(val * 100).toInt()}%", style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900)),
    ]);
  }

  Widget _buildLiveBadge() {
    return Container(
      margin: const EdgeInsets.only(left: 10),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: Colors.green[800], borderRadius: BorderRadius.circular(6)),
      child: Text(lang[selectedLanguage]!['live']!, style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w900)),
    );
  }

  void _toggleAction(String weekId, String task, String? docId, String farmerId) async {
    String cropDocId = widget.crop['id'] ?? 'H3j3duYvevVMwS7jfOCz';
    var collection = FirebaseFirestore.instance.collection('farmers').doc(farmerId).collection('my_crops').doc(cropDocId).collection('actions');
    if (docId != null) { await collection.doc(docId).delete(); }
    else { await collection.add({'week_id': weekId, 'task_name': task, 'timestamp': FieldValue.serverTimestamp()}); }
  }
}
