class CropActivity {
  final String id;
  final String cropPlanId;
  final String title;
  final DateTime createdAt;

  const CropActivity({
    required this.id,
    required this.cropPlanId,
    required this.title,
    required this.createdAt,
  });

  factory CropActivity.fromJson(Map<String, dynamic> json) {
    return CropActivity(
      id: json['id'] as String,
      cropPlanId: json['cropPlanId'] as String,
      title: json['title'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cropPlanId': cropPlanId,
      'title': title,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
