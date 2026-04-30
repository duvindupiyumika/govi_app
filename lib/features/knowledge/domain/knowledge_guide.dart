class KnowledgeGuide {
  final String id;
  final String cropId;
  final String languageCode;
  final String category;
  final String title;
  final String description;
  final String? remedy;
  final int? stageDay;
  final DateTime updatedAt;

  const KnowledgeGuide({
    required this.id,
    required this.cropId,
    required this.languageCode,
    required this.category,
    required this.title,
    required this.description,
    this.remedy,
    this.stageDay,
    required this.updatedAt,
  });

  factory KnowledgeGuide.fromJson(Map<String, dynamic> json) {
    return KnowledgeGuide(
      id: json['id'] as String,
      cropId: json['cropId'] as String,
      languageCode: json['languageCode'] as String? ?? 'si',
      category: json['category'] as String? ?? 'general',
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      remedy: json['remedy'] as String?,
      stageDay: json['stageDay'] as int?,
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cropId': cropId,
      'languageCode': languageCode,
      'category': category,
      'title': title,
      'description': description,
      'remedy': remedy,
      'stageDay': stageDay,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
