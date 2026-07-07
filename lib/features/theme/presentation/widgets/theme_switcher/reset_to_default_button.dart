// lib/features/theme/presentation/widgets/theme_switcher/reset_to_default_button.dart

import 'package:flutter/material.dart';

class ResetToDefaultButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isEnabled;

  const ResetToDefaultButton({
    super.key,
    required this.onPressed,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: OutlinedButton.icon(
        onPressed: isEnabled ? onPressed : null,
        icon: const Icon(Icons.restart_alt),
        label: const Text('Reset to Default'),
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(46),
        ),
      ),
    );
  }
}
