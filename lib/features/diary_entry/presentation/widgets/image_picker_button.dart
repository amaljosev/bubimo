// lib/features/diary_entry/presentation/widgets/image_picker_button.dart

import 'dart:io';

import 'package:bubimo/core/error/exceptions.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/storage/media_storage_service.dart';

/// An icon button that opens the device gallery and reports the picked
/// image's durable, app-owned file path via [onImageSelected].
///
/// Uses `image_picker` — same package already required by the theme
/// feature's header image picker. This widget doesn't touch the Quill
/// document or the entry's `images` list itself; the caller
/// (diary_form_page) is responsible for inserting the image into the
/// document and updating the denormalized `images` field on save.
///
/// The path reported via [onImageSelected] is IMPORTANT: it is the path
/// [MediaStorageService.saveFile] returns, not `image_picker`'s own
/// result path. This matters more here than almost anywhere else in the
/// app — this path gets embedded directly into the Quill Delta JSON
/// that becomes `DiaryEntry.content` (see [ResizableImageEmbedBuilder],
/// which resolves it as a `FileImage`). If a raw gallery/temp path were
/// stored here instead, the image would break inside the rich-text
/// content itself, not just in a denormalized list field — much harder
/// to repair after the fact, since it would mean rewriting Delta JSON
/// rather than updating a single DB column. See
/// `media_storage_service.dart`'s doc comment for the full rationale.
class ImagePickerButton extends StatefulWidget {
  final ValueChanged<String> onImageSelected;

  const ImagePickerButton({super.key, required this.onImageSelected});

  @override
  State<ImagePickerButton> createState() => _ImagePickerButtonState();
}

class _ImagePickerButtonState extends State<ImagePickerButton> {
  final ImagePicker _imagePicker = ImagePicker();
  final MediaStorageService _mediaStorageService = getIt<MediaStorageService>();

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
      if (picked == null) return;

      final savedPath = await _mediaStorageService.saveFile(
        File(picked.path),
        category: MediaCategory.diaryImages,
      );
      widget.onImageSelected(savedPath);
    } on MediaStorageException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not save image: ${e.message}')),
        );
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