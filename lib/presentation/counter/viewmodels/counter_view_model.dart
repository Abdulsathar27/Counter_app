import 'package:equatable/equatable.dart';

import '../bloc/counter_bloc.dart';

/// UI-ready projections of [CounterState]. They only format; the BLoC stays
/// the single source of truth. Each is equatable so a `BlocSelector` rebuilds
/// its part of the screen only when that part actually changes.
class CounterViewModel extends Equatable {
  const CounterViewModel({required this.count, required this.isReady});

  factory CounterViewModel.fromState(CounterState state) =>
      CounterViewModel(count: state.count, isReady: state.isReady);

  final int count;
  final bool isReady;

  String get displayValue => '$count';

  String get semanticLabel => 'Tap to count. Current count: $count.';

  @override
  List<Object?> get props => [count, isReady];
}

class CounterControlsViewModel extends Equatable {
  const CounterControlsViewModel({required this.canUndo, required this.vibrationEnabled});

  factory CounterControlsViewModel.fromState(CounterState state) =>
      CounterControlsViewModel(canUndo: state.canUndo, vibrationEnabled: state.vibrationEnabled);

  static const String undoLabel = 'Undo last count';
  static const String resetLabel = 'Reset count';

  final bool canUndo;
  final bool vibrationEnabled;

  String get vibrationLabel => 'Vibration: ${vibrationEnabled ? 'on' : 'off'}';

  @override
  List<Object?> get props => [canUndo, vibrationEnabled];
}
