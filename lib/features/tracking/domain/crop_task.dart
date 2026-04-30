enum CropTaskStatus { pending, completed, skipped }

class CropTask {
  final String id;
  final String cropPlanId;
  final String title;
  final String description;
  final DateTime dueDate;
  final CropTaskStatus status;
  final DateTime updatedAt;

  const CropTask({
    required this.id,
    required this.cropPlanId,
    required this.title,
    required this.description,
    required this.dueDate,
    this.status = CropTaskStatus.pending,
    required this.updatedAt,
  });

  factory CropTask.fromJson(Map<String, dynamic> json) {
    return CropTask(
      id: json['id'] as String,
      cropPlanId: json['cropPlanId'] as String,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      dueDate: DateTime.parse(json['dueDate'] as String),
      status: CropTaskStatus.values.byName(
        json['status'] as String? ?? CropTaskStatus.pending.name,
      ),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cropPlanId': cropPlanId,
      'title': title,
      'description': description,
      'dueDate': dueDate.toIso8601String(),
      'status': status.name,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  CropTask copyWith({
    String? title,
    String? description,
    DateTime? dueDate,
    CropTaskStatus? status,
    DateTime? updatedAt,
  }) {
    return CropTask(
      id: id,
      cropPlanId: cropPlanId,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      status: status ?? this.status,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
