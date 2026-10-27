import 'package:counter/app/app.dart';
import 'package:counter/domain/entities/counter_entity.dart';
import 'package:counter/presentation/counter/bloc/counter_bloc.dart';
import 'package:counter/presentation/counter/widgets/flip_counter.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fakes.dart';

void main() {
  late FakeCounterRepository repository;

  setUp(() => repository = FakeCounterRepository());

  /// Mirrors main(): the bloc is initialised before the first frame.
  Future<CounterBloc> pumpApp(WidgetTester tester, {CounterEntity? saved}) async {
    if (saved != null) repository.stored = saved;
    final bloc = CounterBloc(repository: repository, haptics: FakeHapticsService())
      ..add(const CounterInitialized());
    await tester.runAsync(() => bloc.stream.firstWhere((s) => s.isReady));
    addTearDown(bloc.close);
    await tester.pumpWidget(MusmilesApp(counterBloc: bloc));
    return bloc;
  }

  /// The settled counter paints the value on both the upper and lower flap.
  Finder counterShows(String value) =>
      find.descendant(of: find.byType(FlipCounter), matching: find.text(value));

  final counter = find.byType(FlipCounter);

  testWidgets('shows the saved count on the first frame, before any tap', (tester) async {
    await pumpApp(tester, saved: const CounterEntity(count: 42));

    expect(counterShows('42'), findsNWidgets(2));
    expect(find.text('MUSMILES'), findsOneWidget);
    expect(find.text('Tap to count'), findsOneWidget);
  });

  testWidgets('tapping the counter flips to the next number', (tester) async {
    await pumpApp(tester);

    await tester.tap(counter);
    await tester.pump(const Duration(milliseconds: 100));
    // Mid-flip both the outgoing and incoming values are on the card.
    expect(counterShows('0'), findsWidgets);
    expect(counterShows('1'), findsWidgets);

    await tester.pumpAndSettle();
    expect(counterShows('1'), findsNWidgets(2));
    expect(counterShows('0'), findsNothing);
    expect(repository.stored.count, 1);
  });

  testWidgets('rapid taps are all counted', (tester) async {
    await pumpApp(tester);

    for (var i = 0; i < 12; i++) {
      await tester.tap(counter);
      await tester.pump(const Duration(milliseconds: 30));
    }
    await tester.pumpAndSettle();

    expect(counterShows('12'), findsNWidgets(2));
    expect(repository.stored.count, 12);
  });

  testWidgets('handles the carry from 9 to 10 and 99 to 100', (tester) async {
    await pumpApp(tester, saved: const CounterEntity(count: 9));

    await tester.tap(counter);
    await tester.pumpAndSettle();
    expect(counterShows('10'), findsNWidgets(2));

    await pumpApp(tester, saved: const CounterEntity(count: 99));
    await tester.tap(counter);
    await tester.pumpAndSettle();
    expect(counterShows('100'), findsNWidgets(2));
    expect(tester.takeException(), isNull);
  });

  testWidgets('undo and reset controls update the counter', (tester) async {
    await pumpApp(tester, saved: const CounterEntity(count: 7));

    await tester.tap(counter);
    await tester.pumpAndSettle();
    expect(counterShows('8'), findsNWidgets(2));

    await tester.tap(find.bySemanticsLabel('Undo last count'));
    await tester.pumpAndSettle();
    expect(counterShows('7'), findsNWidgets(2));

    await tester.tap(find.bySemanticsLabel('Reset count'));
    await tester.pumpAndSettle();
    expect(counterShows('0'), findsNWidgets(2));
    expect(repository.stored.count, 0);
  });

  testWidgets('the three controls and the counter are accessible', (tester) async {
    final semantics = tester.ensureSemantics();
    await pumpApp(tester, saved: const CounterEntity(count: 3, undoHistory: [2]));

    expect(
      tester.getSemantics(counter),
      isSemantics(label: 'Tap to count. Current count: 3.', isButton: true, hasTapAction: true),
    );
    expect(
      tester.getSemantics(find.bySemanticsLabel('Undo last count')),
      isSemantics(isButton: true, isEnabled: true, hasTapAction: true),
    );
    expect(
      tester.getSemantics(find.bySemanticsLabel('Reset count')),
      isSemantics(isButton: true, isEnabled: true, hasTapAction: true),
    );
    expect(
      tester.getSemantics(find.bySemanticsLabel('Vibration: on')),
      isSemantics(isButton: true, hasToggledState: true, isToggled: true, hasTapAction: true),
    );

    await tester.tap(find.bySemanticsLabel('Vibration: on'));
    await tester.pump();
    expect(
      tester.getSemantics(find.bySemanticsLabel('Vibration: off')),
      isSemantics(isButton: true, hasToggledState: true, isToggled: false),
    );
    expect(repository.stored.vibrationEnabled, isFalse);

    semantics.dispose();
  });

  testWidgets('the counter can be activated from the keyboard', (tester) async {
    await pumpApp(tester);

    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();

    expect(counterShows('1'), findsNWidgets(2));
  });

  testWidgets('does not overflow on a small screen with large text', (tester) async {
    tester.view
      ..physicalSize = const Size(320, 480)
      ..devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    await pumpApp(tester, saved: const CounterEntity(count: 123456));

    expect(tester.takeException(), isNull);
    expect(counterShows('123456'), findsNWidgets(2));
  });

  testWidgets('skips the flip when the platform asks for reduced motion', (tester) async {
    tester.platformDispatcher.accessibilityFeaturesTestValue = const FakeAccessibilityFeatures(
      disableAnimations: true,
    );
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
    await pumpApp(tester);

    await tester.tap(counter);
    await tester.pump();

    expect(counterShows('1'), findsNWidgets(2));
    expect(tester.hasRunningAnimations, isFalse);
  });
}
