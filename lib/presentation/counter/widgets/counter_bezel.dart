import 'package:flutter/widgets.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_dimensions.dart';

/// The subtle metallic-gray frame around the flip counter (`.bezel`).
class CounterBezel extends StatelessWidget {
  const CounterBezel({super.key, required this.child});

  final Widget child;

  static const BorderRadius _radius = BorderRadius.all(Radius.circular(AppDimensions.radiusOuter));

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        borderRadius: _radius,
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.bezelTop, AppColors.bezelMid, AppColors.bezelBottom],
          stops: [0, 0.55, 1],
        ),
        boxShadow: [
          // 0 2px 6px rgba(17,17,17,.05)
          BoxShadow(color: AppColors.bezelShadowNear, offset: Offset(0, 2), blurRadius: 6),
          // 0 32px 52px -30px rgba(17,17,17,.38)
          BoxShadow(
            color: AppColors.bezelShadowFar,
            offset: Offset(0, 32),
            blurRadius: 52,
            spreadRadius: -30,
          ),
        ],
      ),
      child: CustomPaint(
        foregroundPainter: const _InsetHighlightPainter(),
        child: Padding(padding: const EdgeInsets.all(AppDimensions.bezelPadding), child: child),
      ),
    );
  }
}

/// Flutter has no inset box-shadow, so `inset 0 1px 1px rgba(255,255,255,.9)`
/// is drawn as the sliver between the frame and itself shifted down by 1px.
class _InsetHighlightPainter extends CustomPainter {
  const _InsetHighlightPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final outer = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(AppDimensions.radiusOuter),
    );
    final highlight = Path.combine(
      PathOperation.difference,
      Path()..addRRect(outer),
      Path()..addRRect(outer.shift(const Offset(0, 1))),
    );
    canvas
      ..save()
      ..clipRRect(outer)
      ..drawPath(
        highlight,
        Paint()
          ..color = AppColors.bezelHighlight
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 0.5),
      )
      ..restore();
  }

  @override
  bool shouldRepaint(_InsetHighlightPainter oldDelegate) => false;
}
