import '../../../core/storage/hive_box_names.dart';
import '../../../core/storage/json_box_repository.dart';
import '../domain/cached_market_price.dart';

class MarketPriceRepository extends JsonBoxRepository<CachedMarketPrice> {
  MarketPriceRepository({super.syncManager})
    : super(
        boxName: HiveBoxNames.marketPrices,
        entityType: 'market_price',
        fromJson: CachedMarketPrice.fromJson,
        toJson: (price) => price.toJson(),
      );
}
