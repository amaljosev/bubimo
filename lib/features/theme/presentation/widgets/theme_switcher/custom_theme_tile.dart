// lib/features/theme/presentation/widgets/theme_switcher/custom_theme_tile.dart

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../domain/entities/app_theme_data.dart';

/// A single custom theme row on the "Custom Themes" tab.
///
/// Like [BuiltInThemeTile], always renders [theme.name] in
/// [theme.fontFamily] regardless of the currently active app theme.
///
/// Unlike built-ins, applying is an explicit action — "Apply Theme"
/// must be tapped (per spec: saving/selecting a custom theme never
/// auto-applies it). Also exposes edit and delete affordances, since
/// custom themes (unlike built-ins) are user-owned and mutable.
class CustomThemeTile extends StatelessWidget {
  final AppThemeData theme;
  final bool isActive;
  final bool isEnabled;
  final VoidCallback onApply;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const CustomThemeTile({
    super.key,
    required this.theme,
    required this.isActive,
    required this.onApply,
    required this.onEdit,
    required this.onDelete,
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
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (headerImagePath != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.file(
                      File(headerImagePath),
                      width: 56,
                      height: 56,
                      fit: BoxFit.cover,
                    ),
                  )
                else
                  Container(
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
                  ),
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
                  Icon(Icons.check_circle, color: colorScheme.primary),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: FilledButton.tonal(
                    onPressed: isEnabled && !isActive ? onApply : null,
                    child: Text(isActive ? 'Applied' : 'Apply Theme'),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: isEnabled ? onEdit : null,
                  icon: const Icon(Icons.edit_outlined),
                  tooltip: 'Edit',
                ),
                IconButton(
                  onPressed: isEnabled ? onDelete : null,
                  icon: Icon(Icons.delete_outline, color: colorScheme.error),
                  tooltip: 'Delete',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
