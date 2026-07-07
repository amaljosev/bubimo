// lib/features/theme/presentation/widgets/theme_switcher/built_in_theme_tile.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../domain/entities/app_theme_data.dart';

/// A single built-in theme row on the "App Themes" tab.
///
/// Always renders [theme.name] in [theme.fontFamily] — this label's
/// font must NEVER change when a different theme becomes active
/// elsewhere in the app, so users can visually tell themes apart by
/// their font in this list regardless of what's currently applied. This
/// is why the tile reads straight from [theme] rather than from
/// `Theme.of(context)`.
///
/// Tapping applies the theme immediately (built-ins can't be edited, so
/// there's no separate "Apply" confirmation step, unlike custom
/// themes).
class BuiltInThemeTile extends StatelessWidget {
  final AppThemeData theme;
  final bool isActive;
  final bool isEnabled;
  final VoidCallback onTap;

  const BuiltInThemeTile({
    super.key,
    required this.theme,
    required this.isActive,
    required this.onTap,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final headerImagePath = theme.headerImagePath;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: isActive
            ? BorderSide(color: colorScheme.primary, width: 2)
            : BorderSide.none,
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: isEnabled ? onTap : null,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              if (headerImagePath != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(
                    headerImagePath,
                    width: 56,
                    height: 56,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Container(
                      width: 56,
                      height: 56,
                      color: colorScheme.surfaceContainerHighest,
                      child: Icon(Icons.image_outlined, color: colorScheme.outline),
                    ),
                  ),
                )
              else
                _ColorSwatchGroup(theme: theme),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      theme.name,
                      style: GoogleFonts.getFont(
                        theme.fontFamily,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      theme.fontFamily,
                      style: GoogleFonts.getFont(
                        theme.fontFamily,
                        fontSize: 13,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (isActive)
                Icon(Icons.check_circle, color: colorScheme.primary)
              else
                _ColorSwatchGroup(theme: theme, compact: true),
            ],
          ),
        ),
      ),
    );
  }
}

class _ColorSwatchGroup extends StatelessWidget {
  final AppThemeData theme;
  final bool compact;

  const _ColorSwatchGroup({required this.theme, this.compact = false});

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _dot(theme.primaryColor.toColor()),
          const SizedBox(width: 3),
          _dot(theme.accentColor.toColor()),
        ],
      );
    }

    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        gradient: LinearGradient(
          colors: [
            theme.primaryColor.toColor(),
            theme.accentColor.toColor(),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    );
  }

  Widget _dot(Color color) {
    return Container(
      width: 14,
      height: 14,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.black12),
      ),
    );
  }
}
