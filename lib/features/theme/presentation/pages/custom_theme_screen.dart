// lib/features/theme/presentation/pages/custom_theme_screen.dart

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/di/injection.dart';
import '../bloc/custom_theme_form/custom_theme_form_bloc.dart';
import '../bloc/custom_theme_form/custom_theme_form_event.dart';
import '../bloc/custom_theme_form/custom_theme_form_state.dart';

/// A fixed palette used for the primary/background/accent pickers below.
/// No color-picker package is in the locked dependency list, so this
/// avoids adding one — swap for a full color wheel later if desired.
const List<String> _swatchPalette = [
  '#6750A4', '#006874', '#9C4146', '#3A6A3E', '#4B5AA8',
  '#B4436C', '#5C6BC0', '#00897B', '#C77800', '#455A64',
  '#FFFBFE', '#F5FDFF', '#FFF8F6', '#F7FDF2', '#FAFBFF',
  '#212121', '#37474F', '#4E342E', '#1B5E20', '#0D47A1',
];

/// Lets the user build and save a custom theme: name, three color
/// swatches, and an optional header image from the gallery.
///
/// Note: header image picking uses the `image_picker` package, which
/// needs to be added to pubspec.yaml — it isn't in the original locked
/// dependency list.
class CustomThemeScreen extends StatelessWidget {
  const CustomThemeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<CustomThemeFormBloc>(),
      child: const _CustomThemeScreenView(),
    );
  }
}

class _CustomThemeScreenView extends StatefulWidget {
  const _CustomThemeScreenView();

  @override
  State<_CustomThemeScreenView> createState() =>
      _CustomThemeScreenViewState();
}

class _CustomThemeScreenViewState extends State<_CustomThemeScreenView> {
  final TextEditingController _nameController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickHeaderImage(BuildContext context) async {
    final picked = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (picked != null && context.mounted) {
      context
          .read<CustomThemeFormBloc>()
          .add(CustomThemeHeaderImagePicked(picked.path));
    }
  }

  Color _colorFromHex(String hex) {
    final cleaned = hex.replaceFirst('#', '');
    return Color(int.parse('FF$cleaned', radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CustomThemeFormBloc, CustomThemeFormState>(
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
        return Scaffold(
          appBar: AppBar(title: const Text('Custom Theme')),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(hintText: 'Theme name'),
                onChanged: (value) => context
                    .read<CustomThemeFormBloc>()
                    .add(CustomThemeNameChanged(value)),
              ),
              const SizedBox(height: 20),
              _HeaderImagePicker(
                imagePath: state.headerImagePath,
                onTap: () => _pickHeaderImage(context),
              ),
              const SizedBox(height: 20),
              _ColorSwatchSection(
                label: 'Primary color',
                selectedHex: state.primaryColor,
                onSelected: (hex) => context
                    .read<CustomThemeFormBloc>()
                    .add(CustomThemePrimaryColorChanged(hex)),
                colorFromHex: _colorFromHex,
              ),
              const SizedBox(height: 16),
              _ColorSwatchSection(
                label: 'Background color',
                selectedHex: state.backgroundColor,
                onSelected: (hex) => context
                    .read<CustomThemeFormBloc>()
                    .add(CustomThemeBackgroundColorChanged(hex)),
                colorFromHex: _colorFromHex,
              ),
              const SizedBox(height: 16),
              _ColorSwatchSection(
                label: 'Accent color',
                selectedHex: state.accentColor,
                onSelected: (hex) => context
                    .read<CustomThemeFormBloc>()
                    .add(CustomThemeAccentColorChanged(hex)),
                colorFromHex: _colorFromHex,
              ),
              const SizedBox(height: 28),
              FilledButton(
                // Guard against duplicate submissions: disable while a
                // save is already in flight.
                onPressed: state.isSubmitting
                    ? null
                    : () => context
                        .read<CustomThemeFormBloc>()
                        .add(const CustomThemeFormSubmitted()),
                child: state.isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Save Theme'),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _HeaderImagePicker extends StatelessWidget {
  final String? imagePath;
  final VoidCallback onTap;

  const _HeaderImagePicker({required this.imagePath, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 120,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          image: imagePath != null
              ? DecorationImage(
                  image: FileImage(File(imagePath!)),
                  fit: BoxFit.cover,
                )
              : null,
        ),
        child: imagePath == null
            ? const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.image_outlined, size: 32),
                    SizedBox(height: 4),
                    Text('Choose header image'),
                  ],
                ),
              )
            : null,
      ),
    );
  }
}

class _ColorSwatchSection extends StatelessWidget {
  final String label;
  final String selectedHex;
  final ValueChanged<String> onSelected;
  final Color Function(String) colorFromHex;

  const _ColorSwatchSection({
    required this.label,
    required this.selectedHex,
    required this.onSelected,
    required this.colorFromHex,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 8),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: _swatchPalette.map((hex) {
            final isSelected = hex == selectedHex;
            return GestureDetector(
              onTap: () => onSelected(hex),
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: colorFromHex(hex),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Colors.black12,
                    width: isSelected ? 3 : 1,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}