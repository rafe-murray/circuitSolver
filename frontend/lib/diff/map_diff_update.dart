sealed class MapDiffUpdate<K, V> {
  MapDiffUpdate._();
}

class MapInsert<K, V> extends MapDiffUpdate<K, V> {
  final K position;
  final V data;

  MapInsert({required this.position, required this.data}) : super._();
}

class MapRemove<K, V> extends MapDiffUpdate<K, V> {
  final K position;
  final V data;

  MapRemove({required this.position, required this.data}) : super._();
}

class MapChange<K, V> extends MapDiffUpdate<K, V> {
  final K position;
  final V oldData;
  final V newData;

  MapChange({
    required this.position,
    required this.oldData,
    required this.newData,
  }) : super._();
}
