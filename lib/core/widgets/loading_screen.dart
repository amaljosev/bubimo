// lib/core/widgets/loading_screen.dart

import 'package:flutter/material.dart';

/// A full-screen, centered loading indicator.
///
/// Intended for use as a whole-screen placeholder while async work (e.g.
/// initial data load, database open) is in progress — not for inline
/// loading states within an otherwise-populated screen.
class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key, this.message});

  /// Optional message shown below the spinner (e.g. "Loading your entries…").
  final String? message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            if (message != null) ...[
              const SizedBox(height: 16),
              Text(
                message!,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}