import 'package:connectivity_plus/connectivity_plus.dart';

import '../storage/hive_box_names.dart';
import '../storage/json_box_repository.dart';
import 'sync_queue_item.dart';
import 'sync_status.dart';

typedef SyncHandler = Future<void> Function(SyncQueueItem item);

class SyncManager {
  final Connectivity _connectivity;
  final Map<String, SyncHandler> _handlers = {};
  late final JsonBoxRepository<SyncQueueItem> _queueRepository;

  SyncStatus status = SyncStatus.idle;
  DateTime? lastSyncedAt;

  SyncManager({Connectivity? connectivity})
    : _connectivity = connectivity ?? Connectivity() {
    _queueRepository = JsonBoxRepository<SyncQueueItem>(
      boxName: HiveBoxNames.syncQueue,
      entityType: 'sync_queue',
      fromJson: SyncQueueItem.fromJson,
      toJson: (item) => item.toJson(),
    );
  }

  void registerHandler(String entityType, SyncHandler handler) {
    _handlers[entityType] = handler;
  }

  Future<void> enqueue(SyncQueueItem item) async {
    await _queueRepository.save(item.id, item, queueSync: false);
  }

  List<SyncQueueItem> pendingItems() {
    return _queueRepository.getAll()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
  }

  Future<void> syncPending() async {
    final connectivity = await _connectivity.checkConnectivity();
    if (connectivity.contains(ConnectivityResult.none)) {
      status = SyncStatus.offline;
      return;
    }

    status = SyncStatus.syncing;

    for (final item in pendingItems()) {
      final handler = _handlers[item.entityType];
      if (handler == null) continue;

      try {
        await handler(item);
        await _queueRepository.delete(item.id, queueSync: false);
      } catch (error) {
        await _queueRepository.save(
          item.id,
          item.copyWith(
            retryCount: item.retryCount + 1,
            lastError: error.toString(),
          ),
          queueSync: false,
        );
        status = SyncStatus.failed;
        return;
      }
    }

    lastSyncedAt = DateTime.now();
    status = SyncStatus.synced;
  }
}
