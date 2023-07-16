
import 'package:rxdart/rxdart.dart';
import 'package:collection/collection.dart';

abstract class ListWithIdsReactiveRepository<T> {

  final update = PublishSubject<Null>();

  Future<List<String>> getRawData();

  Future<bool> saveRawData(final List<String> items);

  T convertFromString(final String rawItem);

  String convertToString(final T item);

  dynamic getId(final T item);

  Future<List<T>> getItems() async {
    final rawItems = await getRawData();
    return rawItems
        .map((rawItem) => convertFromString(rawItem))
        .toList();
  }

  Future<bool> setItems(final List<T> items) async {
    final rawItems = items.map((item) => convertToString(item)).toList();
    return _setRawItems(rawItems);
  }

  Future<bool> _setRawItems(List<String> rawItems) async {
    update.add(null);
    return saveRawData(rawItems);
  }

  Stream<List<T>> observeItems() async* {
    yield await getItems();
    await for (final _ in update) {
      yield await getItems();
    }
  }

  Future<bool> addItem(final T item) async {
    final items = await getItems();
    items.add(item);
    return setItems(items);
  }

  Future<bool> removeItem(final T item) async {
    final items = await getItems();
    items.remove(item);
    return setItems(items);
  }

  Future<bool> addItemOrReplaceById(final T newItem) async {
    final items = await getItems();
    final itemIndex = items.indexWhere((element) => getId(newItem) == getId(element));
    if (itemIndex == -1) {
      items.add(newItem);
    } else {
      items[itemIndex] = newItem;
    }
    return setItems(items);
  }

  Future<bool> removeFromItemsById(final dynamic id) async {
    final items = await getItems();
    items.removeWhere((element) => getId(element) == id);
    return setItems(items);
  }

  Future<T?> getItemById(final dynamic id) async {
    final items = await getItems();

    return items.firstWhereOrNull((item) => getId(item) == id);
  }

}