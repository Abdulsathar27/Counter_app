part of 'counter_bloc.dart';

sealed class CounterEvent extends Equatable {
  const CounterEvent();

  @override
  List<Object?> get props => [];
}

/// Loads the saved counter. Dispatched once when the BLoC is created.
final class CounterInitialized extends CounterEvent {
  const CounterInitialized();
}

/// The user tapped the counter.
final class CounterIncremented extends CounterEvent {
  const CounterIncremented();
}

/// Steps back to the value before the most recent increment or reset.
final class CounterUndoRequested extends CounterEvent {
  const CounterUndoRequested();
}

final class CounterResetRequested extends CounterEvent {
  const CounterResetRequested();
}

final class CounterVibrationToggled extends CounterEvent {
  const CounterVibrationToggled();
}
