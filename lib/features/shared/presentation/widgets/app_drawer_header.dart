// lib/features/shared/presentation/widgets/app_drawer_header.dart

import 'package:flutter/material.dart';

/// The drawer's header: a soft gradient icon badge next to the app
/// name, sitting in its own tinted band above the item list.
///
/// Deliberately skips Flutter's built-in [DrawerHeader]/
/// [UserAccountsDrawerHeader] — both assume a fixed-height banner-style
/// image/account block that doesn't match this app's flatter, more
/// editorial header style (see `HomePage`'s `SliverAppBar` treatment).
class AppDrawerHeader extends StatelessWidget {
  const AppDrawerHeader({
    super.key,
    required this.appName,
    required this.appIcon,
  });

  final String appName;
  final IconData appIcon;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primary.withValues(alpha: 0.10),
            colorScheme.surface.withValues(alpha: 0),
          ],
        ),
      ),
      child: Row(
        children: [
          _IconBadge(icon: appIcon),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  appName,
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                    color: colorScheme.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  'Your space, your story',
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// A rounded-square gradient badge behind the header icon — primary →
/// secondary diagonal gradient, echoing each built-in theme's own
/// primary/secondary pairing (see `BuiltInThemes`) so the badge always
/// reads as "on brand" no matter which theme is active.
class _IconBadge extends StatelessWidget {
  const _IconBadge({required this.icon});

  final IconData icon;

  static const double _size = 48;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: _size,
      height: _size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [colorScheme.primary, colorScheme.secondary],
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Icon(icon, color: colorScheme.onPrimary, size: 24),
    );
  }
}