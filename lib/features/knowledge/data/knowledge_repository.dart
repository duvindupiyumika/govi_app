import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/storage/hive_box_names.dart';
import '../../../core/storage/json_box_repository.dart';
import '../domain/knowledge_guide.dart';

class KnowledgeRepository extends JsonBoxRepository<KnowledgeGuide> {
  final FirebaseFirestore _firestore;

  KnowledgeRepository({super.syncManager, FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      super(
        boxName: HiveBoxNames.knowledgeGuides,
        entityType: 'knowledge_guide',
        fromJson: KnowledgeGuide.fromJson,
        toJson: (guide) => guide.toJson(),
      );

  static const cropIds = ['brinjal', 'chilli', 'pumpkin', 'tomato'];

  static const cropNames = {
    'brinjal': {'en': 'Brinjal', 'si': 'වම්බටු', 'ta': 'கத்தரிக்காய்'},
    'chilli': {'en': 'Chilli', 'si': 'මිරිස්', 'ta': 'மிளகாய்'},
    'pumpkin': {'en': 'Pumpkin', 'si': 'වට්ටක්කා', 'ta': 'பூசணி'},
    'tomato': {'en': 'Tomato', 'si': 'තක්කාලි', 'ta': 'தக்காளி'},
  };

  Future<void> seedDefaultsIfEmpty() async {
    if (getAll().isNotEmpty) return;

    final now = DateTime.now();
    for (final guide in _seedGuides(now)) {
      await save(guide.id, guide, queueSync: false);
    }
  }

  List<KnowledgeGuide> guidesFor({
    required String languageCode,
    String? cropId,
    String? category,
    String query = '',
  }) {
    final normalizedQuery = query.trim().toLowerCase();
    final allGuides = getAll();
    var guides = allGuides
        .where(
          (guide) =>
              guide.languageCode == languageCode ||
              !allGuides.any(
                    (candidate) =>
                        candidate.cropId == guide.cropId &&
                        candidate.languageCode == languageCode,
                  ) &&
                  guide.languageCode == 'en',
        )
        .toList();

    if (cropId != null && cropId.isNotEmpty) {
      guides = guides.where((guide) => guide.cropId == cropId).toList();
    }
    if (category != null && category.isNotEmpty && category != 'all') {
      guides = guides.where((guide) => guide.category == category).toList();
    }
    if (normalizedQuery.isNotEmpty) {
      guides = guides
          .where(
            (guide) =>
                guide.title.toLowerCase().contains(normalizedQuery) ||
                guide.description.toLowerCase().contains(normalizedQuery) ||
                (guide.remedy ?? '').toLowerCase().contains(normalizedQuery),
          )
          .toList();
    }

    guides.sort((a, b) {
      final stageCompare = (a.stageDay ?? 0).compareTo(b.stageDay ?? 0);
      return stageCompare == 0 ? a.title.compareTo(b.title) : stageCompare;
    });
    return guides;
  }

  Future<int> syncFromFirebase() async {
    var synced = 0;
    final vegetableSnapshot = await _firestore
        .collection('vegetable_metadata')
        .get();

    for (final vegetableDoc in vegetableSnapshot.docs) {
      final cropId = vegetableDoc.id;
      final instructionSnapshot = await vegetableDoc.reference
          .collection('instructions')
          .get();

      for (final instruction in instructionSnapshot.docs) {
        final data = instruction.data();
        final guide = KnowledgeGuide(
          id: '${cropId}_${instruction.id}_${data['languageCode'] ?? 'si'}',
          cropId: cropId,
          languageCode: data['languageCode'] as String? ?? 'si',
          category: data['category'] as String? ?? 'general',
          title: data['title'] as String? ?? 'No title',
          description: data['description'] as String? ?? '',
          remedy: data['remedy'] as String?,
          stageDay: data['stageDay'] as int?,
          updatedAt:
              (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        );
        await save(guide.id, guide, queueSync: false);
        synced++;
      }
    }

    return synced;
  }

  List<KnowledgeGuide> _seedGuides(DateTime now) {
    return [
      KnowledgeGuide(
        id: 'brinjal_en_land',
        cropId: 'brinjal',
        languageCode: 'en',
        category: 'land',
        title: 'Prepare well-drained soil',
        description:
            'Brinjal grows best in warm, well-drained loamy soil. Add compost before planting and avoid waterlogging.',
        stageDay: 0,
        updatedAt: now,
      ),
      KnowledgeGuide(
        id: 'brinjal_en_pest',
        cropId: 'brinjal',
        languageCode: 'en',
        category: 'pest',
        title: 'Watch for shoot and fruit borer',
        description:
            'Inspect young shoots and fruits weekly. Remove damaged parts early to reduce spread.',
        remedy:
            'Use recommended integrated pest management and ask an agriculture officer before chemical use.',
        stageDay: 20,
        updatedAt: now,
      ),
      KnowledgeGuide(
        id: 'chilli_en_disease',
        cropId: 'chilli',
        languageCode: 'en',
        category: 'disease',
        title: 'Prevent leaf curl spread',
        description:
            'Leaf curl often spreads through insect vectors. Remove heavily affected plants and manage whiteflies early.',
        remedy:
            'Use yellow sticky traps and seek local guidance for approved controls.',
        stageDay: 25,
        updatedAt: now,
      ),
      KnowledgeGuide(
        id: 'pumpkin_en_water',
        cropId: 'pumpkin',
        languageCode: 'en',
        category: 'water',
        title: 'Water deeply during flowering',
        description:
            'Pumpkin needs steady moisture during flowering and fruit development. Avoid wetting leaves late in the day.',
        stageDay: 30,
        updatedAt: now,
      ),
      KnowledgeGuide(
        id: 'tomato_en_fertilizer',
        cropId: 'tomato',
        languageCode: 'en',
        category: 'fertilizer',
        title: 'Avoid excess nitrogen',
        description:
            'Too much nitrogen gives leafy growth but fewer fruits. Balance fertilizer with crop stage.',
        stageDay: 18,
        updatedAt: now,
      ),
      KnowledgeGuide(
        id: 'brinjal_si_land',
        cropId: 'brinjal',
        languageCode: 'si',
        category: 'land',
        title: 'ජලය බැස යන පස සකස් කරන්න',
        description:
            'වම්බටු උණුසුම්, ජලය බැස යන ලෝම පසක හොඳින් වැඩේ. සිටුවීමට පෙර කොම්පෝස්ට් එක් කරන්න.',
        stageDay: 0,
        updatedAt: now,
      ),
      KnowledgeGuide(
        id: 'chilli_si_disease',
        cropId: 'chilli',
        languageCode: 'si',
        category: 'disease',
        title: 'Leaf curl පැතිරීම වළක්වන්න',
        description:
            'මිරිස් leaf curl බොහෝවිට කෘමීන් හරහා පැතිරේ. බලපෑ පැල ඉක්මනින් වෙන් කර whitefly පාලනය කරන්න.',
        remedy: 'රසායනික පාලනයට පෙර කෘෂි උපදේශකයෙකුගෙන් උපදෙස් ගන්න.',
        stageDay: 25,
        updatedAt: now,
      ),
      KnowledgeGuide(
        id: 'pumpkin_si_water',
        cropId: 'pumpkin',
        languageCode: 'si',
        category: 'water',
        title: 'මල් කාලයේදී ප්‍රමාණවත් ජලය දෙන්න',
        description:
            'වට්ටක්කා මල් හා ගෙඩි ඇතිවන කාලයේදී ස්ථිර තෙතමනය අවශ්‍ය වේ. කොළ තෙමීම අඩු කරන්න.',
        stageDay: 30,
        updatedAt: now,
      ),
      KnowledgeGuide(
        id: 'tomato_si_fertilizer',
        cropId: 'tomato',
        languageCode: 'si',
        category: 'fertilizer',
        title: 'නයිට්‍රජන් අධික නොකරන්න',
        description:
            'නයිට්‍රජන් වැඩි වීමෙන් කොළ වැඩිවෙයි, ගෙඩි අඩුවිය හැක. වර්ධන අවධිය අනුව පොහොර සමබර කරන්න.',
        stageDay: 18,
        updatedAt: now,
      ),
      KnowledgeGuide(
        id: 'brinjal_ta_land',
        cropId: 'brinjal',
        languageCode: 'ta',
        category: 'land',
        title: 'நீர் வடிகால் உள்ள மண் தயாரிக்கவும்',
        description:
            'கத்தரிக்காய் வெப்பமான, நீர் தேங்காத நல்ல மண்ணில் சிறப்பாக வளரும். நடுவதற்கு முன் உரமிட்டு தயார் செய்யவும்.',
        stageDay: 0,
        updatedAt: now,
      ),
      KnowledgeGuide(
        id: 'chilli_ta_disease',
        cropId: 'chilli',
        languageCode: 'ta',
        category: 'disease',
        title: 'இலை சுருட்டலை தடுப்பது',
        description:
            'மிளகாயில் இலை சுருட்டல் பூச்சிகள் மூலம் பரவலாம். பாதிக்கப்பட்ட செடிகளை விரைவில் பிரித்திடுங்கள்.',
        remedy:
            'ரசாயன கட்டுப்பாட்டிற்கு முன் விவசாய அலுவலரிடம் ஆலோசனை பெறுங்கள்.',
        stageDay: 25,
        updatedAt: now,
      ),
    ];
  }
}
