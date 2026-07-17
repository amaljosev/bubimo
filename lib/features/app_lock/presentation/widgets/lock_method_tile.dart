// lib/features/app_lock/presentation/widgets/lock_method_tile.dart
import 'package:flutter/material.dart';

import '../../domain/entities/lock_method.dart';

/// A single row in the app lock listing screen representing one lock
/// method. Shows a check/highlight when [isSelected], and a subtitle
/// hint distinguishing "tap to activate" from "tap to set up".
class LockMethodTile extends StatelessWidget {
  final LockMethod method;
  final bool isSelected;
  final bool isConfigured;
  final VoidCallback onTap;

  const LockMethodTile({
    super.key,
    required this.method,
    required this.isSelected,
    required this.isConfigured,
    required this.onTap,
  });

  IconData get _icon {
    switch (method) {
      case LockMethod.biometric:
        return Icons.fingerprint;
      case LockMethod.pin:
        return Icons.pin_outlined;
      case LockMethod.pattern:
        return Icons.pattern;
      case LockMethod.deviceCredential:
        return Icons.phonelink_lock;
      case LockMethod.none:
        return Icons.lock_open;
    }
  }

  String get _subtitle {
    if (isSelected) return 'Active';
    if (isConfigured) return 'Tap to switch';
    return 'Tap to set up';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      leading: Icon(
        _icon,
        color: isSelected ? theme.colorScheme.primary : null,
      ),
      title: Text(method.label),
      subtitle: Text(_subtitle),
      trailing: isSelected
          ? Icon(Icons.check_circle, color: theme.colorScheme.primary)
          : null,
      onTap: onTap,
    );
  }
}