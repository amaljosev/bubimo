// lib/features/shared/presentation/widgets/cropping_image_picker_field.dart

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

/// Reusable optional image field with a pick -> crop flow.
///
/// Picking flow: gallery (`image_picker`) -> crop to [aspectWidth]:
/// [aspectHeight] (`image_cropper`) -> the resulting cropped file path is
/// reported via [onImagePicked]. Only the final cropped path is ever
/// stored — the picker's raw/uncropped path is discarded.
///
/// Used for both the custom theme header image (3600:1200, rounded rect)
/// and the profile avatar/header image (1:1 circular for avatar, 3600:1200
/// rounded rect for profile header).
class CroppingImagePickerField extends StatelessWidget {
  final String? imagePath;
  final ValueChanged<String> onImagePicked;
  final VoidCallback onImageRemoved;

  /// Aspect ratio numerator/denominator passed to the cropper.
  final double aspectWidth;
  final double aspectHeight;

  /// Label shown above the picker. Pass null to omit (e.g. when the
  /// caller renders its own label/subtitle alongside a compact tile).
  final String? label;

  /// Title shown in the native crop UI toolbar.
  final String cropToolbarTitle;

  /// Renders the preview as a circle instead of a rounded rectangle.
  /// When true, the field becomes a fixed-size square tile rather than
  /// filling width via [AspectRatio].
  final bool circular;

  /// Size (width == height) used only when [circular] is true.
  final double circularSize;

  const CroppingImagePickerField({
    super.key,
    required this.imagePath,
    required this.onImagePicked,
    required this.onImageRemoved,
    required this.aspectWidth,
    required this.aspectHeight,
    this.label,
    this.cropToolbarTitle = 'Crop Image',
    this.circular = false,
    this.circularSize = 100,
  });

  Future<void> _pickAndCrop(BuildContext context) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return; // User cancelled the gallery picker.

    final cropped = await ImageCropper().cropImage(
      sourcePath: picked.path,
      aspectRatio: CropAspectRatio(
        ratioX: aspectWidth,
        ratioY: aspectHeight,
      ),
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: cropToolbarTitle,
          lockAspectRatio: true,
          hideBottomControls: false,
          cropStyle: circular ? CropStyle.circle : CropStyle.rectangle,
        ),
        IOSUiSettings(
          title: cropToolbarTitle,
          aspectRatioLockEnabled: true,
          cropStyle: circular ? CropStyle.circle : CropStyle.rectangle,
        ),
      ],
    );

    if (cropped != null) onImagePicked(cropped.path);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final borderRadius = circular
        ? BorderRadius.circular(999)
        : BorderRadius.circular(16);

    final preview = GestureDetector(
      onTap: () => _pickAndCrop(context),
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: borderRadius,
          image: imagePath != null
              ? DecorationImage(
                  image: FileImage(File(imagePath!)),
                  fit: BoxFit.cover,
                )
              : null,
        ),
        child: imagePath == null
            ? Center(
                child: circular
                    ? Icon(
                        Icons.add_photo_alternate_outlined,
                        size: 28,
                        color: theme.colorScheme.onSurfaceVariant,
                      )
                    : Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.add_photo_alternate_outlined,
                            size: 32,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Choose image',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
              )
            : null,
      ),
    );

    final stack = Stack(
      children: [
        circular
            ? SizedBox(
                width: circularSize,
                height: circularSize,
                child: preview,
              )
            : AspectRatio(
                aspectRatio: aspectWidth / aspectHeight,
                child: preview,
              ),
        if (imagePath != null)
          Positioned(
            top: circular ? -4 : 8,
            right: circular ? -4 : 8,
            child: _RemoveButton(onPressed: onImageRemoved),
          ),
      ],
    );

    if (label == null) return stack;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label!, style: theme.textTheme.labelLarge),
        const SizedBox(height: 8),
        stack,
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