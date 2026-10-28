import 'package:flutter/painting.dart';

/// Color tokens for the dark progress-ring design.
abstract final class AppColors {
  // Role tokens.
  static const Color canvas = Color(0xFF171B20);
  static const Color surface = Color(0xFF1F242B);
  static const Color foreground = Color(0xFFEEEDE4);
  static const Color secondary = Color(0xFF95A0AA);
  static const Color divider = Color(0xFF2C333C);
  static const Color accent = Color(0xFF125CA1);
  static const Color onAccent = Color(0xFFFFFFFF);
  static const Color error = Color(0xFFEF5350);

  // Progress ring.
  static const Color ringTrack = Color(0xFF232C36);
  static const Color ringProgress = accent;

  // Buttons: shadows sit on a dark canvas, so they are pure black.
  static const Color controlShadow = Color(0x66000000); // .40
  static const Color controlShadowPressed = Color(0x80000000); // .50

  // Count button ripple, light at .14 at its start.
  static const Color ripple = Color(0x24EEEDE4);
}
