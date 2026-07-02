// lib/features/theme/presentation/pages/custom_theme_screen.dart

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import '../../domain/entities/app_theme_data.dart';
import '../../domain/usecases/save_custom_theme.dart';
import '../bloc/custom_theme_form/custom_theme_form_bloc.dart';


/// Create/Edit Screen for a custom theme.
///
/// Pass [existingTheme] to edit; omit it to create a new one — mirrors
/// `DiaryFormPage`'s create-vs-edit pattern. Pops with `true` once a save
/// succeeds so the caller (`ThemeScreen`) knows to reload its list via
/// the same awaited-Navigator.push-result + reload pattern used
/// throughout the app; pops with nothing (`null`) on plain back/cancel.
class CustomThemeScreen extends StatelessWidget {
  final AppThemeData? existingTheme;

  const CustomThemeScreen({super.key, this.existingTheme});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CustomThemeFormBloc(
        saveCustomTheme: GetIt.instance<SaveCustomTheme>(),
        existingTheme: existingTheme,
      ),
      child: const _CustomThemeFormView(),
    );
  }
}

class _CustomThemeFormView extends StatefulWidget {
  const _CustomThemeFormView();

  @override
  State<_CustomThemeFormView> createState() => _CustomThemeFormViewState();
}

class _CustomThemeFormViewState extends State<_CustomThemeFormView> {
  late final TextEditingController _nameController;

  // Guards against rapid/duplicate taps on the image picker button —
  // same single-navigation/single-action guard pattern used elsewhere
  // (e.g. the Save button below, ThemeScreen's tap handlers).
  bool _isPickingImage = false;

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: context.read<CustomThemeFormBloc>().state.name);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickHeaderImage() async {
    if (_isPickingImage) return;
    setState(() => _isPickingImage = true);

    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: ImageSource.gallery);
      if (picked == null || !mounted) return;

      final cropped = await ImageCropper().cropImage(
        sourcePath: picked.path,
        aspectRatio: const CropAspectRatio(ratioX: 16, ratioY: 9),
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Header Image',
            lockAspectRatio: true,
          ),
        ],
      );
      if (cropped == null || !mounted) return;

      context
          .read<CustomThemeFormBloc>()
          .add(CustomThemeFormHeaderImageChanged(cropped.path));
    } finally {
      if (mounted) setState(() => _isPickingImage = false);
    }
  }

  void _removeHeaderImage() {
    context.read<CustomThemeFormBloc>().add(
          const CustomThemeFormHeaderImageChanged(null),
        );
  }

  Future<void> _pickColor({
    required BuildContext context,
    required String title,
    required Color current,
    required ValueChanged<Color> onChanged,
  }) async {
    final picked = await showDialog<Color>(
      context: context,
      builder: (dialogContext) => _ColorPickerDialog(
        title: title,
        initialColor: current,
      ),
    );
    if (picked != null) onChanged(picked);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CustomThemeFormBloc, CustomThemeFormState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: (context, state) {
        if (state.status == CustomThemeFormStatus.success) {
          context.pop(true);
        }
        if (state.status == CustomThemeFormStatus.failure &&
            state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage!)),
          );
        }
      },
      builder: (context, state) {
        final isSubmitting = state.status == CustomThemeFormStatus.submitting;

        return Scaffold(
          appBar: AppBar(
            title: Text(state.isEditing ? 'Edit Theme' : 'New Theme'),
            actions: [
              IconButton(
                icon: isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.check),
                // Disabled while submitting — guards against duplicate
                // saves from rapid/duplicate taps, same pattern as
                // DiaryFormPage's check-icon AppBar action.
                onPressed: isSubmitting
                    ? null
                    : () => context
                        .read<CustomThemeFormBloc>()
                        .add(const CustomThemeFormSubmitted()),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Theme name',
                    errorText: state.nameError,
                  ),
                  onChanged: (value) => context
                      .read<CustomThemeFormBloc>()
                      .add(CustomThemeFormNameChanged(value)),
                ),
                const SizedBox(height: 24),
                Text('Colors', style: Theme.of(context).textTheme.labelLarge),
                const SizedBox(height: 8),
                _ColorRow(
                  label: 'Primary',
                  color: state.primaryColor,
                  onTap: () => _pickColor(
                    context: context,
                    title: 'Primary color',
                    current: state.primaryColor,
                    onChanged: (color) => context
                        .read<CustomThemeFormBloc>()
                        .add(CustomThemeFormPrimaryColorChanged(color)),
                  ),
                ),
                _ColorRow(
                  label: 'Background',
                  color: state.backgroundColor,
                  onTap: () => _pickColor(
                    context: context,
                    title: 'Background color',
                    current: state.backgroundColor,
                    onChanged: (color) => context
                        .read<CustomThemeFormBloc>()
                        .add(CustomThemeFormBackgroundColorChanged(color)),
                  ),
                ),
                _ColorRow(
                  label: 'Accent',
                  color: state.accentColor,
                  onTap: () => _pickColor(
                    context: context,
                    title: 'Accent color',
                    current: state.accentColor,
                    onChanged: (color) => context
                        .read<CustomThemeFormBloc>()
                        .add(CustomThemeFormAccentColorChanged(color)),
                  ),
                ),
                const SizedBox(height: 24),
                Text('Header image', style: Theme.of(context).textTheme.labelLarge),
                const SizedBox(height: 8),
                _HeaderImagePicker(
                  imagePath: state.headerImagePath,
                  isBusy: _isPickingImage,
                  onPick: _pickHeaderImage,
                  onRemove: _removeHeaderImage,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ColorRow extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ColorRow({
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.black12),
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right),
        ],
      ),
      onTap: onTap,
    );
  }
}

/// A dependency-free color picker dialog: a grid of curated swatches for
/// quick selection, plus HSV sliders and a hex input for precise control.
/// Pops with the chosen [Color] on "Select", or `null` on "Cancel"/
/// dismiss — the caller ([_CustomThemeFormViewState._pickColor]) only
/// applies the color if a non-null result comes back, so cancelling
/// never touches the form's current value.
class _ColorPickerDialog extends StatefulWidget {
  final String title;
  final Color initialColor;

  const _ColorPickerDialog({
    required this.title,
    required this.initialColor,
  });

  @override
  State<_ColorPickerDialog> createState() => _ColorPickerDialogState();
}

class _ColorPickerDialogState extends State<_ColorPickerDialog> {
  static const List<Color> _swatches = [
    Color(0xFF3F51B5), // indigo
    Color(0xFF00897B), // teal
    Color(0xFFBF5B3F), // terracotta
    Color(0xFF9575CD), // violet
    Color(0xFFFF7043), // coral
    Color(0xFFFFC107), // amber
    Color(0xFF6D8B74), // sage
    Color(0xFF4DD0E1), // cyan
    Color(0xFFE53935), // red
    Color(0xFF43A047), // green
    Color(0xFF1E88E5), // blue
    Color(0xFF8E24AA), // purple
    Color(0xFFFAFAFC), // near-white
    Color(0xFF121218), // near-black
    Color(0xFF757575), // grey
    Color(0xFFFFFFFF), // white
  ];

  late HSVColor _hsv;
  late final TextEditingController _hexController;

  @override
  void initState() {
    super.initState();
    _hsv = HSVColor.fromColor(widget.initialColor);
    _hexController = TextEditingController(text: _colorToHex(_currentColor));
  }

  @override
  void dispose() {
    _hexController.dispose();
    super.dispose();
  }

  Color get _currentColor => _hsv.toColor();

  static String _colorToHex(Color color) {
    return '#${color.toARGB32().toRadixString(16).substring(2).toUpperCase()}';
  }

  void _updateFromHsv(HSVColor hsv) {
    setState(() {
      _hsv = hsv;
      _hexController.text = _colorToHex(_currentColor);
    });
  }

  void _updateFromHex(String value) {
    var hex = value.trim();
    if (hex.startsWith('#')) hex = hex.substring(1);
    if (hex.length != 6) return; // Ignore incomplete input while typing.

    final parsed = int.tryParse(hex, radix: 16);
    if (parsed == null) return;

    setState(() {
      _hsv = HSVColor.fromColor(Color(0xFF000000 | parsed));
    });
  }

  @override
  Widget build(BuildContext context) {
    final color = _currentColor;

    return AlertDialog(
      title: Text(widget.title),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.black12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _swatches.map((swatch) {
                final isSelected = swatch.toARGB32() == color.toARGB32();
                return GestureDetector(
                  onTap: () => _updateFromHsv(HSVColor.fromColor(swatch)),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: swatch,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? Colors.black87 : Colors.black12,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            _HueSlider(
              hue: _hsv.hue,
              onChanged: (hue) => _updateFromHsv(_hsv.withHue(hue)),
            ),
            Row(
              children: [
                const SizedBox(width: 64, child: Text('Saturation')),
                Expanded(
                  child: Slider(
                    value: _hsv.saturation,
                    onChanged: (s) => _updateFromHsv(_hsv.withSaturation(s)),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                const SizedBox(width: 64, child: Text('Brightness')),
                Expanded(
                  child: Slider(
                    value: _hsv.value,
                    onChanged: (v) => _updateFromHsv(_hsv.withValue(v)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _hexController,
              decoration: const InputDecoration(
                labelText: 'Hex',
                prefixIcon: Icon(Icons.tag),
              ),
              maxLength: 7,
              onChanged: _updateFromHex,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(color),
          child: const Text('Select'),
        ),
      ],
    );
  }
}

/// A rainbow-gradient hue slider (0–360°), since `Slider` alone has no
/// built-in way to show a hue gradient track — `SliderTheme` doesn't
/// support gradient tracks natively, so the gradient bar is drawn
/// underneath a transparent-track `Slider` that handles the actual drag
/// interaction.
class _HueSlider extends StatelessWidget {
  final double hue;
  final ValueChanged<double> onChanged;

  const _HueSlider({required this.hue, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const SizedBox(width: 64, child: Text('Hue')),
        Expanded(
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                height: 4,
                margin: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFFFF0000),
                      Color(0xFFFFFF00),
                      Color(0xFF00FF00),
                      Color(0xFF00FFFF),
                      Color(0xFF0000FF),
                      Color(0xFFFF00FF),
                      Color(0xFFFF0000),
                    ],
                  ),
                ),
              ),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: Colors.transparent,
                  inactiveTrackColor: Colors.transparent,
                  overlayColor: Colors.black12,
                ),
                child: Slider(
                  min: 0,
                  max: 360,
                  value: hue,
                  onChanged: onChanged,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _HeaderImagePicker extends StatelessWidget {
  final String? imagePath;
  final bool isBusy;
  final VoidCallback onPick;
  final VoidCallback onRemove;

  const _HeaderImagePicker({
    required this.imagePath,
    required this.isBusy,
    required this.onPick,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    if (imagePath == null) {
      return OutlinedButton.icon(
        // Disabled while a pick/crop is already in flight — guards
        // against duplicate picker launches from rapid taps.
        onPressed: isBusy ? null : onPick,
        icon: isBusy
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.add_photo_alternate_outlined),
        label: const Text('Add header image'),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: Image.file(File(imagePath!), fit: BoxFit.cover),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            TextButton.icon(
              onPressed: isBusy ? null : onPick,
              icon: const Icon(Icons.edit_outlined),
              label: const Text('Change'),
            ),
            TextButton.icon(
              onPressed: isBusy ? null : onRemove,
              icon: const Icon(Icons.delete_outline),
              label: const Text('Remove'),
            ),
          ],
        ),
      ],
    );
  }
}