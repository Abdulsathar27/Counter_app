import 'package:equatable/equatable.dart';

import '../../core/constants/app_constants.dart';

/// The persisted counter: the current value, the values it can be undone
/// back to (most recent last), the vibration preference and the goal the
/// progress ring fills towards.
class CounterEntity extends Equatable {
  const CounterEntity({
    required this.count,
    this.undoHistory = const [],
    this.vibrationEnabled = true,
    this.goal = AppConstants.defaultGoal,
  }) : assert(count >= 0, 'count must not be negative'),
       assert(goal >= AppConstants.minGoal, 'goal must be positive');

  static const CounterEntity initial = CounterEntity(count: 0);

  final int count;
  final List<int> undoHistory;
  final bool vibrationEnabled;
  final int goal;

  CounterEntity copyWith({int? count, List<int>? undoHistory, bool? vibrationEnabled, int? goal}) {
    return CounterEntity(
      count: count ?? this.count,
      undoHistory: undoHistory ?? this.undoHistory,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      goal: goal ?? this.goal,
    );
  }

  @override
  List<Object?> get props => [count, undoHistory, vibrationEnabled, goal];
}
