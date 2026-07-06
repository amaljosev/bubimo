// lib/features/profile/presentation/widgets/edit_profile_sheet.dart

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../domain/entities/user_profile.dart';

/// Bottom sheet for editing the optional profile fields: avatar, header
/// image, username, diary name. Every field is nullable/clearable —
/// nothing here is required.
///
/// Returns the edited [UserProfile] via [Navigator.pop] when saved, or
/// `null` if dismissed without saving.
class EditProfileSheet extends StatefulWidget {
  final UserProfile profile;

  const EditProfileSheet({super.key, required this.profile});

  /// Convenience opener — shows the sheet and returns the saved profile,
  /// or null if the user dismissed it without saving.
  static Future<UserProfile?> show(BuildContext context, UserProfile profile) {
    return showModalBottomSheet<UserProfile>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => EditProfileSheet(profile: profile),
    );
  }

  @override
  State<EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<EditProfileSheet> {
  late final TextEditingController _usernameController;
  late final TextEditingController _diaryNameController;

  String? _avatarPath;
  String? _headerImagePath;

  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(text: widget.profile.username);
    _diaryNameController =
        TextEditingController(text: widget.profile.diaryName);
    _avatarPath = widget.profile.avatarPath;
    _headerImagePath = widget.profile.headerImagePath;
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _diaryNameController.dispose();
    super.dispose();
  }

  /// Picks an image and copies it into the app's documents directory so
  /// it survives independently of wherever the OS picker sourced it
  /// from — the same durable-local-path approach used for custom theme
  /// header images.
  Future<String?> _pickAndPersistImage() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (picked == null) return null;

    final docsDir = await getApplicationDocumentsDirectory();
    final ext = p.extension(picked.path);
    final destPath = p.join(
      docsDir.path,
      'profile_${DateTime.now().millisecondsSinceEpoch}$ext',
    );
    await File(picked.path).copy(destPath);
    return destPath;
  }

  Future<void> _pickAvatar() async {
    final path = await _pickAndPersistImage();
    if (path != null) setState(() => _avatarPath = path);
  }

  Future<void> _pickHeaderImage() async {
    final path = await _pickAndPersistImage();
    if (path != null) setState(() => _headerImagePath = path);
  }

  void _save() {
    final updated = widget.profile.copyWith(
      username: _usernameController.text.trim().isEmpty
          ? null
          : _usernameController.text.trim(),
      clearUsername: _usernameController.text.trim().isEmpty,
      diaryName: _diaryNameController.text.trim().isEmpty
          ? null
          : _diaryNameController.text.trim(),
      clearDiaryName: _diaryNameController.text.trim().isEmpty,
      avatarPath: _avatarPath,
      clearAvatarPath: _avatarPath == null,
      headerImagePath: _headerImagePath,
      clearHeaderImagePath: _headerImagePath == null,
    );
    Navigator.of(context).pop(updated);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(28),
            ),
          ),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Edit profile',
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 20),
              _ImagePickerTile(
                label: 'Header image',
                subtitle: 'Shown behind your profile card',
                imagePath: _headerImagePath,
                onPick: _pickHeaderImage,
                onClear: _headerImagePath == null
                    ? null
                    : () => setState(() => _headerImagePath = null),
                previewHeight: 100,
              ),
              const SizedBox(height: 16),
              _ImagePickerTile(
                label: 'Profile photo',
                subtitle: 'Shown as your avatar',
                imagePath: _avatarPath,
                onPick: _pickAvatar,
                onClear: _avatarPath == null
                    ? null
                    : () => setState(() => _avatarPath = null),
                previewHeight: 100,
                circular: true,
              ),
              const SizedBox(height: 24),
              Text('Username', style: textTheme.labelLarge),
              const SizedBox(height: 8),
              TextField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  hintText: 'Optional',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              Text('Diary name', style: textTheme.labelLarge),
              const SizedBox(height: 8),
              TextField(
                controller: _diaryNameController,
                decoration: const InputDecoration(
                  hintText: 'e.g. "My Diary"',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 28),
              FilledButton(
                onPressed: _save,
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text('Save'),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ImagePickerTile extends StatelessWidget {
  final String label;
  final String subtitle;
  final String? imagePath;
  final VoidCallback onPick;
  final VoidCallback? onClear;
  final double previewHeight;
  final bool circular;

  const _ImagePickerTile({
    required this.label,
    required this.subtitle,
    required this.imagePath,
    required this.onPick,
    required this.onClear,
    required this.previewHeight,
    this.circular = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final hasImage = imagePath != null && File(imagePath!).existsSync();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        InkWell(
          onTap: onPick,
          borderRadius: BorderRadius.circular(circular ? 999 : 14),
          child: Container(
            width: previewHeight,
            height: previewHeight,
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(circular ? 999 : 14),
              image: hasImage
                  ? DecorationImage(
                      image: FileImage(File(imagePath!)),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: hasImage
                ? null
                : Icon(
                    Icons.add_photo_alternate_outlined,
                    color: colorScheme.onSurfaceVariant,
                  ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: textTheme.labelLarge),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              if (onClear != null) ...[
                const SizedBox(height: 4),
                TextButton(
                  onPressed: onClear,
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(0, 0),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text('Remove'),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}