import 'package:flutter/widgets.dart';

import '../../../app/theme/app_typography.dart';
import '../../../core/constants/app_constants.dart';

/// The centred, widely tracked MUSMILES wordmark.
class BrandHeader extends StatelessWidget {
  const BrandHeader({super.key, this.name = AppConstants.brandName});

  final String name;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      header: true,
      label: name,
      excludeSemantics: true,
      child: Padding(
        // Letter spacing trails the last glyph too; pad the start by the same
        // amount so the word centres optically, as `.brand` does.
        padding: const EdgeInsetsDirectional.only(
          start: AppTypography.brandFontSize * AppTypography.brandLetterSpacingEm,
        ),
        child: Text(
          name.toUpperCase(),
          textAlign: TextAlign.center,
          style: AppTypography.brand,
          maxLines: 1,
        ),
      ),
    );
  }
}
