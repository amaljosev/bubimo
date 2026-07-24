// lib/features/app_lock/presentation/widgets/lock_palette.dart

import 'package:flutter/material.dart';

/// Shared visual tokens for every screen in this feature — the same
/// palette already used in app_lock_settings_page.dart and
/// pin_lock_screen.dart, centralized here instead of being redeclared
/// with `const _bgTop = ...` etc. in each file.
class LockPalette {
  const LockPalette._();

  static const bgTop = Color(0xFFFFE3D6);
  static const bgMid = Color(0xFFF6DCEF);
  static const bgBottom = Color(0xFFE2E2FB);
  static const ink = Color(0xFF2B2640);
  static const inkSoft = Color(0xFF8C8696);
  static const danger = Color(0xFFE4574B);

  static const gradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [bgTop, bgMid, bgBottom],
    stops: [0.0, 0.45, 1.0],
  );
}

/// The recurring wavy "cloud horizon" top edge used to transition from
/// the gradient header into a white content panel.
class CloudTopClipper extends CustomClipper<Path> {
  const CloudTopClipper();

  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, 26);
    path.quadraticBezierTo(size.width * 0.12, 4, size.width * 0.25, 16);
    path.quadraticBezierTo(size.width * 0.38, 30, size.width * 0.5, 12);
    path.quadraticBezierTo(size.width * 0.62, 0, size.width * 0.75, 18);
    path.quadraticBezierTo(size.width * 0.88, 32, size.width, 8);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
