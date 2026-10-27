import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_dimensions.dart';
import '../../../app/theme/app_typography.dart';

/// Mechanical split-flap counter (`.counter`).
///
/// The current [value] is always painted on the two static flaps. When it
/// changes, the old upper flap folds down on the hinge to reveal the new upper
/// half, and the new lower flap lands over the old lower half. The widget only
/// animates; the value itself comes from the BLoC.
class FlipCounter extends StatefulWidget {
  const FlipCounter({
    super.key,
    required this.value,
    required this.semanticLabel,
    this.onTap,
    this.animate = true,
  });

  final String value;
  final String semanticLabel;
  final VoidCallback? onTap;

  /// When false, value changes are shown without a flip (e.g. initial load).
  final bool animate;

  @override
  State<FlipCounter> createState() => _FlipCounterState();
}

class _FlipCounterState extends State<FlipCounter> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: AppMotion.flip,
    value: 1,
  );
  late final Animation<double> _progress = CurvedAnimation(
    parent: _controller,
    curve: AppMotion.flipCurve,
  );

  late String _current = widget.value;
  late String _previous = widget.value;
  bool _focused = false;

  @override
  void didUpdateWidget(FlipCounter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value == _current) return;

    final reduceMotion = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    // A change that lands mid-flip settles the running flip first, so rapid
    // taps always fold from the value currently on the upper flap.
    _previous = _current;
    _current = widget.value;
    if (!widget.animate || reduceMotion) {
      _previous = _current;
      _controller.value = 1;
    } else {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onTap != null;
    return Semantics(
      button: true,
      enabled: enabled,
      label: widget.semanticLabel,
      excludeSemantics: true,
      onTap: widget.onTap,
      child: FocusableActionDetector(
        enabled: enabled,
        mouseCursor: enabled ? SystemMouseCursors.click : MouseCursor.defer,
        onShowFocusHighlight: (value) => setState(() => _focused = value),
        actions: {
          ActivateIntent: CallbackAction<ActivateIntent>(onInvoke: (_) => widget.onTap?.call()),
        },
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.onTap,
          child: _CounterFocusRing(
            visible: _focused,
            child: RepaintBoundary(
              child: ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(AppDimensions.radiusInner)),
                child: SizedBox(
                  width: AppDimensions.counterWidth,
                  height: AppDimensions.counterHeight,
                  child: ColoredBox(
                    color: AppColors.counterBase,
                    child: AnimatedBuilder(
                      animation: _progress,
                      builder: (context, _) => _buildFlaps(_progress.value),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFlaps(double t) {
    final settled = _controller.isCompleted;
    final firstHalf = t < 0.5;
    // 0 → 1 across each half of the flip.
    final phase = firstHalf ? t / 0.5 : (t - 0.5) / 0.5;
    final dim = 1 - AppMotion.flapMinBrightness;

    return Stack(
      fit: StackFit.expand,
      children: [
        // Lower static flap: the old value until the new lower flap covers it.
        _positionedHalf(top: false, child: _Flap.bottom(settled ? _current : _previous)),
        // Upper static flap: the new value, revealed as the old one folds away.
        _positionedHalf(top: true, child: _Flap.top(_current)),
        if (!settled && firstHalf)
          _positionedHalf(
            top: true,
            child: _Hinged(
              alignment: Alignment.bottomCenter,
              angle: phase * math.pi / 2,
              child: _Flap.top(_previous, shade: phase * dim),
            ),
          ),
        if (!settled && !firstHalf)
          _positionedHalf(
            top: false,
            child: _Hinged(
              alignment: Alignment.topCenter,
              angle: -(1 - phase) * math.pi / 2,
              child: _Flap.bottom(_current, shade: (1 - phase) * dim),
            ),
          ),
        const _Hinge(),
        const _Sheen(),
      ],
    );
  }

  static Widget _positionedHalf({required bool top, required Widget child}) {
    const half = AppDimensions.counterHeight / 2;
    return Positioned(left: 0, right: 0, top: top ? 0 : half, height: half, child: child);
  }
}

/// Rotates a flap around its hinge edge with the reference's 640px perspective.
class _Hinged extends StatelessWidget {
  const _Hinged({required this.alignment, required this.angle, required this.child});

  final Alignment alignment;
  final double angle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Transform(
      alignment: alignment,
      transform:
          Matrix4.identity()
            ..setEntry(3, 2, 1 / AppDimensions.counterPerspective)
            ..rotateX(angle),
      child: child,
    );
  }
}

/// One half of the card: gradient face, shadow, and half of the digit.
class _Flap extends StatelessWidget {
  const _Flap.top(this.value, {this.shade = 0}) : isTop = true;
  const _Flap.bottom(this.value, {this.shade = 0}) : isTop = false;

  final String value;
  final bool isTop;

  /// Opacity of the black overlay that stands in for `filter: brightness()`.
  final double shade;

  static const Radius _radius = Radius.circular(AppDimensions.radiusInner);

  @override
  Widget build(BuildContext context) {
    final face = ClipRect(
      child: Align(
        alignment: isTop ? Alignment.topCenter : Alignment.bottomCenter,
        heightFactor: 0.5,
        child: _Digit(value),
      ),
    );

    return DecoratedBox(
      decoration: isTop ? _topDecoration : _bottomDecoration,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (!isTop) const _BottomInsetShadow(),
          face,
          if (shade > 0) ColoredBox(color: Colors.black.withValues(alpha: shade)),
        ],
      ),
    );
  }

  // .flap--top: linear-gradient(180deg, #1d1d1d, #131313),
  // box-shadow 0 8px 12px -8px rgba(0,0,0,.7)
  static const BoxDecoration _topDecoration = BoxDecoration(
    borderRadius: BorderRadius.vertical(top: _radius),
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [AppColors.flapTopStart, AppColors.flapTopEnd],
    ),
    boxShadow: [
      BoxShadow(
        color: AppColors.flapTopShadow,
        offset: Offset(0, 8),
        blurRadius: 12,
        spreadRadius: -8,
      ),
    ],
  );

  // .flap--bottom: linear-gradient(180deg, #101010, #090909)
  static const BoxDecoration _bottomDecoration = BoxDecoration(
    borderRadius: BorderRadius.vertical(bottom: _radius),
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [AppColors.flapBottomStart, AppColors.flapBottomEnd],
    ),
  );
}

/// `inset 0 14px 18px -14px rgba(0,0,0,.9)` along the top of the lower flap.
class _BottomInsetShadow extends StatelessWidget {
  const _BottomInsetShadow();

  static const double _depth = 10;

  @override
  Widget build(BuildContext context) {
    return const Align(
      alignment: Alignment.topCenter,
      child: SizedBox(
        height: _depth,
        width: double.infinity,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [AppColors.flapBottomInset, Color(0x00000000)],
            ),
          ),
        ),
      ),
    );
  }
}

/// The full-height digit; each flap shows the half that falls inside it.
class _Digit extends StatelessWidget {
  const _Digit(this.value);

  final String value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: AppDimensions.counterWidth,
      height: AppDimensions.counterHeight,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppDimensions.digitHorizontalPadding),
          // Long values shrink to fit instead of overflowing the card.
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              maxLines: 1,
              softWrap: false,
              style: AppTypography.digit,
              textScaler: TextScaler.noScaling,
            ),
          ),
        ),
      ),
    );
  }
}

/// `.hinge`: a 3px dark seam with a 1px highlight above a 1px shadow.
class _Hinge extends StatelessWidget {
  const _Hinge();

  @override
  Widget build(BuildContext context) {
    return const Positioned(
      left: 0,
      right: 0,
      top: (AppDimensions.counterHeight - AppDimensions.hingeHeight) / 2,
      height: AppDimensions.hingeHeight,
      child: IgnorePointer(
        child: ColoredBox(
          color: AppColors.hinge,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 1, child: ColoredBox(color: AppColors.hingeHighlight)),
              SizedBox(height: 1, child: ColoredBox(color: AppColors.hingeShadow)),
            ],
          ),
        ),
      ),
    );
  }
}

/// `.counter::before`: a faint top-down sheen over the whole card.
class _Sheen extends StatelessWidget {
  const _Sheen();

  @override
  Widget build(BuildContext context) {
    return const IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.counterSheen, Color(0x00FFFFFF)],
            stops: [0, 0.42],
          ),
        ),
      ),
    );
  }
}

/// `.counter:focus-visible`: 2px outline offset 4px from the card.
class _CounterFocusRing extends StatelessWidget {
  const _CounterFocusRing({required this.visible, required this.child});

  final bool visible;
  final Widget child;

  static const double _inset = -(AppDimensions.counterFocusOffset + AppDimensions.focusRingWidth);

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
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
                  borderRadius: BorderRadius.all(
                    Radius.circular(AppDimensions.radiusInner - _inset),
                  ),
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
