// lib/features/diary_entry/presentation/widgets/diary_form/diary_form_overlay_settings_sheet.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/diary_form/diary_form_bloc.dart';
import '../../bloc/diary_form/diary_form_event.dart';

/// Bottom sheet for adjusting the background overlay tint's opacity and
/// color for the current entry only. Reads its initial values from
/// [DiaryFormBloc]'s current state (via the [BlocProvider.value] the
/// caller wraps this in) and dispatches
/// [DiaryFormOverlayOpacityChanged] live as the slider/toggle move, so
/// the form's background preview updates in real time behind the sheet.
///
/// Local widget state ([_opacity]/[_color]) mirrors the bloc for
/// `onChanged` would work too, but keeping local state avoids a full
/// bloc round-trip on every drag frame.
///
/// Extracted from `diary_form_page.dart` into its own file so the form
/// page itself stays focused on the main editor screen.
class DiaryFormOverlaySettingsSheet extends StatefulWidget {
  const DiaryFormOverlaySettingsSheet({super.key});

  @override
  State<DiaryFormOverlaySettingsSheet> createState() =>
      _DiaryFormOverlaySettingsSheetState();
}

class _DiaryFormOverlaySettingsSheetState
    extends State<DiaryFormOverlaySettingsSheet> {
  late double _opacity;
  late String _color;

  @override
  void initState() {
    super.initState();
    final state = context.read<DiaryFormBloc>().state;
    _opacity = state.bgOverlayOpacity;
    _color = state.bgOverlayColor;
  }

  void _apply() {
    context.read<DiaryFormBloc>().add(
          DiaryFormOverlayOpacityChanged(opacity: _opacity, color: _color),
        );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        decoration: BoxDecoration(
          color: isDark ? theme.colorScheme.surface : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
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
            Text(
              'Background Overlay',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Adjust the tint over your background photo so text '
              'stays readable.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _TintChoiceChip(
                    label: 'Light',
                    icon: Icons.light_mode_outlined,
                    selected: _color == 'white',
                    onTap: () {
                      setState(() => _color = 'white');
                      _apply();
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _TintChoiceChip(
                    label: 'Dark',
                    icon: Icons.dark_mode_outlined,
                    selected: _color == 'black',
                    onTap: () {
                      setState(() => _color = 'black');
                      _apply();
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  'Opacity',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Text(
                  '${(_opacity * 100).round()}%',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
            Slider(
              value: _opacity,
              // 0.05 floor rather than 0 — an overlay at 0% opacity is
              // visually indistinguishable from "no overlay control
              // exists", which reads as broken (the icon that opened
              // this sheet already implies an overlay is present).
              min: 0.05,
              max: 1.0,
              onChanged: (value) {
                setState(() => _opacity = value);
                _apply();
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// Selectable chip for choosing the overlay tint color, styled to match
/// this form's other pickers (font, background) rather than a stock
/// [ChoiceChip], for a consistent rounded-pill look across the sheet.
class _TintChoiceChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _TintChoiceChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: selected
          ? theme.colorScheme.primary.withValues(alpha: 0.12)
          : theme.colorScheme.onSurface.withValues(alpha: 0.05),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: selected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: selected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}