# Counter_app

**MUSMILES — Flip Counter** is a Flutter tally counter with a split-flap display. Tap the counter to count up. Your count, undo history and vibration setting are saved on the device, so they are still there when you reopen the app.

---

## Features

- **Split-flap counter:** each tap flips the display to the next number with a mechanical flap animation. Carries such as 9 → 10 and 99 → 100 are handled.
- **Tap to count:** tap anywhere on the counter, or activate it from the keyboard.
- **Undo:** step back through up to 100 previous values, including undoing an accidental reset.
- **Reset:** set the count back to 0. You can undo a reset.
- **Vibration toggle:** a light tick on each count and a firmer pulse on reset. You can turn it on or off, and the setting is saved.
- **Persistence:** the count, undo history and vibration setting are stored with `shared_preferences`. The saved count is loaded before the first frame, so the screen never shows a placeholder value.
- **No lost taps:** events are processed one at a time in order, so rapid tapping never drops a count.
- **Error handling:** if saving or loading fails, a SnackBar tells you. Corrupt stored values are cleaned up instead of crashing the app.
- **Accessibility:** semantic labels for the counter and every control, keyboard support, the flip animation is skipped when the system asks for reduced motion, and the layout scales down on small screens with large text.
- **Portrait only**, with a light theme and custom fonts (Switzer and Pinyon Script).

---

## Tech stack

| Purpose | Package |
|---|---|
| State management | [`flutter_bloc`](https://pub.dev/packages/flutter_bloc), [`bloc`](https://pub.dev/packages/bloc) |
| Ordered event processing | [`bloc_concurrency`](https://pub.dev/packages/bloc_concurrency) (`sequential()`) |
| Value equality | [`equatable`](https://pub.dev/packages/equatable) |
| Dependency injection | [`get_it`](https://pub.dev/packages/get_it) |
| Local storage | [`shared_preferences`](https://pub.dev/packages/shared_preferences) |
| Testing | `flutter_test`, [`bloc_test`](https://pub.dev/packages/bloc_test), [`mocktail`](https://pub.dev/packages/mocktail) |
| Linting | [`flutter_lints`](https://pub.dev/packages/flutter_lints) |

- Dart SDK `^3.12.2`
- Built and tested with Flutter 3.44 (stable)

---

## Architecture

The app follows **Clean Architecture** with the **BLoC** pattern. Each layer depends only on the layer inside it.

```
Presentation (UI, BLoC, view models)
        │
        ▼
Domain (entities, repository contract)
        ▲
        │ implements
Data (models, local data source, repository implementation)
```

### Data flow

1. The user taps the counter, and `CounterPage` adds a `CounterIncremented` event to `CounterBloc`.
2. `CounterBloc` computes the new `CounterEntity`, triggers haptic feedback and emits the new state immediately.
3. The BLoC then saves the change through `CounterRepository`, which uses `SharedPreferencesCounterDataSource`.
4. `BlocSelector` widgets map the state to `CounterViewModel` and `CounterControlsViewModel`, so only the part of the screen that changed is rebuilt.

### BLoC events

| Event | What it does |
|---|---|
| `CounterInitialized` | Loads the saved counter at startup |
| `CounterIncremented` | Adds 1 and records the previous value for undo |
| `CounterUndoRequested` | Restores the most recent previous value |
| `CounterResetRequested` | Sets the count to 0 (can be undone) |
| `CounterVibrationToggled` | Turns haptic feedback on or off |

### Stored keys

| Key | Type | Contents |
|---|---|---|
| `counter.count` | `int` | Current count |
| `counter.undo_history` | `List<String>` | Previous values, most recent last (max 100) |
| `counter.vibration_enabled` | `bool` | Vibration preference |

---

## Project structure

```
lib/
├── main.dart                          # Entry point: orientation, system UI, DI, preloads the count
├── app/
│   ├── app.dart                       # MusmilesApp (MaterialApp + BlocProvider)
│   ├── routes.dart                    # Route table
│   └── theme/                         # Colors, dimensions, typography, theme
├── core/
│   ├── constants/app_constants.dart   # App strings, undo limit, storage keys
│   ├── errors/                        # Exceptions and failures
│   └── services/haptics_service.dart  # Vibration abstraction
├── data/
│   ├── datasources/                   # SharedPreferences data source
│   ├── models/                        # CounterModel (storage mapping and cleanup)
│   └── repositories/                  # CounterRepositoryImpl
├── domain/
│   ├── entities/counter_entity.dart   # Count, undo history, vibration preference
│   └── repositories/                  # CounterRepository contract
├── injection/
│   └── dependency_injection.dart      # get_it registrations
└── presentation/counter/
    ├── bloc/                          # CounterBloc, events, state
    ├── viewmodels/                    # UI-ready projections of the state
    ├── views/counter_page.dart        # The single screen
    └── widgets/                       # Flip counter, bezel, header, caption, buttons, icons

test/
├── data/counter_repository_test.dart
├── helpers/fakes.dart
└── presentation/counter/
    ├── counter_bloc_test.dart
    └── counter_page_test.dart

assets/fonts/                          # Switzer and Pinyon Script, with their licenses
```

---

## Getting started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (stable channel, with Dart 3.12.2 or later)
- An emulator, a physical device, or a desktop or web target

### Install and run

```bash
git clone https://github.com/Abdulsathar27/Counter_app.git
cd Counter_app
flutter pub get
flutter run
```

### Build a release

```bash
flutter build apk --release      # Android
flutter build ios --release      # iOS (requires macOS and Xcode)
flutter build web                # Web
flutter build windows            # Windows
```

---

## Testing

```bash
flutter test
```

The test suite covers:

- **Repository:** loading defaults, restoring saved data in a new instance, and cleaning up corrupt values.
- **BLoC:** increment, undo, reset, the undo history limit, the vibration toggle, haptic feedback, and persistence failures.
- **Widgets:** the saved count showing on the first frame, flipping on tap, rapid taps, 9 → 10 and 99 → 100 carries, undo and reset controls, accessibility labels, keyboard activation, small screens with large text, and reduced motion.

Static analysis:

```bash
flutter analyze
```

---

## Platforms

Android, iOS, Web, Windows, macOS and Linux.

---

## Fonts and licenses

- **Switzer**, licensed under the Fontshare Free Font License (`assets/fonts/FFL.txt`)
- **Pinyon Script**, licensed under the SIL Open Font License (`assets/fonts/OFL-PinyonScript.txt`)

---

## Author

**Abdulsathar27** · [GitHub @Abdulsathar27](https://github.com/Abdulsathar27)
