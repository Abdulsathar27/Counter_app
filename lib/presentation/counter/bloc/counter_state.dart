part of 'counter_bloc.dart';

enum CounterStatus { initial, ready }

final class CounterState extends Equatable {
  const CounterState({
    this.status = CounterStatus.initial,
    this.counter = CounterEntity.initial,
    this.failure,
  });

  final CounterStatus status;
  final CounterEntity counter;

  /// The most recent persistence error, cleared by the next successful save.
  final Failure? failure;

  int get count => counter.count;
  bool get vibrationEnabled => counter.vibrationEnabled;
  bool get canUndo => counter.undoHistory.isNotEmpty;
  bool get isReady => status == CounterStatus.ready;
  int get goal => counter.goal;
  bool get goalReached => count >= goal;

  /// How full the ring is, from 0 to 1. It stays full past the goal.
  double get progress => (count / goal).clamp(0.0, 1.0);

  CounterState copyWith({
    CounterStatus? status,
    CounterEntity? counter,
    Failure? Function()? failure,
  }) {
    return CounterState(
      status: status ?? this.status,
      counter: counter ?? this.counter,
      failure: failure != null ? failure() : this.failure,
    );
  }

  @override
  List<Object?> get props => [status, counter, failure];
}
