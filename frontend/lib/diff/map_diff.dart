import 'package:frontend/diff/diffable.dart';
import 'package:frontend/diff/map_diff_update.dart';

class MapDiff<K, V> implements Diffable<Map<K, V>> {
  final List<MapDiffUpdate<K, V>> updates;

  MapDiff(this.updates);
  @override
  Map<K, V> applyTo(Map<K, V> map) {
    var newMap = Map.of(map);
    for (var update in updates) {
      switch (update) {
        case MapInsert<K, V>():
          newMap[update.position] = update.data;
        case MapRemove<K, V>():
          newMap.remove(update.position);
        case MapChange<K, V>():
          newMap[update.position] = update.newData;
      }
    }
    return newMap;
  }

  @override
  Map<K, V> revertFrom(Map<K, V> map) {
    var newMap = Map.of(map);
    for (var update in updates.toList().reversed) {
      switch (update) {
        case MapInsert<K, V>():
          newMap.remove(update.position);
        case MapRemove<K, V>():
          newMap[update.position] = update.data;
        case MapChange<K, V>():
          newMap[update.position] = update.oldData;
      }
    }
    return newMap;
  }
}

MapDiff<K, V> calculateMapDiff<K, V>(Map<K, V> oldMap, Map<K, V> newMap) {
  // Iterate once over oldMap to get all changes and removes
  final updates = <MapDiffUpdate<K, V>>[];
  for (MapEntry<K, V> entry in oldMap.entries) {
    final newValue = newMap[entry.key];
    if (newValue == null) {
      updates.add(MapRemove(position: entry.key, data: entry.value));
      continue;
    }
    if (newValue != entry.value) {
      updates.add(
        MapChange(position: entry.key, oldData: entry.value, newData: newValue),
      );
      continue;
    }
  }
  updates.addAll(
    newMap.entries
        .where((entry) => (oldMap[entry.key] == null))
        .map((entry) => MapInsert(position: entry.key, data: entry.value)),
  );
  return MapDiff(updates);
}
