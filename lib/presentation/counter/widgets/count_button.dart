import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_dimensions.dart';
import 'line_icons.dart';

/// The round fingerprint button that counts. A [GestureDetector] drives a
/// ripple that spreads from the touch point and fades out, and the disc presses
/// down 1px like the bottom controls.
class CountButton extends StatefulWidget {
  const CountButton({super.key, required this.semanticLabel, required this.onPressed});

  final String semanticLabel;
  final VoidCallback onPressed;

  @override
  State<CountButton> createState() => _CountButtonState();
}

class _CountButtonState extends State<CountButton> with SingleTickerProviderStateMixin {
  late final AnimationController _ripple = AnimationController(
    vsync: this,
    duration: AppMotion.ripple,
  );
  late final Animation<double> _rippleProgress = CurvedAnimation(
    parent: _ripple,
    curve: AppMotion.rippleCurve,
  );

  static const Offset _center = Offset(
    AppDimensions.countButtonSize / 2,
    AppDimensions.countButtonSize / 2,
  );

  Offset _origin = _center;
  bool _pressed = false;
  bool _focused = false;

  void _setPressed(bool value) {
    if (_pressed != value) setState(() => _pressed = value);
  }

  /// Every tap restarts the ripple, so rapid taps each get their own. It is
  /// skipped when the platform asks for reduced motion.
  void _startRipple(Offset origin) {
    if (MediaQuery.maybeDisableAnimationsOf(context) ?? false) return;
    _origin = origin;
    _ripple.forward(from: 0);
  }

  void _activate() {
    _startRipple(_center);
    widget.onPressed();
  }

  @override
  void dispose() {
    _ripple.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: widget.semanticLabel,
      excludeSemantics: true,
      onTap: widget.onPressed,
      child: FocusableActionDetector(
        mouseCursor: SystemMouseCursors.click,
        onShowFocusHighlight: (value) => setState(() => _focused = value),
        actions: {ActivateIntent: CallbackAction<ActivateIntent>(onInvoke: (_) => _activate())},
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (details) {
            _setPressed(true);
            _startRipple(details.localPosition);
          },
          onTapUp: (_) => _setPressed(false),
          onTapCancel: () => _setPressed(false),
          onTap: widget.onPressed,
          child: _FocusRing(
            visible: _focused,
            child: AnimatedContainer(
              duration: AppMotion.press,
              curve: AppMotion.pressCurve,
              width: AppDimensions.countButtonSize,
              height: AppDimensions.countButtonSize,
              transform: Matrix4.translationValues(0, _pressed ? 1 : 0, 0),
              decoration: BoxDecoration(
                color: AppColors.surface,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.divider),
                boxShadow: [
                  _pressed
                      ? const BoxShadow(
                        color: AppColors.controlShadowPressed,
                        offset: Offset(0, 4),
                        blurRadius: 10,
                        spreadRadius: -6,
                      )
                      : const BoxShadow(
                        color: AppColors.controlShadow,
                        offset: Offset(0, 10),
                        blurRadius: 22,
                        spreadRadius: -10,
                      ),
                ],
              ),
              child: ClipOval(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned.fill(
                      child: RepaintBoundary(
                        child: CustomPaint(
                          painter: _RipplePainter(progress: _rippleProgress, origin: () => _origin),
                        ),
                      ),
                    ),
                    const LineIcon(
                      LineIconGlyph.fingerprint,
                      color: AppColors.foreground,
                      size: AppDimensions.countButtonIconSize,
                      strokeWidth: AppDimensions.countButtonIconStroke,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A circle that grows from [origin] until it covers the disc, fading out.
class _RipplePainter extends CustomPainter {
  _RipplePainter({required this.progress, required this.origin}) : super(repaint: progress);

  final Animation<double> progress;
  final Offset Function() origin;

  @override
  void paint(Canvas canvas, Size size) {
    final t = progress.value;
    if (t == 0 || t == 1) return;
    final from = origin();
    // Far enough to reach the opposite edge from any touch point.
    final maxRadius = (size.center(Offset.zero) - from).distance + size.shortestSide / 2;
    final paint = Paint()..color = AppColors.ripple.withValues(alpha: AppColors.ripple.a * (1 - t));
    canvas.drawCircle(from, maxRadius * t, paint);
  }

  @override
  bool shouldRepaint(_RipplePainter oldDelegate) => false;
}

/// `:focus-visible` outline: 2px solid secondary, offset from the disc.
class _FocusRing extends StatelessWidget {
  const _FocusRing({required this.visible, required this.child});

  final bool visible;
  final Widget child;

  static const double _inset = -(AppDimensions.controlFocusOffset + AppDimensions.focusRingWidth);

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        child,
        if (visible)
          const Positioned(
            left: _inset,
            top: _inset,
            right: _inset,
            bottom: _inset,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.fromBorderSide(
                    BorderSide(color: AppColors.secondary, width: AppDimensions.focusRingWidth),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
