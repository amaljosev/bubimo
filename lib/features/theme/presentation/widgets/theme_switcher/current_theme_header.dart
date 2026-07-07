// lib/features/theme/presentation/widgets/theme_switcher/current_theme_header.dart

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../domain/entities/app_theme_data.dart';

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
        borderRadius: BorderRadius.circular(20),
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
              child: theme.isHeaderImageAsset
                  ? Image.asset(headerImagePath, fit: BoxFit.cover)
                  : Image.file(File(headerImagePath), fit: BoxFit.cover),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
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
                      Text(
                        theme.name,
                        style: GoogleFonts.getFont(
                          theme.fontFamily,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    _Dot(color: theme.primaryColor.toColor()),
                    const SizedBox(width: 4),
                    _Dot(color: theme.accentColor.toColor()),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  final Color color;

  const _Dot({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.black12),
      ),
    );
  }
}
