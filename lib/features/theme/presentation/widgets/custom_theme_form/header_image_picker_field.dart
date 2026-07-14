// lib/features/theme/presentation/widgets/custom_theme_form/header_image_picker_field.dart

import 'package:bubimo/features/shared/presentation/widgets/cropping_image_picker_field.dart';
import 'package:flutter/material.dart';


/// Optional header image field for the Create Custom Theme screen.
///
/// Thin wrapper around [CroppingImagePickerField] fixed to the 3600x1200
/// header aspect ratio. Kept as its own widget so existing call sites in
/// the custom theme form don't need to change.
class HeaderImagePickerField extends StatelessWidget {
  final String? imagePath;
  final ValueChanged<String> onImagePicked;
  final VoidCallback onImageRemoved;

  const HeaderImagePickerField({
    super.key,
    required this.imagePath,
    required this.onImagePicked,
    required this.onImageRemoved,
  });

  @override
  Widget build(BuildContext context) {
    return CroppingImagePickerField(
      imagePath: imagePath,
      onImagePicked: onImagePicked,
      onImageRemoved: onImageRemoved,
      aspectWidth: 3600,
      aspectHeight: 1200,
      label: 'Header image (optional)',
      cropToolbarTitle: 'Crop Header Image',
    );
  }
}