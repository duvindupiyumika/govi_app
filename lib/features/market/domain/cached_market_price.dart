class CachedMarketPrice {
  final String id;
  final String market;
  final String cropName;
  final String cropNameSinhala;
  final double price;
  final String unit;
  final String source;
  final DateTime updatedAt;

  const CachedMarketPrice({
    required this.id,
    required this.market,
    required this.cropName,
    required this.cropNameSinhala,
    required this.price,
    required this.unit,
    required this.source,
    required this.updatedAt,
  });

  factory CachedMarketPrice.fromJson(Map<String, dynamic> json) {
    return CachedMarketPrice(
      id: json['id'] as String,
      market: json['market'] as String,
      cropName: json['cropName'] as String,
      cropNameSinhala: json['cropNameSinhala'] as String? ?? '',
      price: (json['price'] as num).toDouble(),
      unit: json['unit'] as String? ?? 'kg',
      source: json['source'] as String? ?? 'local',
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'market': market,
      'cropName': cropName,
      'cropNameSinhala': cropNameSinhala,
      'price': price,
      'unit': unit,
      'source': source,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
