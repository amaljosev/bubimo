// lib/features/theme/presentation/widgets/shared/theme_tile_card.dart

import 'package:flutter/material.dart';

import '../../../../../core/theme/theme_tokens.dart';

/// Shared card chrome for a single theme row on the Theme Switcher
/// screen: rounded card, a highlighted border when [isActive], a
/// leading visual (image or color swatch), the theme's name/font
/// labels, and an optional trailing widget or footer row.
///
/// Extracted from [BuiltInThemeTile] and [CustomThemeTile], which
/// previously duplicated this entire structure — built-in tiles apply
/// instantly on tap ([onTap]), while custom tiles require an explicit
/// "Apply Theme" action and expose edit/delete, so those two widgets
/// stay separate but now only own their tap behavior and
/// footer/trailing content, not the surrounding card.
class ThemeTileCard extends StatelessWidget {
  final bool isActive;
  final bool isEnabled;
  final VoidCallback? onTap;
  final Widget leading;
  final Widget titleAndSubtitle;
  final Widget? trailing;
  final Widget? footer;

  const ThemeTileCard({
    super.key,
    required this.isActive,
    required this.leading,
    required this.titleAndSubtitle,
    this.isEnabled = true,
    this.onTap,
    this.trailing,
    this.footer,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final content = Padding(
      padding: const EdgeInsets.all(ThemeSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              leading,
              const SizedBox(width: 14),
              Expanded(child: titleAndSubtitle),
              ?trailing,
            ],
          ),
          if (footer != null) ...[
            const SizedBox(height: 10),
            footer!,
          ],
        ],
      ),
    );

    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: ThemeSpacing.lg,
        vertical: 6,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ThemeRadii.xl),
        side: isActive
            ? BorderSide(color: colorScheme.primary, width: 2)
            : BorderSide.none,
      ),
      clipBehavior: Clip.antiAlias,
      child: onTap != null
          ? InkWell(onTap: isEnabled ? onTap : null, child: content)
          : content,
    );
  }
}
