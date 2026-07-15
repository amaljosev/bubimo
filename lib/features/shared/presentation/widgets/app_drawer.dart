// lib/features/shared/presentation/widgets/app_drawer.dart

import 'package:flutter/material.dart';

import 'app_drawer_item.dart';
import 'app_drawer_header.dart';

/// The app's primary navigation [Drawer].
///
/// A presentation-layer widget owned by no single feature — it only
/// dispatches to routes/callbacks that belong to their own features
/// (Diary Lock, Backup, Export, Settings, etc.), so it stays free of
/// any feature-specific BLoC or domain dependency. Wire each
/// [AppDrawerItem.onTap] to the relevant `context.push(AppRoutes.xxx)`
/// call, or pass a callback down from the page that hosts this drawer.
///
/// Visually, this mirrors the same design language as the rest of the
/// app (see `HomePage`'s SliverAppBar and `_FavoritesFilterToggle`):
/// `colorScheme.surface`/`surfaceContainerHighest`, soft low-alpha
/// shadows rather than Material elevation, generous rounded corners,
/// and small `AnimatedContainer`/`InkWell` micro-interactions instead
/// of default Material ripple-only feedback.
class AppDrawer extends StatelessWidget {
  const AppDrawer({
    super.key,
    required this.appName,
    this.appIcon = Icons.auto_stories_rounded,
    this.selectedRoute,
    this.onDiaryLockTap,
    this.onBackupTap,
    this.onExportTap,
    this.onHelpTap,
    this.onShareAppTap,
    this.onSettingsTap,
  });

  /// Shown next to the header icon. Pass your app's display name
  /// (e.g. "Routine").
  final String appName;

  /// Header glyph. Defaults to a book/journal icon fitting a diary
  /// app; override per-app as needed.
  final IconData appIcon;

  /// Optional key identifying the currently active destination, used
  /// only to highlight the matching item (e.g. `'settings'`). Leave
  /// null if this drawer never represents "current location".
  final String? selectedRoute;

  final VoidCallback? onDiaryLockTap;
  final VoidCallback? onBackupTap;
  final VoidCallback? onExportTap;
  final VoidCallback? onHelpTap;
  final VoidCallback? onShareAppTap;
  final VoidCallback? onSettingsTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final mediaQuery = MediaQuery.of(context);

    // Cap the drawer width on large/tablet screens rather than letting
    // it stretch edge-to-edge — matches the "responsive and consistent"
    // requirement without introducing a separate tablet layout.
    final drawerWidth = mediaQuery.size.width < 400
        ? mediaQuery.size.width * 0.84
        : 320.0;

    return Drawer(
      width: drawerWidth,
      backgroundColor: colorScheme.surface,
      // Flat edge against the body, soft custom shadow on the exposed
      // edge only — avoids the default Material drawer's harsh single-
      // side elevation shadow which looks dated against this app's
      // otherwise elevation:0 surfaces.
      elevation: 0,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.10),
              blurRadius: 24,
              offset: const Offset(6, 0),
            ),
          ],
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppDrawerHeader(appName: appName, appIcon: appIcon),
              const SizedBox(height: 8),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  children: [
                    AppDrawerItem(
                      icon: Icons.lock_outline_rounded,
                      label: 'Diary Lock',
                      isSelected: selectedRoute == 'diary_lock',
                      onTap: onDiaryLockTap,
                    ),
                    AppDrawerItem(
                      icon: Icons.cloud_upload_outlined,
                      label: 'Backup',
                      isSelected: selectedRoute == 'backup',
                      onTap: onBackupTap,
                    ),
                    AppDrawerItem(
                      icon: Icons.ios_share_rounded,
                      label: 'Export',
                      isSelected: selectedRoute == 'export',
                      onTap: onExportTap,
                    ),
                    const _DrawerSectionDivider(),
                    AppDrawerItem(
                      icon: Icons.help_outline_rounded,
                      label: 'Help',
                      isSelected: selectedRoute == 'help',
                      onTap: onHelpTap,
                    ),
                    AppDrawerItem(
                      icon: Icons.favorite_outline_rounded,
                      label: 'Share App',
                      isSelected: selectedRoute == 'share_app',
                      onTap: onShareAppTap,
                    ),
                  ],
                ),
              ),
              const _DrawerSectionDivider(horizontalInset: 20),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
                child: AppDrawerItem(
                  icon: Icons.settings_outlined,
                  label: 'Settings',
                  isSelected: selectedRoute == 'settings',
                  onTap: onSettingsTap,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A subtle full-bleed-minus-inset divider between drawer sections —
/// deliberately faint (low alpha on `outlineVariant`) so it reads as
/// spacing/grouping rather than a hard rule.
class _DrawerSectionDivider extends StatelessWidget {
  const _DrawerSectionDivider({this.horizontalInset = 16});

  final double horizontalInset;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalInset, vertical: 8),
      child: Divider(
        height: 1,
        thickness: 1,
        color: colorScheme.outlineVariant.withValues(alpha: 0.4),
      ),
    );
  }
}