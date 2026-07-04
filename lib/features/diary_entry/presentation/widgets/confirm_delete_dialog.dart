// lib/features/diary_entry/presentation/widgets/confirm_delete_dialog.dart

import 'package:flutter/material.dart';

/// Shows a confirmation dialog before a destructive delete action.
///
/// Returns `true` if the user confirmed deletion, `false`/`null`
/// otherwise. Used by the Entry View screen before calling
/// `DeleteDiaryEntry` — diary entries are emotionally high-value, so
/// deletion should never happen from a single accidental tap.
Future<bool?> showConfirmDeleteDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: const Text('Delete this entry?'),
        content: const Text(
          'This diary entry will be permanently deleted. This action '
          'cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(dialogContext).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      );
    },
  );
}