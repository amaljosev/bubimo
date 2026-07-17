// lib/features/app_lock/presentation/widgets/pattern_verify_widget.dart
import 'package:flutter/material.dart';

import 'pattern_grid_widget.dart';

/// Thin wrapper around [PatternGridWidget] for the lock-gate's verify
/// step — no create/confirm cycle, just draw-and-submit. Kept as a
/// separate widget from the setup-time grid usage so the gate screen
/// doesn't depend on setup-screen widgets, and so verify-specific
/// affordances (e.g. a "forgot pattern?" link) have an obvious home.
class PatternVerifyWidget extends StatelessWidget {
  final ValueChanged<String> onPatternSubmitted;
  final VoidCallback onForgotPattern;

  const PatternVerifyWidget({
    super.key,
    required this.onPatternSubmitted,
    required this.onForgotPattern,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 300),
          child: PatternGridWidget(onPatternComplete: onPatternSubmitted),
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: onForgotPattern,
          child: const Text('Forgot pattern?'),
        ),
      ],
    );
  }
}