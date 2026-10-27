import 'package:flutter/painting.dart';

import 'app_colors.dart';

/// Typography tokens. Switzer is the body voice; Pinyon Script is the
/// display face used for the caption, as in the reference HTML.
abstract final class AppTypography {
  static const String bodyFamily = 'Switzer';
  static const String displayFamily = 'PinyonScript';

  /// `.brand` — 15px, weight 300, uppercase, letter-spacing .46em.
  static const double brandFontSize = 15;
  static const double brandLetterSpacingEm = 0.46;
  static const TextStyle brand = TextStyle(
    fontFamily: bodyFamily,
    fontSize: brandFontSize,
    fontWeight: FontWeight.w300,
    letterSpacing: brandFontSize * brandLetterSpacingEm,
    height: 1.5,
    color: AppColors.foreground,
  );

  /// `.digit` — 88px, weight 500, line-height 1.
  static const double digitFontSize = 88;
  static const TextStyle digit = TextStyle(
    fontFamily: bodyFamily,
    fontSize: digitFontSize,
    fontWeight: FontWeight.w500,
    height: 1,
    leadingDistribution: TextLeadingDistribution.even,
    color: AppColors.digit,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  /// `.caption` — Pinyon Script 27px, weight 400.
  static const TextStyle caption = TextStyle(
    fontFamily: displayFamily,
    fontSize: 27,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: AppColors.foreground,
  );

  static const TextStyle body = TextStyle(
    fontFamily: bodyFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: AppColors.foreground,
  );
}
