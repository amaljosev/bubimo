// lib/features/rich_editor/presentation/widgets/image_picker_button.dart

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

/// An icon button that opens the device gallery and returns the picked
/// image's file path via [onImageSelected].
///
/// Uses `image_picker` — same package already required by the theme
/// feature's header image picker. This widget doesn't touch the Quill
/// document or the entry's `images` list itself; the caller
/// (diary_form_page) is responsible for inserting the image into the
/// document and updating the denormalized `images` field on save.
class ImagePickerButton extends StatefulWidget {
  final ValueChanged<String> onImageSelected;

  const ImagePickerButton({super.key, required this.onImageSelected});

  @override
  State<ImagePickerButton> createState() => _ImagePickerButtonState();
}

class _ImagePickerButtonState extends State<ImagePickerButton> {
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
      icon: const Icon(Icons.image_outlined),
      tooltip: 'Add photo',
      onPressed: _pickImage,
    );
  }
}