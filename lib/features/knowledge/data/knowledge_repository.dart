import '../../../core/storage/hive_box_names.dart';
import '../../../core/storage/json_box_repository.dart';
import '../domain/knowledge_guide.dart';

class KnowledgeRepository extends JsonBoxRepository<KnowledgeGuide> {
  KnowledgeRepository({super.syncManager})
    : super(
        boxName: HiveBoxNames.knowledgeGuides,
        entityType: 'knowledge_guide',
        fromJson: KnowledgeGuide.fromJson,
        toJson: (guide) => guide.toJson(),
      );
}
