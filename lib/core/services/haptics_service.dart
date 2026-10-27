import 'package:flutter/services.dart';

/// Device vibration. Abstracted so the BLoC can be tested without a platform.
abstract interface class HapticsService {
  /// A short tick for each count.
  Future<void> tick();

  /// A firmer pulse for resets and for switching vibration back on.
  Future<void> confirm();
}

/// Uses the platform haptic engine. It needs no runtime permission and is a
/// silent no-op on devices without a vibration motor.
class PlatformHapticsService implements HapticsService {
  const PlatformHapticsService();

  @override
  Future<void> tick() => _guard(HapticFeedback.lightImpact);

  @override
  Future<void> confirm() => _guard(HapticFeedback.mediumImpact);

  Future<void> _guard(Future<void> Function() feedback) async {
    try {
      await feedback();
    } on PlatformException {
      // Haptics are best-effort; an unsupported device must not break counting.
    } on MissingPluginException {
      // Same as above, for platforms without a haptics implementation.
    }
  }
}
