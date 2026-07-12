// lib/features/theme/presentation/widgets/custom_theme_form/home_preview_card.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../domain/entities/rgba_color.dart';
import '../shared/theme_header_image.dart';


class HomePreviewCard extends StatelessWidget {
  final RgbaColor primaryColor;
  final RgbaColor secondaryColor;
  final RgbaColor surfaceColor;
  final RgbaColor backgroundColor;
  final RgbaColor textColor;
  final bool isDark;
  final String fontFamily;
  final String? headerImagePath;

  const HomePreviewCard({
    super.key,
    required this.primaryColor,
    required this.secondaryColor,
    required this.surfaceColor,
    required this.backgroundColor,
    required this.textColor,
    required this.isDark,
    required this.fontFamily,
    required this.headerImagePath,
  });

  /// Realistic student-diary sample content, in place of the previous
  /// lorem-ipsum placeholder text — two consecutive days (Nov 10 and
  /// 11) so the month/day pairing in [_PreviewDiaryRow] is internally
  /// consistent.
  static const List<_PreviewEntry> _sampleEntries = [
    _PreviewEntry(
      month: 'NOV',
      day: '11',
      mood: '😄',
      moodLabel: 'HAPPY',
      isFavorite: true,
      title: 'Finished my chemistry assignment early',
      preview:
          'Got through the whole titration lab write-up before dinner for '
          'once. Ms. Rivera said our group\'s data was the cleanest in class.',
    ),
    _PreviewEntry(
      month: 'NOV',
      day: '10',
      mood: '😴',
      moodLabel: 'TIRED',
      isFavorite: false,
      title: 'Late night studying for the history quiz',
      preview:
          'Stayed up way too late going over the timeline for tomorrow\'s '
          'quiz. Hoping all those flashcards actually stick this time.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final bg = backgroundColor.toColor();
    final primary = primaryColor.toColor();
    final surface = surfaceColor.toColor();
    final onSurface = textColor.toColor();
    final onSurfaceMuted = onSurface.withValues(alpha: 0.6);
    final onPrimary =
        ThemeData.estimateBrightnessForColor(primary) == Brightness.dark
            ? Colors.white
            : Colors.black87;

    final textTheme = GoogleFonts.getTextTheme(
      fontFamily,
      isDark
          ? ThemeData(brightness: Brightness.dark).textTheme
          : ThemeData(brightness: Brightness.light).textTheme,
    ).apply(bodyColor: onSurface, displayColor: onSurface);

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Container(
        height: 420,
        color: bg,
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _PreviewHeader(
                  imagePath: headerImagePath,
                  primaryColor: primary,
                  textTheme: textTheme,
                ),
                const SizedBox(height: 12),
                Center(
                  child: _PreviewFavoritesFilterToggle(
                    primaryColor: primary,
                    surfaceColor: surface,
                    onSurfaceVariant: onSurfaceMuted,
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 72),
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      for (final entry in _sampleEntries) ...[
                        _PreviewDiaryRow(
                          entry: entry,
                          surfaceColor: surface,
                          primaryColor: primary,
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
            // Floating action button preview — shows exactly how
            // Primary color renders as a real, tappable-looking
            // button, per the requirement that users be able to see
            // button colors directly rather than only inferring them
            // from a swatch.
            Positioned(
              right: 16,
              bottom: 16,
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: primary,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.25),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Icon(Icons.add, color: onPrimary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PreviewEntry {
  final String month;
  final String day;
  final String? mood;
  final String? moodLabel;
  final bool isFavorite;
  final String title;
  final String preview;

  const _PreviewEntry({
    required this.month,
    required this.day,
    required this.mood,
    required this.moodLabel,
    required this.isFavorite,
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
            ThemeHeaderImage.fromPath(path)
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
}

/// Field-for-field mirror of the real `_FavoritesFilterToggle`: same
/// fixed 108px segment width, same sliding-capsule highlight (a
/// `Positioned` capsule in `surfaceColor` with a soft shadow, snapped
/// to whichever segment is active — static here at "All" selected,
/// since the live preview has no real filter state to reflect), same
/// track background (`surfaceContainerHighest`-equivalent — this
/// preview passes [surfaceColor] at 50% alpha, since `theme_mapper.dart`
/// maps `AppThemeData.surfaceColor` directly onto
/// `ColorScheme.surfaceContainerHighest`, the exact source the real
/// widget reads from), same `favorite_rounded` icon shown only on the
/// Favorites segment, and the same `primary`/`onSurfaceVariant` text
/// coloring for selected/unselected.
///
/// Takes colors as explicit params rather than reading
/// `Theme.of(context).colorScheme` like the real widget does, since
/// this preview deliberately never builds a real themed `Theme` (see
/// [HomePreviewCard]'s doc comment) — the values passed in are exactly
/// what the real widget would read from the eventual `ColorScheme` once
/// this custom theme is applied.
class _PreviewFavoritesFilterToggle extends StatelessWidget {
  final Color primaryColor;
  final Color surfaceColor;
  final Color onSurfaceVariant;

  const _PreviewFavoritesFilterToggle({
    required this.primaryColor,
    required this.surfaceColor,
    required this.onSurfaceVariant,
  });

  static const _height = 40.0;
  static const _trackPadding = 4.0;
  static const _segmentWidth = 108.0;
  static const _radius = Radius.circular(_height / 2);

  @override
  Widget build(BuildContext context) {
    const trackWidth = _segmentWidth * 2 + _trackPadding * 2;

    return Container(
      height: _height,
      width: trackWidth,
      padding: const EdgeInsets.all(_trackPadding),
      decoration: BoxDecoration(
        color: surfaceColor.withValues(alpha: 0.5),
        borderRadius: BorderRadius.all(_radius),
      ),
      child: Stack(
        children: [
          // "All" is always the active segment in this static preview
          // — left: 0 — since there's no real filter state to reflect.
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            width: _segmentWidth,
            child: Container(
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: BorderRadius.all(_radius),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 6,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
            ),
          ),
          Row(
            children: [
              _buildOption(label: 'All', icon: null, isSelected: true),
              _buildOption(
                label: 'Favorites',
                icon: Icons.favorite_rounded,
                isSelected: false,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOption({
    required String label,
    required IconData? icon,
    required bool isSelected,
  }) {
    final foreground = isSelected ? primaryColor : onSurfaceVariant;

    return SizedBox(
      width: _segmentWidth,
      height: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 15, color: foreground),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: TextStyle(
              color: foreground,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

/// A single diary row: date column mirroring the real `DateTile` (month
/// abbreviation on top, big bold day number in `colorScheme.primary`
/// below, left-aligned) on the left, and a card on the right mirroring
/// `DiaryListItem` exactly — same padding (14), same corner radius
/// (18), NO accent border, showing an optional mood-emoji-and-label row
/// (with a favorite heart icon on the same line via a trailing
/// `Spacer()`, matching the real widget), then the title
/// (`titleSmall`), then a 2-line preview (`bodyMedium`, muted).
class _PreviewDiaryRow extends StatelessWidget {
  final _PreviewEntry entry;
  final Color surfaceColor;
  final Color primaryColor;
  final Color onSurface;
  final Color onSurfaceMuted;
  final TextTheme textTheme;

  const _PreviewDiaryRow({
    required this.entry,
    required this.surfaceColor,
    required this.primaryColor,
    required this.onSurface,
    required this.onSurfaceMuted,
    required this.textTheme,
  });

  @override
  Widget build(BuildContext context) {
    // Matches DiaryListItem's card exactly: 14 padding, 18 radius, no
    // left accent border.
    final card = Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (entry.mood != null) ...[
                Text(entry.mood!, style: const TextStyle(fontSize: 14)),
                const SizedBox(width: 4),
                Text(
                  entry.moodLabel ?? '',
                  style: textTheme.labelSmall?.copyWith(
                    color: onSurfaceMuted,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
              const Spacer(),
              if (entry.isFavorite)
                Icon(Icons.favorite, size: 14, color: primaryColor),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            entry.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textTheme.titleSmall?.copyWith(color: onSurface),
          ),
          const SizedBox(height: 2),
          Text(
            entry.preview,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: textTheme.bodyMedium?.copyWith(color: onSurfaceMuted),
          ),
        ],
      ),
    );

    // Matches the real DateTile exactly (the variant Home's day-grouped
    // list actually uses, not DiaryListItem's own day-first/weekday-
    // below column): 56-wide, left-aligned, labelSmall muted month
    // abbreviation on top, headlineMedium bold day number in
    // primaryColor below.
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 56,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                entry.month,
                style: textTheme.labelSmall?.copyWith(
                  color: onSurfaceMuted,
                  letterSpacing: 0.5,
                ),
              ),
              Text(
                entry.day,
                style: textTheme.headlineMedium?.copyWith(
                  color: primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(child: card),
      ],
    );
  }
}