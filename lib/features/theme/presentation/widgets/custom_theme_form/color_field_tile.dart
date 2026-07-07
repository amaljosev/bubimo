// lib/features/theme/presentation/widgets/custom_theme_form/color_field_tile.dart

import 'package:flutter/material.dart';

import '../../../domain/entities/rgba_color.dart';
import 'rgba_color_picker_sheet.dart';

/// A labeled row showing a color swatch + hex-ish RGBA readout, tapping
/// which opens [RgbaColorPickerSheet]. Used for the primary, background,
/// and accent color fields on the Create Custom Theme screen.
class ColorFieldTile extends StatelessWidget {
  final String label;
  final RgbaColor color;
  final ValueChanged<RgbaColor> onChanged;

  const ColorFieldTile({
    super.key,
    required this.label,
    required this.color,
    required this.onChanged,
  });

  Future<void> _openPicker(BuildContext context) async {
    final picked = await RgbaColorPickerSheet.show(
      context,
      label: label,
      initialColor: color,
    );
    if (picked != null) onChanged(picked);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => _openPicker(context),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.toColor(),
                  shape: BoxShape.circle,
                  border: Border.all(color: theme.colorScheme.outlineVariant),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: theme.textTheme.labelLarge),
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
        ),
      ),
    );
  }
}
