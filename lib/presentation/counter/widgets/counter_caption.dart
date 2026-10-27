import 'package:flutter/widgets.dart';

import '../../../app/theme/app_typography.dart';
import '../../../core/constants/app_constants.dart';

class CounterCaption extends StatelessWidget {
  const CounterCaption({super.key, this.text = AppConstants.caption});

  final String text;

  @override
  Widget build(BuildContext context) {
    // The counter's own label already says "Tap to count", so the caption is
    // hidden from screen readers to avoid announcing it twice.
    return ExcludeSemantics(
      child: Text(text, textAlign: TextAlign.center, style: AppTypography.caption),
    );
  }
}
