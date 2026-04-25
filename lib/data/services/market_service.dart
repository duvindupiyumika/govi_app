import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/market_price_model.dart';

class MarketService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // All available markets
  static const List<String> allMarkets = [
    'දඹුල්ල',
    'පැල්ල',
    'මීගොඩ',
    'රත්මලාන',
    'බෝකුන්දර',
    'නාරහෙන්පිට',
    'තිස්ස',
    'වේයන්ගොඩ',
    'කැප්පෙටිපොල',
    'තඹුත්තේගම',
  ];

  // All vegetables with Sinhala + English names
  static const List<Map<String, String>> allVegetables = [
    {'si': 'වම්බටු', 'en': 'Brinjal'},
    {'si': 'මිරිස්', 'en': 'Chilli'},
    {'si': 'වටක්කා', 'en': 'Pumpkin'},
    {'si': 'කැරට්', 'en': 'Carrot'},
    {'si': 'තක්කාලි', 'en': 'Tomato'},
    {'si': 'බණ්ඩක්කා', 'en': 'Okra'},
    {'si': 'බෝංචි', 'en': 'Beans'},
    {'si': 'ලීක්ස්', 'en': 'Leeks'},
    {'si': 'කොළ එළවළු', 'en': 'Green Vegetables'},
    {'si': 'අල', 'en': 'Potato'},
    {'si': 'සෝයාබෝංචි', 'en': 'Soybean'},
    {'si': 'කරවිල', 'en': 'Bitter Gourd'},
    {'si': 'පිපිඤ්ඤා', 'en': 'Cucumber'},
    {'si': 'කැබැල්ලා', 'en': 'Snake Gourd'},
    {'si': 'රාබු', 'en': 'Radish'},
    {'si': 'බීට්රූට්', 'en': 'Beetroot'},
  ];

  /// Stream real-time prices for a specific market
  Stream<List<MarketPrice>> streamPricesByMarket(String market) {
    return _firestore
        .collection('markets')
        .doc(market)
        .collection('prices')
        .orderBy('vegetableName')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MarketPrice.fromFirestore(doc))
            .toList());
  }

  /// Add or update a vegetable price in a market
  Future<void> addOrUpdatePrice(MarketPrice price) async {
    final docRef = _firestore
        .collection('markets')
        .doc(price.market)
        .collection('prices')
        .doc(price.vegetableNameEn.toLowerCase());

    await docRef.set(price.toFirestore(), SetOptions(merge: true));
  }

  /// Get all available markets from Firestore
  Future<List<String>> getMarkets() async {
    final snapshot = await _firestore.collection('markets').get();
    if (snapshot.docs.isEmpty) {
      return allMarkets;
    }
    return snapshot.docs.map((doc) => doc.id).toList();
  }

  /// Seed Firestore with sample market data for all markets
  Future<void> seedMarketData() async {
    final batch = _firestore.batch();

    // Base prices per vegetable (will vary by market)
    final basePrices = {
      'Brinjal': 120.0,
      'Chilli': 350.0,
      'Pumpkin': 150.0,
      'Carrot': 180.0,
      'Tomato': 200.0,
      'Okra': 160.0,
      'Beans': 280.0,
      'Leeks': 220.0,
      'Green Vegetables': 100.0,
      'Potato': 250.0,
      'Soybean': 300.0,
      'Bitter Gourd': 190.0,
      'Cucumber': 130.0,
      'Snake Gourd': 170.0,
      'Radish': 140.0,
      'Beetroot': 210.0,
    };

    // Price variation per market (simulate real differences)
    final marketVariations = {
      'දඹුල්ල': 0.85,    // Dambulla: wholesale, cheaper
      'පැල්ල': 1.0,      // Pella: average
      'මීගොඩ': 1.1,      // Meegoda: slightly higher
      'රත්මලාන': 1.15,   // Ratmalana: urban, higher
      'බෝකුන්දර': 1.05,   // Bokundara: slightly above average
      'නාරහෙන්පිට': 1.2,  // Narahenpita: Colombo, highest
      'තිස්ස': 0.9,      // Thissa: rural, lower
      'වේයන්ගොඩ': 0.95,   // Weyangoda: moderate
      'කැප්පෙටිපොල': 0.88, // Keppetipola: upcountry, lower
      'තඹුත්තේගම': 0.92,  // Thambuththegama: rural
    };

    for (final market in allMarkets) {
      // Create market document
      final marketDoc = _firestore.collection('markets').doc(market);
      batch.set(marketDoc, {
        'name': market,
        'createdAt': Timestamp.now(),
      });

      final variation = marketVariations[market] ?? 1.0;

      for (final veg in allVegetables) {
        final basePrice = basePrices[veg['en']] ?? 100.0;
        final adjustedPrice = (basePrice * variation).roundToDouble();

        final priceDoc = marketDoc
            .collection('prices')
            .doc(veg['en']!.toLowerCase());

        batch.set(priceDoc, {
          'vegetableName': veg['si'],
          'vegetableNameEn': veg['en'],
          'price': adjustedPrice,
          'market': market,
          'unit': 'kg',
          'updatedAt': Timestamp.now(),
        });
      }
    }

    await batch.commit();
  }
}
