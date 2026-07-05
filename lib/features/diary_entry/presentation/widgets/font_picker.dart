// lib/features/rich_editor/presentation/widgets/font_picker.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Categories used to group fonts for filtering in the UI.
enum _FontCategory { all, handwriting, serif, sans, playful, mono }

extension on _FontCategory {
  String get label {
    switch (this) {
      case _FontCategory.all:
        return 'All';
      case _FontCategory.handwriting:
        return 'Handwriting';
      case _FontCategory.serif:
        return 'Serif';
      case _FontCategory.sans:
        return 'Sans';
      case _FontCategory.playful:
        return 'Playful';
      case _FontCategory.mono:
        return 'Mono';
    }
  }
}

/// A single selectable font option: a display label, the category it
/// belongs to, and a function that builds its Google Fonts TextStyle
/// (used both for the tile preview and to resolve the actual font
/// family string).
class _FontOption {
  final String label;
  final _FontCategory category;
  final TextStyle Function() styleBuilder;

  const _FontOption(this.label, this.category, this.styleBuilder);
}

/// Font options offered to the user, backed by `google_fonts` — no
/// bundled font assets or `flutter: fonts:` pubspec entries needed.
/// Fonts are fetched on first use and cached by the package afterward;
/// the very first render of each font may require a brief network
/// fetch (falls back to the default font if offline and not yet
/// cached).
///
/// Curated for journaling: a mix of handwriting/script (personal,
/// diary-like feel), serif (classic, reflective), clean sans (easy
/// everyday reading), playful display faces (lighter entries), and
/// monospace (typewriter-diary feel).
final List<_FontOption> _fontOptions = [
  _FontOption('Default', _FontCategory.all, () => const TextStyle()),

  // ── Handwriting / script — personal, diary-like ──────────────────
  _FontOption('Caveat', _FontCategory.handwriting, () => GoogleFonts.caveat()),
  _FontOption('Dancing Script', _FontCategory.handwriting,
      () => GoogleFonts.dancingScript()),
  _FontOption('Kalam', _FontCategory.handwriting, () => GoogleFonts.kalam()),
  _FontOption('Shadows Into Light', _FontCategory.handwriting,
      () => GoogleFonts.shadowsIntoLight()),
  _FontOption('Indie Flower', _FontCategory.handwriting,
      () => GoogleFonts.indieFlower()),
  _FontOption('Patrick Hand', _FontCategory.handwriting,
      () => GoogleFonts.patrickHand()),
  _FontOption('Satisfy', _FontCategory.handwriting, () => GoogleFonts.satisfy()),
  _FontOption(
      'Sacramento', _FontCategory.handwriting, () => GoogleFonts.sacramento()),
  _FontOption(
      'Great Vibes', _FontCategory.handwriting, () => GoogleFonts.greatVibes()),
  _FontOption('Homemade Apple', _FontCategory.handwriting,
      () => GoogleFonts.homemadeApple()),
  _FontOption('Reenie Beanie', _FontCategory.handwriting,
      () => GoogleFonts.reenieBeanie()),
  _FontOption(
      'Amatic SC', _FontCategory.handwriting, () => GoogleFonts.amaticSc()),
  _FontOption('Caveat Brush', _FontCategory.handwriting,
      () => GoogleFonts.caveatBrush()),

  // ── Serif — classic, reflective ──────────────────────────────────
  _FontOption(
      'Merriweather', _FontCategory.serif, () => GoogleFonts.merriweather()),
  _FontOption('Lora', _FontCategory.serif, () => GoogleFonts.lora()),
  _FontOption('Playfair Display', _FontCategory.serif,
      () => GoogleFonts.playfairDisplay()),
  _FontOption(
      'EB Garamond', _FontCategory.serif, () => GoogleFonts.ebGaramond()),
  _FontOption(
      'Crimson Text', _FontCategory.serif, () => GoogleFonts.crimsonText()),
  _FontOption('Cormorant Garamond', _FontCategory.serif,
      () => GoogleFonts.cormorantGaramond()),
  _FontOption('PT Serif', _FontCategory.serif, () => GoogleFonts.ptSerif()),
  _FontOption('Libre Baskerville', _FontCategory.serif,
      () => GoogleFonts.libreBaskerville()),
  _FontOption('Bitter', _FontCategory.serif, () => GoogleFonts.bitter()),
  _FontOption('Spectral', _FontCategory.serif, () => GoogleFonts.spectral()),

  // ── Sans-serif — clean, easy everyday reading ────────────────────
  _FontOption('Nunito', _FontCategory.sans, () => GoogleFonts.nunito()),
  _FontOption('Poppins', _FontCategory.sans, () => GoogleFonts.poppins()),
  _FontOption('Quicksand', _FontCategory.sans, () => GoogleFonts.quicksand()),
  _FontOption('Lato', _FontCategory.sans, () => GoogleFonts.lato()),
  _FontOption('Inter', _FontCategory.sans, () => GoogleFonts.inter()),
  _FontOption('Roboto', _FontCategory.sans, () => GoogleFonts.roboto()),
  _FontOption('Open Sans', _FontCategory.sans, () => GoogleFonts.openSans()),
  _FontOption(
      'Montserrat', _FontCategory.sans, () => GoogleFonts.montserrat()),
  _FontOption('Raleway', _FontCategory.sans, () => GoogleFonts.raleway()),
  _FontOption('Work Sans', _FontCategory.sans, () => GoogleFonts.workSans()),
  _FontOption('Karla', _FontCategory.sans, () => GoogleFonts.karla()),

  // ── Playful / display — lighter, expressive entries ──────────────
  _FontOption('Pacifico', _FontCategory.playful, () => GoogleFonts.pacifico()),
  _FontOption(
      'Comic Neue', _FontCategory.playful, () => GoogleFonts.comicNeue()),
  _FontOption('Fredoka', _FontCategory.playful, () => GoogleFonts.fredoka()),
  _FontOption('Baloo 2', _FontCategory.playful, () => GoogleFonts.baloo2()),
  _FontOption(
      'Righteous', _FontCategory.playful, () => GoogleFonts.righteous()),
  _FontOption('Lobster', _FontCategory.playful, () => GoogleFonts.lobster()),

  // ── Monospace — for a typewriter-diary feel ──────────────────────
  _FontOption(
      'Roboto Mono', _FontCategory.mono, () => GoogleFonts.robotoMono()),
  _FontOption('Space Mono', _FontCategory.mono, () => GoogleFonts.spaceMono()),
  _FontOption('JetBrains Mono', _FontCategory.mono,
      () => GoogleFonts.jetBrainsMono()),
  _FontOption('Source Code Pro', _FontCategory.mono,
      () => GoogleFonts.sourceCodePro()),
];

/// Full bottom-sheet content for choosing a whole-entry font: a drag
/// handle, a header with a close action, category filter pills, and a
/// scrollable grid of font tiles (each previewed in its own font).
///
/// Present with:
/// ```dart
/// showModalBottomSheet(
///   context: context,
///   isScrollControlled: true,
///   backgroundColor: Colors.transparent,
///   builder: (_) => FontPicker(
///     selectedFontFamily: _bloc.state.fontFamily,
///     onFontSelected: (family) {
///       _applyFontFamily(family);
///       Navigator.pop(context);
///     },
///   ),
/// );
/// ```
///
/// Selection state lives in [ValueNotifier]s scoped to just the grid
/// and category row, so tapping a category or a tile only rebuilds the
/// small widget that displays that state — not the whole sheet.
class FontPicker extends StatefulWidget {
  final String? selectedFontFamily;
  final ValueChanged<String?> onFontSelected;

  const FontPicker({
    super.key,
    required this.selectedFontFamily,
    required this.onFontSelected,
  });

  @override
  State<FontPicker> createState() => _FontPickerState();
}

class _FontPickerState extends State<FontPicker> {
  late final ValueNotifier<String?> _selectedFamily =
      ValueNotifier<String?>(widget.selectedFontFamily);
  final ValueNotifier<_FontCategory> _category =
      ValueNotifier<_FontCategory>(_FontCategory.all);

  @override
  void didUpdateWidget(covariant FontPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedFontFamily != widget.selectedFontFamily) {
      _selectedFamily.value = widget.selectedFontFamily;
    }
  }

  @override
  void dispose() {
    _selectedFamily.dispose();
    _category.dispose();
    super.dispose();
  }

  void _handleFontTap(String? resolvedFamily) {
    _selectedFamily.value = resolvedFamily;
    widget.onFontSelected(resolvedFamily);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);

    return SafeArea(
      top: false,
      child: Container(
        height: mediaQuery.size.height * 0.72,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 10),
            // Drag handle.
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 12, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Choose a font',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                    tooltip: 'Close',
                  ),
                ],
              ),
            ),
            _CategoryTabs(category: _category),
            const SizedBox(height: 8),
            Expanded(
              child: ValueListenableBuilder<_FontCategory>(
                valueListenable: _category,
                builder: (context, category, _) {
                  final options = category == _FontCategory.all
                      ? _fontOptions
                      : _fontOptions
                          .where((o) =>
                              o.category == category || o.label == 'Default')
                          .toList();

                  return GridView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      childAspectRatio: 2.6,
                    ),
                    itemCount: options.length,
                    itemBuilder: (context, index) {
                      final option = options[index];
                      final style = option.styleBuilder();
                      final isDefault = option.label == 'Default';
                      final resolvedFamily =
                          isDefault ? null : style.fontFamily;

                      return _FontTile(
                        label: option.label,
                        style: style,
                        resolvedFamily: resolvedFamily,
                        selectedFamily: _selectedFamily,
                        onTap: () => _handleFontTap(resolvedFamily),
                      );
                    },
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

/// Row of pill-shaped category filters. Only rebuilds itself when the
/// selected category changes, via the [ValueListenableBuilder] wrapping
/// the row contents.
class _CategoryTabs extends StatelessWidget {
  final ValueNotifier<_FontCategory> category;

  const _CategoryTabs({required this.category});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      height: 34,
      child: ValueListenableBuilder<_FontCategory>(
        valueListenable: category,
        builder: (context, selected, _) {
          return ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _FontCategory.values.length,
            separatorBuilder: (_, __) => const SizedBox(width: 6),
            itemBuilder: (context, index) {
              final value = _FontCategory.values[index];
              final isSelected = value == selected;

              return GestureDetector(
                onTap: () => category.value = value,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOut,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? colorScheme.primary
                        : colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(17),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    value.label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? colorScheme.onPrimary
                          : colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

/// A single font tile in the grid, previewed in its own font. Wraps
/// only its own content in a [ValueListenableBuilder] scoped to
/// [selectedFamily], so selecting a font only rebuilds the
/// previously-selected tile and the newly-selected tile — not the
/// whole grid.
class _FontTile extends StatelessWidget {
  final String label;
  final TextStyle style;
  final String? resolvedFamily;
  final ValueNotifier<String?> selectedFamily;
  final VoidCallback onTap;

  const _FontTile({
    required this.label,
    required this.style,
    required this.resolvedFamily,
    required this.selectedFamily,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ValueListenableBuilder<String?>(
      valueListenable: selectedFamily,
      builder: (context, currentFamily, _) {
        final isSelected = currentFamily == resolvedFamily;

        return GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: isSelected
                  ? colorScheme.primaryContainer
                  : colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isSelected
                    ? colorScheme.primary
                    : colorScheme.outlineVariant,
                width: isSelected ? 1.4 : 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: colorScheme.primary.withValues(alpha: 0.18),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    label,
                    overflow: TextOverflow.ellipsis,
                    style: style.copyWith(
                      fontSize: 15,
                      color: isSelected
                          ? colorScheme.onPrimaryContainer
                          : colorScheme.onSurface,
                    ),
                  ),
                ),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 150),
                  child: isSelected
                      ? Icon(
                          Icons.check_circle_rounded,
                          key: const ValueKey('check'),
                          size: 18,
                          color: colorScheme.primary,
                        )
                      : const SizedBox(key: ValueKey('no-check'), width: 0),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}