// lib/features/theme/presentation/widgets/custom_theme_form/rgba_color_picker_sheet.dart

import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../domain/entities/rgba_color.dart';

/// A reusable RGBA color picker shown in a modal bottom sheet.
///
/// Layout follows the app's standard color-picker pattern: drag handle,
/// title + close button, swatch + hex input, HSV sliders (Hue /
/// Saturation / Brightness / Opacity), preset swatches, then
/// Cancel / Select actions.
///
/// Built entirely from stock Flutter widgets (Slider with a custom
/// gradient track, CustomPainter checkerboard for opacity preview) —
/// no external color-picker package. Reused for the primary, secondary,
/// surface, and background color slots on the Create Custom Theme
/// screen.
///
/// [presets] drives the "PRESETS" swatch row and MUST be supplied by
/// the caller — pulled from [AppColors] via `AppColors.forRole`, keyed
/// to whichever color role this instance is picking for and the
/// theme's current light/dark mode (e.g.
/// `AppColors.forRole(AppColorRole.primary, isDark: state.isDark)`
/// for the Primary field). This sheet intentionally has no built-in
/// default preset list: a single generic list was previously reused
/// for every color role, which meant e.g. the Surface picker offered
/// saturated brand colors that make poor surfaces. Centralizing the
/// *palettes* in [AppColors] while keeping *presentation* here is what
/// lets each field show swatches appropriate to its actual purpose and
/// mode.
///
/// Returns the picked [RgbaColor] via `Navigator.pop`, or `null` if the
/// user dismisses without confirming.
class RgbaColorPickerSheet extends StatefulWidget {
  final String label;
  final RgbaColor initialColor;
  final List<RgbaColor> presets;

  const RgbaColorPickerSheet({
    super.key,
    required this.label,
    required this.initialColor,
    required this.presets,
  });

  /// Convenience launcher — shows the sheet and returns the picked
  /// color, or `null` if cancelled.
  static Future<RgbaColor?> show(
    BuildContext context, {
    required String label,
    required RgbaColor initialColor,
    required List<RgbaColor> presets,
  }) {
    return showModalBottomSheet<RgbaColor>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => RgbaColorPickerSheet(
        label: label,
        initialColor: initialColor,
        presets: presets,
      ),
    );
  }

  @override
  State<RgbaColorPickerSheet> createState() => _RgbaColorPickerSheetState();
}

class _RgbaColorPickerSheetState extends State<RgbaColorPickerSheet> {
  late HSVColor _hsv;
  late double _opacity;
  late TextEditingController _hexController;

  @override
  void initState() {
    super.initState();
    _hsv = HSVColor.fromColor(
      Color.fromARGB(
        255,
        widget.initialColor.red,
        widget.initialColor.green,
        widget.initialColor.blue,
      ),
    );
    _opacity = widget.initialColor.opacity;
    _hexController = TextEditingController(text: _hexOf(_hsv.toColor()));
  }

  @override
  void dispose() {
    _hexController.dispose();
    super.dispose();
  }

  RgbaColor get _currentColor {
    final c = _hsv.toColor();
    return RgbaColor(
      red: (c.r * 255).round(),
      green: (c.g * 255).round(),
      blue: (c.b * 255).round(),
      opacity: _opacity,
    );
  }

  String _hexOf(Color c) =>
      c.toARGB32().toRadixString(16).padLeft(8, '0').substring(2).toUpperCase();

  void _applyHex(String value) {
    final cleaned = value.replaceAll('#', '').trim();
    if (cleaned.length == 6) {
      final intVal = int.tryParse('FF$cleaned', radix: 16);
      if (intVal != null) {
        setState(() => _hsv = HSVColor.fromColor(Color(intVal)));
      }
    }
  }

  void _setHsv(HSVColor value) {
    setState(() {
      _hsv = value;
      _hexController.value = TextEditingValue(
        text: _hexOf(_hsv.toColor()),
        selection: TextSelection.collapsed(
          offset: _hexController.selection.baseOffset.clamp(0, 6),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selected = _hsv.toColor();
    final isLight =
        ThemeData.estimateBrightnessForColor(selected) == Brightness.light;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return AnimatedPadding(
      duration: const Duration(milliseconds: 100),
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
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
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Drag handle
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
              // Title + close
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.label,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                    style: IconButton.styleFrom(
                      backgroundColor:
                          theme.colorScheme.surfaceContainerHighest,
                      shape: const CircleBorder(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              // Preview swatch (checkerboard-backed so opacity is
              // visible) + hex input
              Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: selected.withValues(alpha: 0.4 * _opacity),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: CustomPaint(
                      painter: _CheckerboardPainter(),
                      child: Container(
                        color: selected.withValues(alpha: _opacity),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: TextField(
                      controller: _hexController,
                      textCapitalization: TextCapitalization.characters,
                      maxLength: 6,
                      decoration: InputDecoration(
                        prefixText: '#  ',
                        labelText: 'Hex code',
                        counterText: '',
                        filled: true,
                        fillColor: theme.colorScheme.surfaceContainerHighest,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                      ),
                      onSubmitted: _applyHex,
                      onChanged: (v) {
                        if (v.length == 6) _applyHex(v);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              // ── HSV + Opacity sliders ────────────────────────────────
              _SliderRow(
                label: 'Hue',
                value: _hsv.hue / 360,
                trackGradient: LinearGradient(
                  colors: List.generate(
                    7,
                    (i) => HSVColor.fromAHSV(1, i * 60, 1, 1).toColor(),
                  ),
                ),
                onChanged: (v) => _setHsv(_hsv.withHue(v * 360)),
              ),
              const SizedBox(height: 10),
              _SliderRow(
                label: 'Saturation',
                value: _hsv.saturation,
                trackGradient: LinearGradient(
                  colors: [
                    HSVColor.fromAHSV(1, _hsv.hue, 0, _hsv.value).toColor(),
                    HSVColor.fromAHSV(1, _hsv.hue, 1, _hsv.value).toColor(),
                  ],
                ),
                onChanged: (v) => _setHsv(_hsv.withSaturation(v)),
              ),
              const SizedBox(height: 10),
              _SliderRow(
                label: 'Brightness',
                value: _hsv.value,
                trackGradient: LinearGradient(
                  colors: [
                    Colors.black,
                    HSVColor.fromAHSV(
                      1,
                      _hsv.hue,
                      _hsv.saturation,
                      1,
                    ).toColor(),
                  ],
                ),
                onChanged: (v) => _setHsv(_hsv.withValue(v)),
              ),
              const SizedBox(height: 10),
              _SliderRow(
                label: 'Opacity',
                value: _opacity,
                trackGradient: LinearGradient(
                  colors: [
                    selected.withValues(alpha: 0),
                    selected.withValues(alpha: 1),
                  ],
                ),
                onChanged: (v) => setState(() => _opacity = v),
              ),
              const SizedBox(height: 22),
              // ── Preset swatches ──────────────────────────────────────
              Text(
                'PRESETS',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.45),
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: widget.presets.map((preset) {
                  final c = preset.toColor();
                  // Compare RGB only (ignore opacity) so a preset still
                  // shows as selected regardless of the current opacity
                  // slider value — presets represent hue/tone choices,
                  // not a fixed opacity.
                  final isSel = c.r == selected.r &&
                      c.g == selected.g &&
                      c.b == selected.b;
                  return GestureDetector(
                    onTap: () => _setHsv(HSVColor.fromColor(c)),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: c,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSel
                              ? theme.colorScheme.primary
                              : Colors.black.withValues(alpha: 0.08),
                          width: isSel ? 2.5 : 1,
                        ),
                      ),
                      child: isSel
                          ? Icon(
                              Icons.check_rounded,
                              size: 16,
                              color:
                                  ThemeData.estimateBrightnessForColor(c) ==
                                      Brightness.light
                                  ? Colors.black87
                                  : Colors.white,
                            )
                          : null,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              // ── Actions ───────────────────────────────────────────────
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: FilledButton(
                      onPressed: () =>
                          Navigator.of(context).pop(_currentColor),
                      style: FilledButton.styleFrom(
                        backgroundColor: selected,
                        foregroundColor: isLight
                            ? Colors.black87
                            : Colors.white,
                        minimumSize: const Size(0, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        'Select Color',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Checkerboard backdrop so opacity changes are visible even at low
/// alpha values — used behind the preview swatch.
class _CheckerboardPainter extends CustomPainter {
  static const double _cellSize = 8;

  @override
  void paint(Canvas canvas, Size size) {
    final light = Paint()..color = const Color(0xFFE0E0E0);
    final dark = Paint()..color = const Color(0xFFBDBDBD);

    for (double y = 0; y < size.height; y += _cellSize) {
      for (double x = 0; x < size.width; x += _cellSize) {
        final isEven =
            ((x / _cellSize).floor() + (y / _cellSize).floor()) % 2 == 0;
        canvas.drawRect(
          Rect.fromLTWH(x, y, _cellSize, _cellSize),
          isEven ? light : dark,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _SliderRow extends StatelessWidget {
  final String label;
  final double value;
  final LinearGradient trackGradient;
  final ValueChanged<double> onChanged;

  const _SliderRow({
    required this.label,
    required this.value,
    required this.trackGradient,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 78,
          child: Text(
            label,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ),
        Expanded(
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 12,
              thumbShape: const RoundSliderThumbShape(
                enabledThumbRadius: 9,
                elevation: 2,
              ),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 18),
              trackShape: _GradientTrackShape(gradient: trackGradient),
            ),
            child: Slider(
              value: value.clamp(0.0, 1.0),
              onChanged: onChanged,
              activeColor: Colors.transparent,
              inactiveColor: Colors.transparent,
              thumbColor: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}

class _GradientTrackShape extends SliderTrackShape {
  final LinearGradient gradient;

  const _GradientTrackShape({required this.gradient});

  @override
  Rect getPreferredRect({
    required RenderBox parentBox,
    Offset offset = Offset.zero,
    required SliderThemeData sliderTheme,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) {
    final trackHeight = sliderTheme.trackHeight ?? 4;
    final trackTop = offset.dy + (parentBox.size.height - trackHeight) / 2;
    return Rect.fromLTWH(
      offset.dx,
      trackTop,
      parentBox.size.width,
      trackHeight,
    );
  }

  @override
  void paint(
    PaintingContext context,
    Offset offset, {
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required Animation<double> enableAnimation,
    required TextDirection textDirection,
    required Offset thumbCenter,
    Offset? secondaryOffset,
    bool isDiscrete = false,
    bool isEnabled = false,
  }) {
    final rect = getPreferredRect(
      parentBox: parentBox,
      offset: offset,
      sliderTheme: sliderTheme,
    );
    final paint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.fill;

    final rRect = RRect.fromRectAndRadius(rect, const Radius.circular(6));
    context.canvas.drawRRect(rRect, paint);
  }
}