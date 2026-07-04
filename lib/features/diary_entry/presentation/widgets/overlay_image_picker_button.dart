// lib/features/diary_entry/presentation/widgets/overlay_image_picker_button.dart

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

/// AppBar button that picks a gallery photo and reports its path via
/// [onImageSelected] for use as a free-floating overlay image.
///
/// Distinct from [ImagePickerButton] (inline Quill embed): visually
/// differentiated with a "layers" icon and its own tooltip so users
/// don't confuse the two very different insertion modes at a glance.
class OverlayImagePickerButton extends StatefulWidget {
  final ValueChanged<String> onImageSelected;

  const OverlayImagePickerButton({super.key, required this.onImageSelected});

  @override
  State<OverlayImagePickerButton> createState() =>
      _OverlayImagePickerButtonState();
}

class _OverlayImagePickerButtonState extends State<OverlayImagePickerButton> {
  final ImagePicker _imagePicker = ImagePicker();

  // Guards against rapid repeated taps opening the gallery picker
  // multiple times concurrently.
  bool _isPicking = false;

  Future<void> _pickImage() async {
    if (_isPicking) return;
    _isPicking = true;

    try {
      final picked = await _imagePicker.pickImage(
        source: ImageSource.gallery,
      );
      if (picked != null) {
        widget.onImageSelected(picked.path);
      }
    } finally {
      _isPicking = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.filter_none_rounded),
      tooltip: 'Add floating photo',
      onPressed: _pickImage,
    );
  }
}