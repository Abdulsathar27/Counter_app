import '../entities/counter_entity.dart';

/// Contract for loading and saving the counter.
abstract interface class CounterRepository {
  /// Returns the saved counter, or [CounterEntity.initial] when nothing has
  /// been saved yet. Throws a `StorageException` if storage is unreadable.
  Future<CounterEntity> load();

  /// Saves the count and its undo history.
  Future<void> saveCount(CounterEntity counter);

  /// Saves the vibration preference.
  Future<void> saveVibrationEnabled({required bool enabled});
}
