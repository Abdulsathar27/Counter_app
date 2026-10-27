import 'package:equatable/equatable.dart';

/// The persisted counter: the current value, the values it can be undone
/// back to (most recent last) and the vibration preference.
class CounterEntity extends Equatable {
  const CounterEntity({
    required this.count,
    this.undoHistory = const [],
    this.vibrationEnabled = true,
  }) : assert(count >= 0, 'count must not be negative');

  static const CounterEntity initial = CounterEntity(count: 0);

  final int count;
  final List<int> undoHistory;
  final bool vibrationEnabled;

  CounterEntity copyWith({int? count, List<int>? undoHistory, bool? vibrationEnabled}) {
    return CounterEntity(
      count: count ?? this.count,
      undoHistory: undoHistory ?? this.undoHistory,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
    );
  }

  @override
  List<Object?> get props => [count, undoHistory, vibrationEnabled];
}
