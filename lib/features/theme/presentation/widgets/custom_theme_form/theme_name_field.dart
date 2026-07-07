// lib/features/theme/presentation/widgets/custom_theme_form/theme_name_field.dart

import 'package:flutter/material.dart';

/// Theme name input. Kept as a stateless wrapper around a
/// [TextEditingController] passed in from the parent screen (rather
/// than owning its own controller) so the screen can control initial
/// text for edit mode and dispose the controller in one place.
class ThemeNameField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const ThemeNameField({
    super.key,
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      textCapitalization: TextCapitalization.words,
      decoration: const InputDecoration(
        labelText: 'Theme name',
        hintText: 'e.g. Rainy Afternoon',
        prefixIcon: Icon(Icons.edit_outlined),
      ),
    );
  }
}
