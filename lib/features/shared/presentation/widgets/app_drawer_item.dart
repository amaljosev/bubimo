// lib/features/shared/presentation/widgets/app_drawer_item.dart

import 'package:flutter/material.dart';

/// A single tappable row in [AppDrawer].
///
/// Uses an [AnimatedContainer] for the selected/hover-like background
/// and an [InkWell] purely for tap feedback + accessibility (focus,
/// splash) — the same "custom animated surface + Material feedback
/// underneath" pattern as `_FavoritesFilterToggle` in `home_page.dart`.
class AppDrawerItem extends StatelessWidget {
  const AppDrawerItem({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.isSelected = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool isSelected;

  static const _radius = 14.0;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final foreground = isSelected
        ? colorScheme.primary
        : colorScheme.onSurfaceVariant;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primary.withValues(alpha: 0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(_radius),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(_radius),
            onTap: onTap == null
                ? null
                : () {
                    // Close the drawer first so the destination screen
                    // isn't fighting the drawer's own closing
                    // animation for frame budget.
                    Navigator.of(context).pop();
                    onTap!.call();
                  },
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 13,
              ),
              child: Row(
                children: [
                  AnimatedScale(
                    duration: const Duration(milliseconds: 200),
                    scale: isSelected ? 1.05 : 1.0,
                    child: Icon(icon, size: 22, color: foreground),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      label,
                      style: textTheme.bodyLarge?.copyWith(
                        color: foreground,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w500,
                      ),
                    ),
                  ),
                  if (isSelected)
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: colorScheme.primary,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}