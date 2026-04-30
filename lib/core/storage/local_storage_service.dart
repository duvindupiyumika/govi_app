import 'package:hive_flutter/hive_flutter.dart';

import 'hive_box_names.dart';

class LocalStorageService {
  const LocalStorageService._();

  static Future<void> initialize() async {
    await Hive.initFlutter();

    for (final boxName in HiveBoxNames.all) {
      if (!Hive.isBoxOpen(boxName)) {
        await Hive.openBox<dynamic>(boxName);
      }
    }
  }

  static Box<dynamic> box(String name) {
    if (!Hive.isBoxOpen(name)) {
      throw StateError('Hive box "$name" has not been opened.');
    }

    return Hive.box<dynamic>(name);
  }
}
