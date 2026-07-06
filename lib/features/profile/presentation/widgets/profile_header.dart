// lib/features/profile/presentation/widgets/profile_header.dart

import 'dart:io';

import 'package:flutter/material.dart';

import '../../domain/entities/user_profile.dart';

/// The hero section of the combined Profile & Analytics screen.
///
/// Styled as a "journal cover": a large rounded card carrying the
/// header image (or a themed paper-gradient fallback) with the user's
/// avatar inset at the bottom-left in a circular notch, evoking a photo
/// tucked into the inside cover of a physical diary — rather than a
/// generic social-app cover-photo banner.
class ProfileHeader extends StatelessWidget {
  final UserProfile profile;
  final VoidCallback onEdit;

  const ProfileHeader({
    super.key,
    required this.profile,
    required this.onEdit,
  });

  static const double _coverHeight = 168;
  static const double _avatarSize = 84;
  static const double _avatarOverlap = _avatarSize / 2;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final diaryName = profile.diaryName?.trim();
    final username = profile.username?.trim();

    return Padding(
      padding: EdgeInsets.only(bottom: _avatarOverlap + 12),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // The "cover" itself.
          ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: SizedBox(
              height: _coverHeight,
              width: double.infinity,
              child: _CoverBackground(
                headerImagePath: profile.headerImagePath,
                colorScheme: colorScheme,
              ),
            ),
          ),

          // Edit affordance, top-right.
          Positioned(
            top: 12,
            right: 12,
            child: _EditButton(onPressed: onEdit),
          ),

          // Diary name + username, bottom-right of the cover so they sit
          // beside the avatar notch rather than behind it.
          Positioned(
            left: _avatarSize + 28,
            right: 16,
            bottom: -_avatarOverlap + 8,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  (diaryName == null || diaryName.isEmpty)
                      ? 'My Diary'
                      : diaryName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  (username == null || username.isEmpty)
                      ? 'Tap to set up your profile'
                      : username,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),

          // Avatar notch, inset at the bottom-left, overlapping the
          // cover's bottom edge.
          Positioned(
            left: 20,
            bottom: -_avatarOverlap,
            child: _AvatarNotch(
              avatarPath: profile.avatarPath,
              size: _avatarSize,
              colorScheme: colorScheme,
            ),
          ),
        ],
      ),
    );
  }
}

class _CoverBackground extends StatelessWidget {
  final String? headerImagePath;
  final ColorScheme colorScheme;

  const _CoverBackground({
    required this.headerImagePath,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    if (headerImagePath != null && File(headerImagePath!).existsSync()) {
      return Stack(
        fit: StackFit.expand,
        children: [
          Image.file(File(headerImagePath!), fit: BoxFit.cover),
          // Soft scrim so the diary name stays legible over any photo.
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.0),
                  Colors.black.withValues(alpha: 0.45),
                ],
              ),
            ),
          ),
        ],
      );
    }

    // Themed "paper" fallback — a warm two-tone diagonal wash derived
    // from the active color scheme rather than a hardcoded brand color,
    // so it always matches the user's selected theme.
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primaryContainer,
            colorScheme.primary.withValues(alpha: 0.75),
          ],
        ),
      ),
      child: CustomPaint(painter: _PaperGrainPainter(colorScheme)),
    );
  }
}

/// A faint scattering of dots suggesting paper grain/texture — the
/// signature detail that ties the fallback cover back to the "diary"
/// subject matter instead of reading as a flat generic gradient.
class _PaperGrainPainter extends CustomPainter {
  final ColorScheme colorScheme;

  _PaperGrainPainter(this.colorScheme);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = colorScheme.onPrimaryContainer.withValues(alpha: 0.05);

    const spacing = 18.0;
    for (double y = 0; y < size.height; y += spacing) {
      for (double x = 0; x < size.width; x += spacing) {
        final offset = (y ~/ spacing).isEven ? 0.0 : spacing / 2;
        canvas.drawCircle(Offset(x + offset, y), 1.1, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _PaperGrainPainter oldDelegate) => false;
}

class _AvatarNotch extends StatelessWidget {
  final String? avatarPath;
  final double size;
  final ColorScheme colorScheme;

  const _AvatarNotch({
    required this.avatarPath,
    required this.size,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    final hasAvatar = avatarPath != null && File(avatarPath!).existsSync();

    return Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: CircleAvatar(
        backgroundColor: colorScheme.surfaceContainerHighest,
        backgroundImage: hasAvatar ? FileImage(File(avatarPath!)) : null,
        child: hasAvatar
            ? null
            : Icon(
                Icons.person_rounded,
                size: size * 0.5,
                color: colorScheme.onSurfaceVariant,
              ),
      ),
    );
  }
}

class _EditButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _EditButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.28),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: const Padding(
          padding: EdgeInsets.all(8),
          child: Icon(Icons.edit_rounded, size: 18, color: Colors.white),
        ),
      ),
    );
  }
}