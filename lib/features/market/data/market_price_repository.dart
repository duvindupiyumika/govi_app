import '../../../data/services/market_service.dart';
import '../../../core/storage/hive_box_names.dart';
import '../../../core/storage/json_box_repository.dart';
import '../domain/cached_market_price.dart';

class MarketPriceRepository extends JsonBoxRepository<CachedMarketPrice> {
  final MarketService _marketService;

  MarketPriceRepository({super.syncManager, MarketService? marketService})
    : _marketService = marketService ?? MarketService(),
      super(
        boxName: HiveBoxNames.marketPrices,
        entityType: 'market_price',
        fromJson: CachedMarketPrice.fromJson,
        toJson: (price) => price.toJson(),
      );

  List<String> get availableMarkets => MarketService.allMarkets;

  List<CachedMarketPrice> pricesByMarket(String market) {
    final prices = getAll().where((price) => price.market == market).toList()
      ..sort((a, b) => a.cropNameSinhala.compareTo(b.cropNameSinhala));
    return prices;
  }

  Stream<List<CachedMarketPrice>> watchPricesByMarket(String market) {
    return watchAll().map((prices) {
      final filtered = prices.where((price) => price.market == market).toList()
        ..sort((a, b) => a.cropNameSinhala.compareTo(b.cropNameSinhala));
      return filtered;
    });
  }

  DateTime? lastUpdatedForMarket(String market) {
    final prices = pricesByMarket(market);
    if (prices.isEmpty) return null;

    return prices
        .map((price) => price.updatedAt)
        .reduce((latest, next) => next.isAfter(latest) ? next : latest);
  }

  bool isStale(String market, {Duration maxAge = const Duration(hours: 12)}) {
    final lastUpdated = lastUpdatedForMarket(market);
    if (lastUpdated == null) return true;
    return DateTime.now().difference(lastUpdated) > maxAge;
  }

  Future<int> syncMarketFromFirebase(String market) async {
    final remotePrices = await _marketService.fetchPricesByMarket(market);

    for (final price in remotePrices) {
      final cached = CachedMarketPrice.fromMarketPrice(price);
      await save(cached.id, cached, queueSync: false);
    }

    return remotePrices.length;
  }
}
