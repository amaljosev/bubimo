// lib/features/diary_entry/presentation/pages/diary_entry_view_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../../domain/entities/diary_entry.dart';
import '../../domain/usecases/delete_diary_entry.dart';
import '../bloc/diary_view/diary_view_bloc.dart';
import '../widgets/confirm_delete_dialog.dart';

/// Entry View Screen — displays title/content/date/mood, edit/delete.
///
/// Fetches the entry fresh by [entryId] via [DiaryViewBloc] rather than
/// receiving a [DiaryEntry] directly — after a successful edit, this
/// screen re-dispatches [DiaryViewRequested] on its own bloc and always
/// shows current DB state, without popping back through Home.
///
/// [onEdit] is a raw navigation callback (push the form, return the push
/// result) — refreshing on successful edit is handled internally by this
/// screen (it owns the [DiaryViewBloc] instance that needs refreshing),
/// not by the router.
class DiaryEntryViewPage extends StatelessWidget {
  final String entryId;
  final Future<bool?> Function(DiaryEntry entry) onEdit;
  final VoidCallback onDeleted;

  const DiaryEntryViewPage({
    super.key,
    required this.entryId,
    required this.onEdit,
    required this.onDeleted,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GetIt.instance<DiaryViewBloc>()
        ..add(DiaryViewRequested(entryId)),
      child: _DiaryEntryViewBody(
        entryId: entryId,
        onEdit: onEdit,
        onDeleted: onDeleted,
      ),
    );
  }
}

class _DiaryEntryViewBody extends StatefulWidget {
  final String entryId;
  final Future<bool?> Function(DiaryEntry entry) onEdit;
  final VoidCallback onDeleted;

  const _DiaryEntryViewBody({
    required this.entryId,
    required this.onEdit,
    required this.onDeleted,
  });

  @override
  State<_DiaryEntryViewBody> createState() => _DiaryEntryViewBodyState();
}

class _DiaryEntryViewBodyState extends State<_DiaryEntryViewBody> {
  bool _isDeleting = false;
  bool _isNavigatingToEdit = false;

  Future<void> _handleDelete(DiaryEntry entry) async {
    final confirmed = await showConfirmDeleteDialog(context);
    if (confirmed != true || !mounted) return;

    setState(() => _isDeleting = true);

    final deleteDiaryEntry = GetIt.instance<DeleteDiaryEntry>();
    final result = await deleteDiaryEntry(entry.id!);

    if (!mounted) return;

    result.fold(
      (failure) {
        setState(() => _isDeleting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(failure.message)),
        );
      },
      (_) => widget.onDeleted(),
    );
  }

  /// Pushes the edit form via [widget.onEdit] and, if it reports a
  /// successful save, re-dispatches [DiaryViewRequested] on this screen's
  /// own [DiaryViewBloc] — this is what shows the freshly saved data
  /// after returning from Edit, without this screen ever being popped.
  Future<void> _handleEdit(DiaryEntry entry) async {
    if (_isNavigatingToEdit) return;
    _isNavigatingToEdit = true;
    try {
      final result = await widget.onEdit(entry);
      if (result == true && mounted) {
        context.read<DiaryViewBloc>().add(DiaryViewRequested(widget.entryId));
      }
    } finally {
      _isNavigatingToEdit = false;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DiaryViewBloc, DiaryViewState>(
      builder: (context, state) {
        final entry = state is DiaryViewLoaded ? state.entry : null;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Entry'),
            actions: entry == null
                ? null
                : [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _handleEdit(entry),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: _isDeleting ? null : () => _handleDelete(entry),
                    ),
                  ],
          ),
          body: _buildBody(context, state),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, DiaryViewState state) {
    if (_isDeleting) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is DiaryViewLoading || state is DiaryViewInitial) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is DiaryViewError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(state.message, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => context
                    .read<DiaryViewBloc>()
                    .add(DiaryViewRequested(widget.entryId)),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final entry = (state as DiaryViewLoaded).entry;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (entry.mood != null) ...[
                Text(entry.mood!.emoji, style: const TextStyle(fontSize: 28)),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: Text(
                  entry.title,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _formatDate(entry.date),
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 16),
          Text(entry.content),
        ],
      ),
    );
  }
}