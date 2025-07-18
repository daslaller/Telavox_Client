import 'dart:async';

class TimedItem<T> {
  final T value;
  final Duration lifetime;
  late final Timer _timer;

  TimedItem(this.value, this.lifetime, void Function() onExpired) {
    _timer = Timer(lifetime, onExpired);
  }

  void cancel() {
    _timer.cancel();
  }
}

enum TimedListEvents { added, removed, cleared }

/// A list that automatically removes items after their specified lifetime has passed.
class TimedList<T> {
  final List<TimedItem<T>> _items = [];
  final StreamController<Map<TimedListEvents, TimedItem<T>>> _events =
      StreamController.broadcast();
  Stream<Map<TimedListEvents, TimedItem<T>>> get eventSink => _events.stream;

  /// Adds an item to the list with a specific lifetime.
  void add(T value, Duration lifetime) {
    // To avoid creating a closure in a loop, we create the item first.
    late TimedItem<T> item;
    item = TimedItem(value, lifetime, () {
      _removeItem(item);
    });
    _items.add(item);
    _events.add({TimedListEvents.added: item});
  }

  void _removeItem(TimedItem<T> item) {
    item.cancel();
    _items.remove(item);
    _events.add({TimedListEvents.removed: item});
  }

  /// Checks if a value is currently in the list.
  bool contains(T value) {
    return _items.any((item) => item.value == value);
  }

  /// Clears all items and cancels their timers.
  void clear() {
    for (var item in _items) {
      item.cancel();
    }
    _items.clear();
  }

  int get length => _items.length;
}
