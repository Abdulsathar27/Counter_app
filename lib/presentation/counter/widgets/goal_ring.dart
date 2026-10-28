import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_dimensions.dart';
import '../../../app/theme/app_typography.dart';

/// The count inside a ring that fills towards the goal.
///
/// The ring eases to each new [progress] (skipped when the platform asks for
/// reduced motion). It is display-only; counting is done by the fingerprint
/// button.
class GoalRing extends StatelessWidget {
  const GoalRing({
    super.key,
    required this.value,
    required this.label,
    required this.progress,
    required this.semanticLabel,
  });

  final String value;

  /// Shown under the count, e.g. "3 to go" or "goal reached".
  final String label;

  /// How full the ring is, from 0 to 1.
  final double progress;

  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    return Semantics(
      label: semanticLabel,
      liveRegion: true,
      excludeSemantics: true,
      child: SizedBox.square(
        dimension: AppDimensions.ringDiameter,
        child: TweenAnimationBuilder<double>(
          tween: Tween(end: progress),
          duration: reduceMotion ? Duration.zero : AppMotion.ring,
          curve: AppMotion.ringCurve,
          builder:
              (context, animated, child) =>
                  CustomPaint(painter: _RingPainter(animated), child: child),
          child: Center(
            child: SizedBox(
              width: AppDimensions.ringContentWidth,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Long values shrink to fit inside the ring.
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      value,
                      maxLines: 1,
                      style: AppTypography.count,
                      textScaler: TextScaler.noScaling,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.ringLabelGap),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      label,
                      maxLines: 1,
                      style: AppTypography.ringLabel,
                      textScaler: TextScaler.noScaling,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A dim full track with the progress arc on top, starting at 12 o'clock and
/// running clockwise.
class _RingPainter extends CustomPainter {
  const _RingPainter(this.progress);

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = AppDimensions.ringStroke;
    final rect = (Offset.zero & size).deflate(stroke / 2);
    final paint =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = stroke
          ..isAntiAlias = true;

    canvas.drawOval(rect, paint..color = AppColors.ringTrack);

    final sweep = progress.clamp(0.0, 1.0) * 2 * math.pi;
    if (sweep <= 0) return;
    paint
      ..color = AppColors.ringProgress
      // A full ring has no ends, so round caps would only matter mid-way.
      ..strokeCap = sweep >= 2 * math.pi ? StrokeCap.butt : StrokeCap.round;
    canvas.drawArc(rect, -math.pi / 2, sweep, false, paint);
  }

  @override
  bool shouldRepaint(_RingPainter oldDelegate) => oldDelegate.progress != progress;
}
