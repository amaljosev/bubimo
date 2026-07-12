// lib/features/theme/presentation/widgets/custom_theme_form/color_field_tile.dart

import 'package:flutter/material.dart';

import '../../../domain/entities/rgba_color.dart';
import 'rgba_color_picker_sheet.dart';

/// A labeled row showing a color swatch + hex-ish RGBA readout, tapping
/// which opens a color picker. Used for the primary, secondary,
/// surface, background, and text color fields on the Create Custom
/// Theme screen.
///
/// By default, tapping opens [RgbaColorPickerSheet] (the freeform HSV/
/// hex picker) and reports the result via [onChanged]. Pass [onTap] to
/// override this entirely — used by the Text color field, which routes
/// to a curated, contrast-filtered swatch picker instead (see
/// `TextColorSwatchPickerSheet`), since text color is constrained to
/// pre-vetted options rather than a free color space. When [onTap] is
/// provided, [onChanged] is not used by this widget directly (the
/// caller is responsible for dispatching whatever event the custom
/// picker's result implies).
///
/// [description] answers "what does this color control, and where will
/// I see it?" (e.g. "Buttons, floating action button, active tab
/// indicator") so users can map each field to what it actually affects
/// without guessing — the live preview reinforces this, but the label
/// alone wasn't enough on the old screen.
///
/// [warning], when non-null, renders an inline amber/red notice below
/// the row — used by the Text color field to surface a contrast/
/// readability problem (see `CustomThemeFormState.textColorWarning`)
/// right where the user is about to act on it. This warning is now
/// purely informational: it never blocks saving the theme.
///
/// [presets] is the curated swatch list shown in the default picker's
/// "PRESETS" row — pulled from `AppColors.forRole` by the caller and
/// keyed to both this field's color role and the theme's current
/// light/dark mode (e.g. `AppColors.forRole(AppColorRole.primary,
/// isDark: state.isDark)` for the Primary tile). Required whenever
/// [onChanged] is used (i.e. the default [RgbaColorPickerSheet] path);
/// unused when [onTap] overrides the picker entirely, since the caller
/// owns preset selection in that case (see the Text field, which uses
/// `AppColors.textLight`/`AppColors.textDark` inside
/// `TextColorSwatchPickerSheet` instead).
class ColorFieldTile extends StatelessWidget {
  final String label;
  final String? description;
  final RgbaColor color;
  final ValueChanged<RgbaColor>? onChanged;
  final VoidCallback? onTap;
  final String? warning;
  final List<RgbaColor>? presets;

  const ColorFieldTile({
    super.key,
    required this.label,
    this.description,
    required this.color,
    this.onChanged,
    this.onTap,
    this.warning,
    this.presets,
  }) : assert(
          onChanged != null || onTap != null,
          'Provide either onChanged (default picker) or onTap (custom picker).',
        ),
        assert(
          onChanged == null || presets != null,
          'presets is required when using the default picker (onChanged).',
        );

  Future<void> _openDefaultPicker(BuildContext context) async {
    final picked = await RgbaColorPickerSheet.show(
      context,
      label: label,
      initialColor: color,
      presets: presets!,
    );
    if (picked != null) onChanged?.call(picked);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasWarning = warning != null;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap ?? () => _openDefaultPicker(context),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: color.toColor(),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: hasWarning
                            ? theme.colorScheme.error
                            : theme.colorScheme.outlineVariant,
                        width: hasWarning ? 2 : 1,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(label, style: theme.textTheme.labelLarge),
                        if (description != null) ...[
                          const SizedBox(height: 1),
                          Text(
                            description!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                        const SizedBox(height: 2),
                        Text(
                          'R${color.red} G${color.green} B${color.blue} O${color.opacity.toStringAsFixed(2)}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right, color: theme.colorScheme.outline),
                ],
              ),
              if (hasWarning) ...[
                const SizedBox(height: 6),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      size: 16,
                      color: theme.colorScheme.error,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        warning!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.error,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}