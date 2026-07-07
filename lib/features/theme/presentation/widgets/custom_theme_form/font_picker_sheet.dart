// lib/features/theme/presentation/widgets/custom_theme_form/font_picker_sheet.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../core/theme/google_fonts_catalog.dart';

/// Bottom sheet listing [GoogleFontsCatalog.families], each rendered in
/// its own font via `GoogleFonts.getFont` so the user sees an actual
/// live preview rather than a plain label before picking.
///
/// Returns the picked family name via `Navigator.pop`, or `null` if
/// dismissed without a selection.
class FontPickerSheet extends StatelessWidget {
  final String selectedFont;

  const FontPickerSheet({super.key, required this.selectedFont});

  static Future<String?> show(
    BuildContext context, {
    required String selectedFont,
  }) {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => FontPickerSheet(selectedFont: selectedFont),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mediaHeight = MediaQuery.of(context).size.height;

    return SafeArea(
      top: false,
      child: SizedBox(
        height: mediaHeight * 0.7,
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 12),
            Text('Choose a font', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            const Divider(height: 1),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: GoogleFontsCatalog.families.length,
                itemBuilder: (context, index) {
                  final font = GoogleFontsCatalog.families[index];
                  final isSelected = font == selectedFont;

                  TextStyle previewStyle;
                  try {
                    previewStyle = GoogleFonts.getFont(font, fontSize: 17);
                  } catch (_) {
                    // Family name not found in this version of the
                    // google_fonts manifest (e.g. renamed/removed
                    // upstream, like 'Source Serif Pro' ->
                    // 'Source Serif 4'). Fall back to the default text
                    // style rather than crashing the whole sheet.
                    previewStyle = const TextStyle(fontSize: 17);
                  }

                  return ListTile(
                    title: Text(font, style: previewStyle),
                    trailing: isSelected
                        ? Icon(
                            Icons.check_circle,
                            color: theme.colorScheme.primary,
                          )
                        : null,
                    selected: isSelected,
                    onTap: () => Navigator.of(context).pop(font),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}