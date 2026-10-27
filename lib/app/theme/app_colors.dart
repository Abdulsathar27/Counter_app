import 'package:flutter/painting.dart';

/// Color tokens from the MUSMILES / Minimalism design reference.
abstract final class AppColors {
  // Gesso role tokens.
  static const Color canvas = Color(0xFFFFFFFF);
  static const Color surfaceRecessed = Color(0xFFF5F5F5);
  static const Color surface = Color(0xFFF8F8F6);
  static const Color foreground = Color(0xFF111111);
  static const Color foregroundMuted = Color(0xFF5C5C5A);
  static const Color accent = Color(0xFF111111);
  static const Color onAccent = Color(0xFFFFFFFF);
  static const Color secondary = Color(0xFF6E6E6B);
  static const Color divider = Color(0xFFE4E4E1);
  static const Color success = Color(0xFF149343);
  static const Color error = Color(0xFFDC2626);

  // Metallic bezel gradient (180deg: #efefec, #d2d2cf 55%, #e5e5e2).
  static const Color bezelTop = Color(0xFFEFEFEC);
  static const Color bezelMid = Color(0xFFD2D2CF);
  static const Color bezelBottom = Color(0xFFE5E5E2);
  static const Color bezelHighlight = Color(0xE6FFFFFF); // rgba(255,255,255,.9)

  // Flip counter.
  static const Color counterBase = Color(0xFF050505);
  static const Color flapTopStart = Color(0xFF1D1D1D);
  static const Color flapTopEnd = Color(0xFF131313);
  static const Color flapBottomStart = Color(0xFF101010);
  static const Color flapBottomEnd = Color(0xFF090909);
  static const Color digit = Color(0xFFFAFAFA);
  static const Color counterSheen = Color(0x0DFFFFFF); // rgba(255,255,255,.05)
  static const Color hinge = Color(0x73000000); // rgba(0,0,0,.45)
  static const Color hingeHighlight = Color(0x17FFFFFF); // rgba(255,255,255,.09)
  static const Color hingeShadow = Color(0xE6000000); // rgba(0,0,0,.9)
  static const Color flapTopShadow = Color(0xB3000000); // rgba(0,0,0,.7)
  static const Color flapBottomInset = Color(0xE6000000); // rgba(0,0,0,.9)

  // Shadows tinted with ink (#111111).
  static const Color bezelShadowNear = Color(0x0D111111); // .05
  static const Color bezelShadowFar = Color(0x61111111); // .38
  static const Color controlShadow = Color(0x24111111); // .14
  static const Color controlShadowPressed = Color(0x38111111); // .22
}
