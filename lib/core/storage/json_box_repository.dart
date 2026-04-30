import 'package:hive/hive.dart';

import '../sync/sync_manager.dart';
import '../sync/sync_queue_item.dart';
import 'local_storage_service.dart';

typedef FromJson<T> = T Function(Map<String, dynamic> json);
typedef ToJson<T> = Map<String, dynamic> Function(T value);

class JsonBoxRepository<T> {
  final String boxName;
  final FromJson<T> fromJson;
  final ToJson<T> toJson;
  final SyncManager? syncManager;
  final String entityType;

  JsonBoxRepository({
    required this.boxName,
    required this.fromJson,
    required this.toJson,
    required this.entityType,
    this.syncManager,
  });

  Box<dynamic> get _box => LocalStorageService.box(boxName);

  Future<void> save(String id, T value, {bool queueSync = true}) async {
    final json = toJson(value);
    await _box.put(id, json);

    if (queueSync && syncManager != null) {
      await syncManager!.enqueue(
        SyncQueueItem(
          id: '${entityType}_$id',
          entityType: entityType,
          entityId: id,
          operation: SyncOperation.upsert,
          payload: json,
          createdAt: DateTime.now(),
        ),
      );
    }
  }

  T? getById(String id) {
    final value = _box.get(id);
    if (value == null) return null;

    return fromJson(Map<String, dynamic>.from(value as Map));
  }

  List<T> getAll() {
    return _box.values
        .whereType<Map>()
        .map((value) => fromJson(Map<String, dynamic>.from(value)))
        .toList();
  }

  Stream<List<T>> watchAll() async* {
    yield getAll();
    yield* _box.watch().map((_) => getAll());
  }

  Future<void> delete(String id, {bool queueSync = true}) async {
    await _box.delete(id);

    if (queueSync && syncManager != null) {
      await syncManager!.enqueue(
        SyncQueueItem(
          id: '${entityType}_${id}_delete',
          entityType: entityType,
          entityId: id,
          operation: SyncOperation.delete,
          payload: const {},
          createdAt: DateTime.now(),
        ),
      );
    }
  }
}
