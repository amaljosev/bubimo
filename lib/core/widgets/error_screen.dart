// lib/core/widgets/error_screen.dart

import 'package:flutter/material.dart';

/// A full-screen error state with a message and an optional retry action.
///
/// If [onRetry] is provided, a "Retry" button is shown beneath the message
/// and invokes the callback when tapped. If [onRetry] is omitted, only the
/// message (and icon) are shown — use this for errors where retrying
/// wouldn't help (e.g. a validation failure the user can't fix by tapping
/// a button).
class ErrorScreen extends StatelessWidget {
  const ErrorScreen({
    super.key,
    required this.message,
    this.onRetry,
  });

  /// The error message to display to the user.
  final String message;

  /// Called when the user taps "Retry". If null, no retry button is shown.
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline,
                size: 48,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                message,
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              if (onRetry != null) ...[
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: onRetry,
                  child: const Text('Retry'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}