// lib/features/app_lock/presentation/widgets/lock_gate_background.dart
import 'dart:ui';

import 'package:flutter/material.dart';

/// Dimmed, blurred backdrop shown while the biometric system prompt
/// (bottom sheet on Android) is animating in or awaiting the user.
/// Prevents a dead/blank frame between the gate screen mounting and
/// the OS sheet appearing.
class LockGateBackground extends StatelessWidget {
  final Widget? child;

  const LockGateBackground({super.key, this.child});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Stack(
      fit: StackFit.expand,
      children: [
        ColoredBox(color: theme.colorScheme.surface),
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: ColoredBox(
            color: theme.colorScheme.surface.withValues(alpha: 0.6),
          ),
        ),
        if (child != null) child! else const _DefaultLoadingIndicator(),
      ],
    );
  }
}

class _DefaultLoadingIndicator extends StatelessWidget {
  const _DefaultLoadingIndicator();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.fingerprint, size: 56),
          SizedBox(height: 16),
          CircularProgressIndicator(),
        ],
      ),
    );
  }
}