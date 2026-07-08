// lib/features/theme/presentation/widgets/shared/theme_font_label.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Renders [text] in a specific Google Fonts [fontFamily], regardless of
/// the app's currently active theme.
///
/// Used anywhere a theme needs to visually "speak for itself" — e.g. a
/// theme list tile showing its own name in its own font so users can
/// tell themes apart by font, independent of whichever theme happens to
/// be applied app-wide right now (see [BuiltInThemeTile],
/// [CustomThemeTile], [CurrentThemeHeader]).
///
/// Falls back to the ambient [TextStyle] if [fontFamily] isn't a known
/// Google Fonts family (e.g. a renamed/removed manifest entry), rather
/// than throwing.
class ThemeFontLabel extends StatelessWidget {
  final String text;
  final String fontFamily;
  final double? fontSize;
  final FontWeight? fontWeight;
  final Color? color;
  final int? maxLines;
  final TextOverflow? overflow;

  const ThemeFontLabel(
    this.text, {
    super.key,
    required this.fontFamily,
    this.fontSize,
    this.fontWeight,
    this.color,
    this.maxLines,
    this.overflow,
  });

  @override
  Widget build(BuildContext context) {
    TextStyle style;
    try {
      style = GoogleFonts.getFont(
        fontFamily,
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
      );
    } catch (_) {
      style = TextStyle(fontSize: fontSize, fontWeight: fontWeight, color: color);
    }

    return Text(
      text,
      style: style,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}
