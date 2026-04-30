class AiPrediction {
  final String id;
  final String type;
  final Map<String, dynamic> input;
  final Map<String, dynamic> output;
  final String languageCode;
  final DateTime createdAt;

  const AiPrediction({
    required this.id,
    required this.type,
    required this.input,
    required this.output,
    required this.languageCode,
    required this.createdAt,
  });

  factory AiPrediction.fromJson(Map<String, dynamic> json) {
    return AiPrediction(
      id: json['id'] as String,
      type: json['type'] as String,
      input: Map<String, dynamic>.from(json['input'] as Map? ?? {}),
      output: Map<String, dynamic>.from(json['output'] as Map? ?? {}),
      languageCode: json['languageCode'] as String? ?? 'si',
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'input': input,
      'output': output,
      'languageCode': languageCode,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
