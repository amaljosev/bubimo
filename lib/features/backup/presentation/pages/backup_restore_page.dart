// lib/features/backup/presentation/pages/backup_restore_page.dart

import 'package:bubimo/features/backup/presentation/bloc/backup_bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';

/// Single screen for creating a local backup (`.bubimo` file) and
/// restoring diary entries from one — see `app_drawer.dart`'s
/// `onExportTap` wiring. Deliberately one screen for both directions
/// rather than two (see [BackupBloc]'s doc comment) — the drawer's
/// separate "Backup" item is reserved for a future cloud-sync feature
/// and intentionally left unwired by this feature.
class BackupRestorePage extends StatelessWidget {
  const BackupRestorePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<BackupBloc>(),
      child: const _BackupRestoreView(),
    );
  }
}

class _BackupRestoreView extends StatelessWidget {
  const _BackupRestoreView();

  Future<void> _handleExport(BuildContext context) async {
    context.read<BackupBloc>().add(const BackupExportRequested());
  }

  Future<void> _handleImport(BuildContext context) async {
    // File selection is a presentation-layer concern — the bloc only
    // ever receives an already-resolved path (see
    // BackupImportRequested's doc comment).
   final result = await FilePicker.platform.pickFiles(
  type: FileType.any,
);

    final pickedPath = result?.files.single.path;
    if (pickedPath == null || !context.mounted) return;

    context.read<BackupBloc>().add(BackupImportRequested(pickedPath));
  }

  Future<void> _showImportConfirmation(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Import backup?'),
        content: const Text(
          'Entries from the backup file will be added as new diary '
          'entries. Nothing already in your diary will be changed or '
          'removed.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Choose file'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await _handleImport(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Import & Export')),
      body: BlocConsumer<BackupBloc, BackupState>(
        listenWhen: (previous, current) =>
            current.status == BackupStatus.exportSuccess ||
            current.status == BackupStatus.importSuccess ||
            current.status == BackupStatus.failure,
        listener: (context, state) {
          switch (state.status) {
            case BackupStatus.exportSuccess:
              _showResultDialog(
                context,
                title: 'Backup created',
                message: state.exportResult!.savedToPublicDownloads
                    ? 'Saved to your Downloads folder:\n'
                        '${state.exportResult!.filePath}'
                    : 'Saved inside the app\'s own storage (your device '
                        'didn\'t make its Downloads folder available):\n'
                        '${state.exportResult!.filePath}',
              );
            case BackupStatus.importSuccess:
              final result = state.importResult!;
              _showResultDialog(
                context,
                title: 'Import complete',
                message: result.skippedCount == 0
                    ? 'Added ${result.importedCount} ${result.importedCount == 1 ? 'entry' : 'entries'} to your diary.'
                    : 'Added ${result.importedCount} ${result.importedCount == 1 ? 'entry' : 'entries'} to your diary. '
                        '${result.skippedCount} ${result.skippedCount == 1 ? 'entry' : 'entries'} in the file '
                        'couldn\'t be read and ${result.skippedCount == 1 ? 'was' : 'were'} skipped.',
              );
            case BackupStatus.failure:
              _showResultDialog(
                context,
                title: 'Something went wrong',
                message: state.errorMessage ?? 'Please try again.',
              );
            case BackupStatus.idle:
            case BackupStatus.exporting:
            case BackupStatus.importing:
              break;
          }
        },
        builder: (context, state) {
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
            children: [
              _SectionCard(
                icon: Icons.ios_share_rounded,
                title: 'Export',
                description:
                    'Save every diary entry — including photos, '
                    'stickers, and backgrounds — into a single backup '
                    'file you can keep or move to another device.',
                buttonLabel: 'Export diary',
                isLoading: state.status == BackupStatus.exporting,
                isEnabled: !state.isBusy,
                onPressed: () => _handleExport(context),
                colorScheme: colorScheme,
                textTheme: textTheme,
              ),
              const SizedBox(height: 20),
              _SectionCard(
                icon: Icons.file_download_outlined,
                title: 'Import',
                description:
                    'Add entries from a previously exported backup '
                    'file. Existing entries are never changed or '
                    'removed — imported entries are always added '
                    'alongside what\'s already in your diary.',
                buttonLabel: 'Choose backup file',
                isLoading: state.status == BackupStatus.importing,
                isEnabled: !state.isBusy,
                onPressed: () => _showImportConfirmation(context),
                colorScheme: colorScheme,
                textTheme: textTheme,
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _showResultDialog(
    BuildContext context, {
    required String title,
    required String message,
  }) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
    if (context.mounted) {
      context.read<BackupBloc>().add(const BackupResultAcknowledged());
    }
  }
}

/// A soft, rounded card for one action (export or import) — matches the
/// app's existing surface language (`colorScheme.surface`, low-alpha
/// shadow rather than Material elevation, generous rounded corners) per
/// `AppDrawer`'s and `DiaryBottomToolbar`'s established styling.
class _SectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String buttonLabel;
  final bool isLoading;
  final bool isEnabled;
  final VoidCallback onPressed;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  const _SectionCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.buttonLabel,
    required this.isLoading,
    required this.isEnabled,
    required this.onPressed,
    required this.colorScheme,
    required this.textTheme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: colorScheme.primary),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: isEnabled ? onPressed : null,
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(buttonLabel),
          ),
        ],
      ),
    );
  }
}