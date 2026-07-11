// lib/features/theme/presentation/widgets/custom_theme_form/text_color_swatch_picker_sheet.dart

import 'package:flutter/material.dart';

import '../../../domain/entities/rgba_color.dart';

/// sync with `CustomThemeFormState.kMinTextContrastRatio`. Duplicated
/// as a `const` here (rather than imported) since this widget shouldn't
/// depend on the form's bloc/state part-file to stay independently
/// reusable/testable.
const double _kMinTextContrastRatio = 4.5;

/// A curated swatch-grid picker used ONLY for the Text color field.
///
/// Unlike [RgbaColorPickerSheet] (a freeform HSV/hex picker used for
/// the other 4 color fields), this sheet only offers a fixed set of
/// pre-defined swatches — and only shows the ones that already pass
/// [surfaceColor]. This prevents an invalid text-color pick at
/// selection time, rather than only flagging it afterward: the user
/// can no longer land on a hard-to-read combination by picking text
/// color first, since every swatch shown here is already safe against
/// the theme's current background/surface.
///
/// The currently-selected color (if it's one of the offered swatches)
/// is always visibly highlighted, per spec ("the currently selected
/// colors should always be highlighted in the picker").
///
/// If [initialColor] doesn't pass contrast against the current
/// background/surface (e.g. the user changed Background/Surface color
/// after already picking a Text color), it's excluded from the grid —
/// nothing in the grid is pre-selected in that case, and the existing
/// non-blocking warning banner on the form (see
/// `CustomThemeFormState.textColorWarning`) is what surfaces that to
/// the user, not this sheet.
class TextColorSwatchPickerSheet extends StatelessWidget {
  final RgbaColor initialColor;
  final RgbaColor backgroundColor;
  final RgbaColor surfaceColor;

  const TextColorSwatchPickerSheet({
    super.key,
    required this.initialColor,
    required this.backgroundColor,
    required this.surfaceColor,
  });

  static Future<RgbaColor?> show(
    BuildContext context, {
    required RgbaColor initialColor,
    required RgbaColor backgroundColor,
    required RgbaColor surfaceColor,
  }) {
    return showModalBottomSheet<RgbaColor>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => TextColorSwatchPickerSheet(
        initialColor: initialColor,
        backgroundColor: backgroundColor,
        surfaceColor: surfaceColor,
      ),
    );
  }

  /// The full curated candidate set — spans near-black/near-white
  /// neutrals plus a range of mid-tone hues, so there's always a
  /// reasonable spread of options that pass contrast regardless of
  /// whether the background/surface is light or dark.
  static const List<RgbaColor> _candidates = [
    // Neutrals — near-black through near-white.
    RgbaColor(red: 10, green: 10, blue: 12),
    RgbaColor(red: 24, green: 24, blue: 27),
    RgbaColor(red: 38, green: 38, blue: 42),
    RgbaColor(red: 55, green: 55, blue: 60),
    RgbaColor(red: 90, green: 90, blue: 96),
    RgbaColor(red: 130, green: 130, blue: 136),
    RgbaColor(red: 180, green: 180, blue: 186),
    RgbaColor(red: 225, green: 225, blue: 230),
    RgbaColor(red: 245, green: 245, blue: 248),
    RgbaColor(red: 255, green: 255, blue: 255),
    // Warm neutrals.
    RgbaColor(red: 32, green: 28, blue: 44),
    RgbaColor(red: 43, green: 24, blue: 20),
    RgbaColor(red: 40, green: 24, blue: 32),
    RgbaColor(red: 228, green: 229, blue: 245),
    // Hues — deep/dark variants (readable on light backgrounds).
    RgbaColor(red: 20, green: 40, blue: 90),
    RgbaColor(red: 80, green: 20, blue: 30),
    RgbaColor(red: 20, green: 70, blue: 45),
    RgbaColor(red: 90, green: 50, blue: 10),
    RgbaColor(red: 70, green: 20, blue: 80),
    RgbaColor(red: 10, green: 60, blue: 70),
    // Hues — light/pastel variants (readable on dark backgrounds).
    RgbaColor(red: 200, green: 220, blue: 255),
    RgbaColor(red: 255, green: 205, blue: 210),
    RgbaColor(red: 205, green: 245, blue: 220),
    RgbaColor(red: 255, green: 225, blue: 180),
    RgbaColor(red: 235, green: 205, blue: 255),
    RgbaColor(red: 190, green: 240, blue: 245),
  ];

  bool _passesContrast(RgbaColor candidate) {
    return candidate.contrastRatioWith(backgroundColor) >=
            _kMinTextContrastRatio &&
        candidate.contrastRatioWith(surfaceColor) >= _kMinTextContrastRatio;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final validSwatches = _candidates.where(_passesContrast).toList();

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(
        20,
        12,
        20,
        MediaQuery.of(context).padding.bottom + 20,
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Text color',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded),
                  style: IconButton.styleFrom(
                    backgroundColor: theme.colorScheme.surfaceContainerHighest,
                    shape: const CircleBorder(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Only colors that read clearly against your current '
              'Background and Surface colors are shown.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 18),
            if (validSwatches.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Text(
                  'No preset text colors have enough contrast against the '
                  'current Background/Surface colors. Try adjusting those '
                  'colors first.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              )
            else
              Flexible(
                child: SingleChildScrollView(
                  child: Wrap(
                    spacing: 14,
                    runSpacing: 14,
                    children: validSwatches.map((swatch) {
                      final isSelected = swatch == initialColor;
                      final color = swatch.toColor();
                      final onColor =
                          ThemeData.estimateBrightnessForColor(color) ==
                                  Brightness.light
                              ? Colors.black87
                              : Colors.white;

                      return GestureDetector(
                        onTap: () => Navigator.of(context).pop(swatch),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isSelected
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.outlineVariant,
                              width: isSelected ? 3 : 1,
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: theme.colorScheme.primary
                                          .withValues(alpha: 0.35),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                : null,
                          ),
                          child: isSelected
                              ? Icon(Icons.check_rounded, color: onColor)
                              : null,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            const SizedBox(height: 20),
            OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }
}