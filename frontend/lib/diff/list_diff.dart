import 'package:diffutil_dart/diffutil.dart';
import './diffable.dart';

class ListDiff<T> implements Diffable<List<T>> {
  final DiffResult<T> result;

  ListDiff(this.result);

  /// Performs a shallow copy on [list] and applies this [DiffResult]
  List<T> applyTo(List<T> list) {
    var newList = list.toList();
    final updates = result.getUpdatesWithData();
    for (var update in updates) {
      switch (update) {
        case DataInsert<T>():
          newList.insert(update.position, update.data);
        case DataRemove<T>():
          newList.removeAt(update.position);
        case DataChange<T>():
          newList[update.position] = update.newData;
        case DataMove<T>():
          newList[update.to] = newList[update.from];
      }
    }
    return newList;
  }

  /// Performs a shallow copy on [list] and applies the inverse of this [DiffResult].
  /// This method should undo the changes from [applyTo()]
  List<T> revertFrom(List<T> list) {
    var newList = list.toList();
    final updates = result.getUpdatesWithData();
    for (var update in updates.toList().reversed) {
      switch (update) {
        case DataInsert<T>():
          newList.removeAt(update.position);
        case DataRemove<T>():
          newList.insert(update.position, update.data);
        case DataChange<T>():
          newList[update.position] = update.oldData;
        case DataMove<T>():
          newList[update.from] = newList[update.to];
      }
    }
    return newList;
  }
}
