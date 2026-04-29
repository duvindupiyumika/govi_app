import 'package:cloud_firestore/cloud_firestore.dart';

class MarketPrice {
  final String id;
  final String vegetableName; // Sinhala name
  final String vegetableNameEn; // English name
  final double price; // LKR per unit
  final String market;
  final String unit;
  final DateTime updatedAt;

  MarketPrice({
    required this.id,
    required this.vegetableName,
    required this.vegetableNameEn,
    required this.price,
    required this.market,
    required this.unit,
    required this.updatedAt,
  });

  factory MarketPrice.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final Map<String, dynamic>? data = doc.data();
    if (data == null) {
      throw StateError(
        'MarketPrice document "${doc.id}" does not exist or has no data.',
      );
    }
    return MarketPrice(
      id: doc.id,
      vegetableName: data['vegetableName'] ?? '',
      vegetableNameEn: data['vegetableNameEn'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      market: data['market'] ?? '',
      unit: data['unit'] ?? 'kg',
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'vegetableName': vegetableName,
      'vegetableNameEn': vegetableNameEn,
      'price': price,
      'market': market,
      'unit': unit,
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}
