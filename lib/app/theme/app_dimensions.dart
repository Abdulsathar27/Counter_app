import 'package:flutter/animation.dart';

/// Layout, shape and motion tokens taken from the reference HTML.
abstract final class AppDimensions {
  // Screen. The reference pads 92px from the top of the device, 44px of
  // which belong to the status bar; the rest sits below the safe area.
  static const double screenTopPadding = 48;

  // Stage.
  static const double stageVerticalPadding = 32;
  static const double stageHorizontalPadding = 24;
  static const double captionTopGap = 38;

  // Counter and bezel.
  static const double counterWidth = 238;
  static const double counterHeight = 150;
  static const double bezelPadding = 7;
  static const double radiusOuter = 26;
  static const double radiusInner = 18;
  static const double counterPerspective = 640;
  static const double hingeHeight = 3;
  static const double digitHorizontalPadding = 16;

  // Controls.
  static const double controlSize = 56;
  static const double controlIconSize = 24;
  static const double controlIconStroke = 1.75;
  static const double controlGap = 34;
  static const double controlsTopPadding = 24;
  static const double controlsHorizontalPadding = 32;
  static const double controlsBottomPadding = 58;
  static const double controlsMinBottomPadding = 24;

  // Focus ring.
  static const double focusRingWidth = 2;
  static const double controlFocusOffset = 3;
  static const double counterFocusOffset = 4;
}

abstract final class AppMotion {
  /// `.flap--top` transition: transform .55s cubic-bezier(.34,.9,.3,1).
  static const Duration flip = Duration(milliseconds: 550);
  static const Curve flipCurve = Cubic(0.34, 0.9, 0.3, 1);

  /// Brightness the folding flap reaches at the hinge (`filter: brightness(.72)`).
  static const double flapMinBrightness = 0.72;

  /// `.ctrl` transition: transform .15s ease.
  static const Duration press = Duration(milliseconds: 150);
  static const Curve pressCurve = Curves.ease;
}
