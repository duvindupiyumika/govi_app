import 'package:characters/characters.dart';
import 'package:flutter/material.dart';

import '../../features/market/data/market_price_repository.dart';
import '../../l10n/app_localizations_context.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../features/market/domain/cached_market_price.dart';

enum _MarketSyncState { idle, syncing, synced, failed }

class MarketScreen extends StatefulWidget {
  const MarketScreen({super.key});

  @override
  State<MarketScreen> createState() => _MarketScreenState();
}

class _MarketScreenState extends State<MarketScreen> {
  final MarketPriceRepository _marketRepository = MarketPriceRepository();
  final TextEditingController _searchController = TextEditingController();

  late String _selectedMarket;
  String _searchQuery = '';
  _MarketSyncState _syncState = _MarketSyncState.idle;

  @override
  void initState() {
    super.initState();
    _selectedMarket = _marketRepository.availableMarkets.first;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncSelectedMarket();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _syncSelectedMarket() async {
    setState(() {
      _syncState = _MarketSyncState.syncing;
    });

    try {
      await _marketRepository.syncMarketFromFirebase(_selectedMarket);
      if (!mounted) return;
      setState(() => _syncState = _MarketSyncState.synced);
    } catch (error) {
      if (!mounted) return;
      setState(() => _syncState = _MarketSyncState.failed);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.marketScreenTitle),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: l10n.marketRefreshTooltip,
            onPressed: _syncState == _MarketSyncState.syncing
                ? null
                : _syncSelectedMarket,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildHeader(context, l10n, isDark),
          _buildMarketTabs(),
          _buildMarketStatus(l10n),
          const Divider(height: 1),
          Expanded(
            child: StreamBuilder<List<CachedMarketPrice>>(
              stream: _marketRepository.watchPricesByMarket(_selectedMarket),
              builder: (context, snapshot) {
                final prices =
                    snapshot.data ??
                    _marketRepository.pricesByMarket(_selectedMarket);
                final filtered = _filterPrices(prices);

                if (filtered.isEmpty) {
                  return _EmptyMarketState(
                    l10n: l10n,
                    hasCachedData: prices.isNotEmpty,
                    isSyncing: _syncState == _MarketSyncState.syncing,
                    onRetry: _syncSelectedMarket,
                  );
                }

                return RefreshIndicator(
                  onRefresh: _syncSelectedMarket,
                  child: ListView.builder(
                    padding: const EdgeInsets.only(top: 8, bottom: 16),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      return _PriceCard(l10n: l10n, item: filtered[index]);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    AppLocalizations l10n,
    bool isDark,
  ) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.green, Colors.transparent],
        ),
      ),
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[800] : Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (value) => setState(() => _searchQuery = value),
          decoration: InputDecoration(
            hintText: l10n.marketSearchHint,
            prefixIcon: const Icon(Icons.search, color: Colors.green),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _searchQuery = '');
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 15,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMarketTabs() {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemCount: _marketRepository.availableMarkets.length,
        itemBuilder: (context, index) {
          final market = _marketRepository.availableMarkets[index];
          final isSelected = market == _selectedMarket;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ChoiceChip(
              label: Text(
                market,
                style: TextStyle(
                  color: isSelected ? Colors.white : null,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              selected: isSelected,
              selectedColor: Colors.green,
              onSelected: (selected) {
                if (!selected) return;
                setState(() => _selectedMarket = market);
                _syncSelectedMarket();
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildMarketStatus(AppLocalizations l10n) {
    final lastUpdated = _marketRepository.lastUpdatedForMarket(_selectedMarket);
    final isStale = _marketRepository.isStale(_selectedMarket);

    Color color;
    String label;
    IconData icon;

    if (_syncState == _MarketSyncState.syncing) {
      color = Colors.blue;
      label = l10n.marketStatusSyncing;
      icon = Icons.sync;
    } else if (_syncState == _MarketSyncState.failed) {
      color = lastUpdated == null ? Colors.red : Colors.orange;
      label = lastUpdated == null
          ? l10n.marketStatusOfflineNoCache
          : l10n.marketStatusOfflineCache;
      icon = Icons.cloud_off;
    } else if (lastUpdated == null) {
      color = Colors.grey;
      label = l10n.marketStatusNoCachedData;
      icon = Icons.inbox;
    } else if (isStale) {
      color = Colors.orange;
      label = l10n.marketStatusCachedStale;
      icon = Icons.history;
    } else {
      color = Colors.green;
      label = l10n.marketStatusCachedFresh;
      icon = Icons.check_circle;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          const Icon(Icons.store, color: Colors.green, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              l10n.marketHeaderForMarket(_selectedMarket),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: color, size: 13),
                const SizedBox(width: 4),
                Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<CachedMarketPrice> _filterPrices(List<CachedMarketPrice> prices) {
    final query = _searchQuery.trim().toLowerCase();
    if (query.isEmpty) return prices;

    return prices
        .where(
          (price) =>
              price.cropName.toLowerCase().contains(query) ||
              price.cropNameSinhala.toLowerCase().contains(query),
        )
        .toList();
  }
}

class _EmptyMarketState extends StatelessWidget {
  final AppLocalizations l10n;
  final bool hasCachedData;
  final bool isSyncing;
  final VoidCallback onRetry;

  const _EmptyMarketState({
    required this.l10n,
    required this.hasCachedData,
    required this.isSyncing,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.storefront, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              hasCachedData
                  ? l10n.marketEmptyNoSearchResults
                  : l10n.marketEmptyNoDataYet,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 12),
            if (isSyncing)
              const CircularProgressIndicator(color: Colors.green)
            else
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: Text(l10n.marketSyncPrices),
              ),
          ],
        ),
      ),
    );
  }
}

class _PriceCard extends StatelessWidget {
  final AppLocalizations l10n;
  final CachedMarketPrice item;

  const _PriceCard({required this.l10n, required this.item});

  @override
  Widget build(BuildContext context) {
    final vegColor =
        _vegColors[(item.cropName.hashCode % _vegColors.length).abs()];

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: vegColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  item.cropNameSinhala.isNotEmpty
                      ? item.cropNameSinhala.characters.first
                      : l10n.marketCropInitialFallback,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: vegColor,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.cropNameSinhala,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.cropName,
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    l10n.marketUpdatedOn(_formatDate(item.updatedAt)),
                    style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  l10n.marketPriceRupee(item.price.toStringAsFixed(0)),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                Text(
                  l10n.marketUnitSlash(item.unit),
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  static const List<Color> _vegColors = [
    Colors.green,
    Colors.orange,
    Colors.red,
    Colors.purple,
    Colors.teal,
    Colors.indigo,
    Colors.amber,
    Colors.cyan,
    Colors.brown,
    Colors.pink,
  ];
}
