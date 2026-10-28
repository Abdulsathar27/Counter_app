import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_dimensions.dart';
import 'line_icons.dart';

/// One of the round bottom controls (`.ctrl`): white disc, hairline border,
/// soft shadow, and a 1px press-down.
class CounterControlButton extends StatefulWidget {
  const CounterControlButton({
    super.key,
    required this.glyph,
    required this.semanticLabel,
    required this.onPressed,
    this.toggled,
    this.iconColor = AppColors.foreground,
  });

  final LineIconGlyph glyph;
  final String semanticLabel;
  final VoidCallback? onPressed;

  /// Non-null for toggle controls; exposed to assistive tech as pressed state.
  final bool? toggled;
  final Color iconColor;

  @override
  State<CounterControlButton> createState() => _CounterControlButtonState();
}

class _CounterControlButtonState extends State<CounterControlButton> {
  bool _pressed = false;
  bool _focused = false;

  void _setPressed(bool value) {
    if (_pressed != value) setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null;
    return Semantics(
      button: true,
      enabled: enabled,
      toggled: widget.toggled,
      label: widget.semanticLabel,
      excludeSemantics: true,
      onTap: widget.onPressed,
      child: FocusableActionDetector(
        enabled: enabled,
        mouseCursor: enabled ? SystemMouseCursors.click : MouseCursor.defer,
        onShowFocusHighlight: (value) => setState(() => _focused = value),
        actions: {
          ActivateIntent: CallbackAction<ActivateIntent>(onInvoke: (_) => widget.onPressed?.call()),
        },
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: enabled ? (_) => _setPressed(true) : null,
          onTapUp: enabled ? (_) => _setPressed(false) : null,
          onTapCancel: () => _setPressed(false),
          onTap: widget.onPressed,
          child: _FocusRing(
            visible: _focused,
            child: AnimatedContainer(
              duration: AppMotion.press,
              curve: AppMotion.pressCurve,
              width: AppDimensions.controlSize,
              height: AppDimensions.controlSize,
              transform: Matrix4.translationValues(0, _pressed ? 1 : 0, 0),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.surface,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.divider),
                boxShadow: [
                  _pressed
                      // 0 4px 10px -6px rgba(17,17,17,.22)
                      ? const BoxShadow(
                        color: AppColors.controlShadowPressed,
                        offset: Offset(0, 4),
                        blurRadius: 10,
                        spreadRadius: -6,
                      )
                      // 0 10px 22px -10px rgba(17,17,17,.14)
                      : const BoxShadow(
                        color: AppColors.controlShadow,
                        offset: Offset(0, 10),
                        blurRadius: 22,
                        spreadRadius: -10,
                      ),
                ],
              ),
              child: LineIcon(widget.glyph, color: widget.iconColor),
            ),
          ),
        ),
      ),
    );
  }
}

/// `:focus-visible` outline: 2px solid secondary, offset by [offset].
class _FocusRing extends StatelessWidget {
  const _FocusRing({required this.visible, required this.child});

  final bool visible;
  final Widget child;

  static const double offset = AppDimensions.controlFocusOffset;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        child,
        if (visible)
          const Positioned(
            left: -offset - AppDimensions.focusRingWidth,
            top: -offset - AppDimensions.focusRingWidth,
            right: -offset - AppDimensions.focusRingWidth,
            bottom: -offset - AppDimensions.focusRingWidth,
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
