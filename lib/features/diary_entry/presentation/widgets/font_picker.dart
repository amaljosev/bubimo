// lib/features/rich_editor/presentation/widgets/font_picker.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// A single selectable font option: a display label, and a function
/// that builds its Google Fonts TextStyle (used both for the chip
/// preview and to resolve the actual font family string).
class _FontOption {
  final String label;
  final TextStyle Function() styleBuilder;

  const _FontOption(this.label, this.styleBuilder);
}

/// Font options offered to the user, backed by `google_fonts` — no
/// bundled font assets or `flutter: fonts:` pubspec entries needed.
/// Fonts are fetched on first use and cached by the package afterward;
/// the very first render of each font may require a brief network
/// fetch (falls back to the default font if offline and not yet
/// cached).
final List<_FontOption> _fontOptions = [
  _FontOption('Default', () => const TextStyle()),
  _FontOption('Merriweather', () => GoogleFonts.merriweather()),
  _FontOption('Lora', () => GoogleFonts.lora()),
  _FontOption('Caveat', () => GoogleFonts.caveat()),
  _FontOption('Roboto Mono', () => GoogleFonts.robotoMono()),
  _FontOption('Nunito', () => GoogleFonts.nunito()),
];

/// A horizontal list of tappable font options, each rendered in its own
/// font so the user can preview it before selecting. Returns the
/// resolved font family string (or null for "Default") via
/// [onFontSelected] — that string is what gets applied to the Quill
/// document and stored on `DiaryEntry.fontFamily`.
class FontPicker extends StatelessWidget {
  final String? selectedFontFamily;
  final ValueChanged<String?> onFontSelected;

  const FontPicker({
    super.key,
    required this.selectedFontFamily,
    required this.onFontSelected,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        itemCount: _fontOptions.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final option = _fontOptions[index];
          final style = option.styleBuilder();
          final isDefault = option.label == 'Default';
          final resolvedFamily = isDefault ? null : style.fontFamily;
          final isSelected = resolvedFamily == selectedFontFamily;

          return ChoiceChip(
            label: Text(option.label, style: style),
            selected: isSelected,
            onSelected: (_) => onFontSelected(resolvedFamily),
            selectedColor: colorScheme.primaryContainer,
          );
        },
      ),
    );
  }
}