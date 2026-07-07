// lib/features/theme/presentation/widgets/custom_theme_form/header_image_picker_field.dart

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

/// Optional header image field for the Create Custom Theme screen.
///
/// Picking flow: gallery (`image_picker`) -> crop to a fixed 3600x1200
/// aspect ratio (`image_cropper`) -> the resulting cropped file path is
/// reported via [onImagePicked]. Only the final cropped path is ever
/// stored — the picker's raw/uncropped path is discarded.
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

  static const double _aspectWidth = 3600;
  static const double _aspectHeight = 1200;

  Future<void> _pickAndCrop(BuildContext context) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return; // User cancelled the gallery picker.

    final cropped = await ImageCropper().cropImage(
      sourcePath: picked.path,
      aspectRatio: const CropAspectRatio(
        ratioX: _aspectWidth,
        ratioY: _aspectHeight,
      ),
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop Header Image',
          lockAspectRatio: true,
          hideBottomControls: false,
        ),
        IOSUiSettings(
          title: 'Crop Header Image',
          aspectRatioLockEnabled: true,
        ),
      ],
    );

    if (cropped != null) onImagePicked(cropped.path);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Header image (optional)', style: theme.textTheme.labelLarge),
        const SizedBox(height: 8),
        Stack(
          children: [
            GestureDetector(
              onTap: () => _pickAndCrop(context),
              child: AspectRatio(
                aspectRatio: _aspectWidth / _aspectHeight,
                child: Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(16),
                    image: imagePath != null
                        ? DecorationImage(
                            image: FileImage(File(imagePath!)),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: imagePath == null
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.add_photo_alternate_outlined,
                                size: 32,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Choose header image',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        )
                      : null,
                ),
              ),
            ),
            if (imagePath != null)
              Positioned(
                top: 8,
                right: 8,
                child: _RemoveButton(onPressed: onImageRemoved),
              ),
          ],
        ),
      ],
    );
  }
}

class _RemoveButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _RemoveButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black54,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: const Padding(
          padding: EdgeInsets.all(6),
          child: Icon(Icons.close, size: 18, color: Colors.white),
        ),
      ),
    );
  }
}
