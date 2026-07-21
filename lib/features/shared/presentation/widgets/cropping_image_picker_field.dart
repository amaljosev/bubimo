// lib/features/shared/presentation/widgets/cropping_image_picker_field.dart

import 'dart:io';

import 'package:bubimo/core/error/exceptions.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/storage/media_storage_service.dart';

/// Reusable optional image field with a pick -> crop -> save flow.
///
/// Picking flow: gallery (`image_picker`) -> crop to [aspectWidth]:
/// [aspectHeight] (`image_cropper`) -> the cropped file is copied into
/// this app's own media directory via [MediaStorageService] (registered
/// in `injection.dart`) -> that durable path is reported via
/// [onImagePicked].
///
/// Neither the picker's raw/uncropped path NOR the cropper's own output
/// path is ever stored — both live in locations this app doesn't own
/// (OS temp dirs / gallery cache) and aren't guaranteed to survive past
/// this session, let alone a backup/restore onto a different device.
/// Only the path [MediaStorageService.saveFile] returns is durable and
/// safe to persist. See `media_storage_service.dart`'s doc comment for
/// the full rationale.
///
/// [category] tells [MediaStorageService] which media folder this
/// particular use of the field belongs to (e.g. profile avatar vs.
/// theme header) — required so every caller makes a deliberate choice
/// rather than everything landing in one undifferentiated folder.
///
/// Used for the custom theme header image (3600:1200, rounded rect) and
/// the profile avatar/header image (1:1 circular for avatar, 3600:1200
/// rounded rect for profile header).
class CroppingImagePickerField extends StatefulWidget {
  final String? imagePath;
  final ValueChanged<String> onImagePicked;
  final VoidCallback onImageRemoved;

  /// Aspect ratio numerator/denominator passed to the cropper.
  final double aspectWidth;
  final double aspectHeight;

  /// Which app-owned media folder the saved file belongs in — see
  /// [MediaCategory].
  final MediaCategory category;

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
    required this.category,
    this.label,
    this.cropToolbarTitle = 'Crop Image',
    this.circular = false,
    this.circularSize = 100,
  });

  @override
  State<CroppingImagePickerField> createState() =>
      _CroppingImagePickerFieldState();
}

class _CroppingImagePickerFieldState extends State<CroppingImagePickerField> {
  final MediaStorageService _mediaStorageService = getIt<MediaStorageService>();

  // Guards against rapid repeated taps opening the gallery
  // picker/cropper multiple times concurrently.
  bool _isPicking = false;

  Future<void> _pickAndCrop(BuildContext context) async {
    if (_isPicking) return;
    _isPicking = true;

    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: ImageSource.gallery);
      if (picked == null) return; // User cancelled the gallery picker.

      final cropped = await ImageCropper().cropImage(
        sourcePath: picked.path,
        aspectRatio: CropAspectRatio(
          ratioX: widget.aspectWidth,
          ratioY: widget.aspectHeight,
        ),
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: widget.cropToolbarTitle,
            lockAspectRatio: true,
            hideBottomControls: false,
            cropStyle: widget.circular ? CropStyle.circle : CropStyle.rectangle,
          ),
          IOSUiSettings(
            title: widget.cropToolbarTitle,
            aspectRatioLockEnabled: true,
            cropStyle: widget.circular ? CropStyle.circle : CropStyle.rectangle,
          ),
        ],
      );

      if (cropped == null) return; // User cancelled the crop step.

      // Copy the cropper's output into app-owned storage before
      // reporting it — the cropped file itself is still a temp file at
      // this point, with the exact same lifetime problem as the
      // pre-crop picker path.
      final savedPath = await _mediaStorageService.saveFile(
        File(cropped.path),
        category: widget.category,
      );
      widget.onImagePicked(savedPath);
    } on MediaStorageException catch (e) {
      if (mounted) {
        // ignore: use_build_context_synchronously
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
    final theme = Theme.of(context);
    final borderRadius = widget.circular
        ? BorderRadius.circular(999)
        : BorderRadius.circular(16);

    final preview = GestureDetector(
      onTap: () => _pickAndCrop(context),
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: borderRadius,
          image: widget.imagePath != null
              ? DecorationImage(
                  image: FileImage(File(widget.imagePath!)),
                  fit: BoxFit.cover,
                )
              : null,
        ),
        child: widget.imagePath == null
            ? Center(
                child: widget.circular
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
        widget.circular
            ? SizedBox(
                width: widget.circularSize,
                height: widget.circularSize,
                child: preview,
              )
            : AspectRatio(
                aspectRatio: widget.aspectWidth / widget.aspectHeight,
                child: preview,
              ),
        if (widget.imagePath != null)
          Positioned(
            top: widget.circular ? -4 : 8,
            right: widget.circular ? -4 : 8,
            child: _RemoveButton(onPressed: widget.onImageRemoved),
          ),
      ],
    );

    if (widget.label == null) return stack;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label!, style: theme.textTheme.labelLarge),
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