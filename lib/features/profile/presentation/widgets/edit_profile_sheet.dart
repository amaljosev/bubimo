// lib/features/profile/presentation/widgets/edit_profile_sheet.dart

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../../shared/presentation/widgets/cropping_image_picker_field.dart';
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

  /// Copies the cropper's output file into the app's documents directory
  /// so it survives independently of the cropper's cache location — the
  /// same durable-local-path approach used for custom theme header
  /// images.
  Future<String> _persistCroppedImage(String croppedPath, String prefix) async {
    final docsDir = await getApplicationDocumentsDirectory();
    final ext = p.extension(croppedPath);
    final destPath = p.join(
      docsDir.path,
      '${prefix}_${DateTime.now().millisecondsSinceEpoch}$ext',
    );
    await File(croppedPath).copy(destPath);
    return destPath;
  }

  Future<void> _onAvatarPicked(String croppedPath) async {
    final path = await _persistCroppedImage(croppedPath, 'avatar');
    if (mounted) setState(() => _avatarPath = path);
  }

  Future<void> _onHeaderImagePicked(String croppedPath) async {
    final path = await _persistCroppedImage(croppedPath, 'profile_header');
    if (mounted) setState(() => _headerImagePath = path);
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
              CroppingImagePickerField(
                imagePath: _headerImagePath,
                onImagePicked: _onHeaderImagePicked,
                onImageRemoved: () =>
                    setState(() => _headerImagePath = null),
                aspectWidth: 3600,
                aspectHeight: 1200,
                label: 'Header image',
                cropToolbarTitle: 'Crop Header Image',
              ),
              const SizedBox(height: 24),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CroppingImagePickerField(
                    imagePath: _avatarPath,
                    onImagePicked: _onAvatarPicked,
                    onImageRemoved: () => setState(() => _avatarPath = null),
                    aspectWidth: 1,
                    aspectHeight: 1,
                    circular: true,
                    circularSize: 88,
                    cropToolbarTitle: 'Crop Profile Photo',
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Profile photo', style: textTheme.labelLarge),
                        const SizedBox(height: 2),
                        Text(
                          'Shown as your avatar',
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
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