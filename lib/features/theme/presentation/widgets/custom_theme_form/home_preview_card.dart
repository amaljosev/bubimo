// lib/features/theme/presentation/widgets/custom_theme_form/home_preview_card.dart

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../domain/entities/rgba_color.dart';

/// A miniature, self-contained mock-up of the Home Screen (Diary tab),
/// themed entirely from the in-memory field values currently being
/// edited on the Create Custom Theme screen.
///
/// Mirrors the real [HomePage] as closely as a fixed-height card
/// allows: a header image with the "Diary" title sitting near its top
/// (not a bottom-anchored caption), a gradient just strong enough to
/// keep the title legible, an All/Favorites segmented pill below it,
/// and a short stack of diary-entry-style rows — date column on the
/// left, rounded accent-tinted card on the right with mood + title +
/// preview text — instead of an abstract two-card grid.
///
/// Deliberately does NOT build a real `ThemeData`/`Theme.of(context)`
/// and does NOT touch [AppThemeCubit] — applying the theme globally
/// happens only when the user later taps "Apply Theme" back on the
/// Theme Switcher screen (per spec: "Saving a theme should not
/// automatically apply it"). This widget instead wraps its own content
/// in a local `Theme` override scoped to just this card, so live edits
/// reflect instantly without any global side effect.
class HomePreviewCard extends StatelessWidget {
  final RgbaColor primaryColor;
  final RgbaColor backgroundColor;
  final RgbaColor accentColor;
  final String fontFamily;
  final String? headerImagePath;
  final String themeName;

  const HomePreviewCard({
    super.key,
    required this.primaryColor,
    required this.backgroundColor,
    required this.accentColor,
    required this.fontFamily,
    required this.headerImagePath,
    required this.themeName,
  });

  static const List<_PreviewEntry> _sampleEntries = [
    _PreviewEntry(
      day: '07',
      weekday: 'Tue',
      mood: '😄',
      moodLabel: 'HAPPY',
      title: 'test',
      preview:
          'Lorem Ipsum is simply dummy text of the printing and typesetting industry.',
    ),
    _PreviewEntry(
      day: '05',
      weekday: 'Sun',
      mood: null,
      moodLabel: null,
      title: 'new',
      preview:
          'Lorem Ipsum is simply dummy text of the printing and typesetting industry.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final bg = backgroundColor.toColor();
    final primary = primaryColor.toColor();
    final accent = accentColor.toColor();
    final brightness =
        bg.computeLuminance() < 0.5 ? Brightness.dark : Brightness.light;
    final onSurface =
        brightness == Brightness.dark ? Colors.white : Colors.black87;
    final onSurfaceMuted = onSurface.withValues(alpha: 0.6);

    final textTheme = GoogleFonts.getTextTheme(
      fontFamily,
      brightness == Brightness.dark
          ? ThemeData(brightness: Brightness.dark).textTheme
          : ThemeData(brightness: Brightness.light).textTheme,
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Container(
        height: 380,
        color: bg,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _PreviewHeader(
              imagePath: headerImagePath,
              primaryColor: primary,
              textTheme: textTheme,
            ),
            const SizedBox(height: 12),
            Center(
              child: _PreviewSegmentedControl(
                primaryColor: primary,
                onSurface: onSurface,
                textTheme: textTheme,
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  for (final entry in _sampleEntries) ...[
                    _PreviewDiaryRow(
                      entry: entry,
                      accentColor: accent,
                      onSurface: onSurface,
                      onSurfaceMuted: onSurfaceMuted,
                      textTheme: textTheme,
                    ),
                    const SizedBox(height: 8),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PreviewEntry {
  final String day;
  final String weekday;
  final String? mood;
  final String? moodLabel;
  final String title;
  final String preview;

  const _PreviewEntry({
    required this.day,
    required this.weekday,
    required this.mood,
    required this.moodLabel,
    required this.title,
    required this.preview,
  });
}

/// Header block: image (or a primary-colored fallback) behind a
/// top-to-bottom gradient with the "Diary" title placed roughly a
/// third of the way down — matching the real collapsing SliverAppBar's
/// title position rather than a bottom-anchored caption.
class _PreviewHeader extends StatelessWidget {
  final String? imagePath;
  final Color primaryColor;
  final TextTheme textTheme;

  const _PreviewHeader({
    required this.imagePath,
    required this.primaryColor,
    required this.textTheme,
  });

  @override
  Widget build(BuildContext context) {
    final path = imagePath;

    return SizedBox(
      height: 150,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (path != null)
            _headerImage(path)
          else
            ColoredBox(color: primaryColor.withValues(alpha: 0.85)),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.35),
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.45),
                ],
              ),
            ),
          ),
          Align(
            alignment: const Alignment(0, -0.35),
            child: Text(
              'Diary',
              style: textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _headerImage(String path) {
    if (path.startsWith('assets/')) {
      return Image.asset(path, fit: BoxFit.cover);
    }
    return Image.file(File(path), fit: BoxFit.cover);
  }
}

/// Rounded-pill All/Favorites control, mirroring the real
/// `SegmentedButton` look: filled+checked "All" segment in a soft tint
/// of the primary color, outlined "Favorites" segment beside it.
class _PreviewSegmentedControl extends StatelessWidget {
  final Color primaryColor;
  final Color onSurface;
  final TextTheme textTheme;

  const _PreviewSegmentedControl({
    required this.primaryColor,
    required this.onSurface,
    required this.textTheme,
  });

  @override
  Widget build(BuildContext context) {
    final labelStyle = textTheme.labelMedium?.copyWith(
      color: onSurface,
      fontWeight: FontWeight.w600,
    );

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: onSurface.withValues(alpha: 0.25)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: primaryColor.withValues(alpha: 0.35),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check, size: 14, color: onSurface),
                const SizedBox(width: 4),
                Text('All', style: labelStyle),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.favorite, size: 14, color: onSurface),
                const SizedBox(width: 4),
                Text('Favorites', style: labelStyle),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// A single diary row: bold date number + weekday on the left, a
/// rounded accent-tinted card on the right with an optional mood row,
/// a title, and a 2-line preview — matching [DiaryListItem]'s layout.
class _PreviewDiaryRow extends StatelessWidget {
  final _PreviewEntry entry;
  final Color accentColor;
  final Color onSurface;
  final Color onSurfaceMuted;
  final TextTheme textTheme;

  const _PreviewDiaryRow({
    required this.entry,
    required this.accentColor,
    required this.onSurface,
    required this.onSurfaceMuted,
    required this.textTheme,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 32,
          child: Column(
            children: [
              Text(
                entry.day,
                style: textTheme.titleSmall?.copyWith(
                  color: onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                entry.weekday,
                style: textTheme.labelSmall?.copyWith(color: onSurfaceMuted),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (entry.mood != null) ...[
                  Row(
                    children: [
                      Text(entry.mood!, style: const TextStyle(fontSize: 12)),
                      const SizedBox(width: 4),
                      Text(
                        entry.moodLabel ?? '',
                        style: textTheme.labelSmall?.copyWith(
                          color: onSurface,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                ],
                Text(
                  entry.title,
                  style: textTheme.bodyMedium?.copyWith(
                    color: onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  entry.preview,
                  style: textTheme.bodySmall?.copyWith(color: onSurfaceMuted),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}