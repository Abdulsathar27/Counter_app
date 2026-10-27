abstract final class AppConstants {
  static const String appTitle = 'Counter';
  static const String brandName = 'Musmiles';
  static const String caption = 'Tap to count';

  /// How many previous values are kept so that undo can step back through
  /// increments and resets. Older entries are discarded.
  static const int undoHistoryLimit = 100;
}

abstract final class StorageKeys {
  static const String count = 'counter.count';
  static const String undoHistory = 'counter.undo_history';
  static const String vibrationEnabled = 'counter.vibration_enabled';
}
