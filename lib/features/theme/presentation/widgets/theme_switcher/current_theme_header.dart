// lib/features/theme/presentation/widgets/theme_switcher/current_theme_header.dart

import 'package:flutter/material.dart';

import '../../../../../core/theme/theme_tokens.dart';
import '../../../domain/entities/app_theme_data.dart';
import '../shared/theme_color_swatch.dart';
import '../shared/theme_font_label.dart';
import '../shared/theme_header_image.dart';

/// Displays the currently applied theme at the top of the Theme
/// Switcher screen: name, header image (if any), and a small color
/// swatch row.
///
/// Uses [AppThemeData.fontFamily] directly for the theme name label —
/// this is the one place showing the *active* theme's own font is
/// actually correct (it's describing that specific theme, not a list
/// item that must stay font-stable across theme changes).
class CurrentThemeHeader extends StatelessWidget {
  final AppThemeData theme;

  const CurrentThemeHeader({super.key, required this.theme});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final headerImagePath = theme.headerImagePath;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(ThemeRadii.xxl),
        color: colorScheme.surfaceContainerHighest,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (headerImagePath != null)
            SizedBox(
              height: 110,
              width: double.infinity,
              child: ThemeHeaderImage.fromTheme(theme),
            ),
          Padding(
            padding: const EdgeInsets.all(ThemeSpacing.lg),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Currently applied',
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                      ),
                      const SizedBox(height: 2),
                      ThemeFontLabel(
                        theme.name,
                        fontFamily: theme.fontFamily,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
                      ),
                    ],
                  ),
                ),
                ThemeColorDotRow(
                  colors: [
                    theme.primaryColor.toColor(),
                    theme.accentColor.toColor(),
                  ],
                  dotSize: 22,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
