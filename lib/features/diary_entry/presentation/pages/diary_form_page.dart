// lib/features/diary_entry/presentation/pages/diary_form_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../../domain/entities/diary_entry.dart';
import '../../domain/usecases/create_diary_entry.dart';
import '../../domain/usecases/update_diary_entry.dart';
import '../bloc/diary_form/diary_form_bloc.dart';
import '../widgets/mood_picker.dart';

/// Create/Update Screen.
///
/// Pass [existingEntry] to edit; omit it to create a new one. [onSaved] is
/// invoked once the save succeeds — the caller pops the route with a
/// success signal.
///
/// Edit mode only: intercepts back navigation (system gesture, AppBar
/// back button) via [PopScope] when [DiaryFormState.hasUnsavedChanges] is
/// true, prompting Save / Discard / Cancel. Create mode never prompts —
/// per product decision, there's nothing to "discard" when nothing
/// existed before.
class DiaryFormPage extends StatelessWidget {
  final DiaryEntry? existingEntry;
  final VoidCallback onSaved;

  const DiaryFormPage({
    super.key,
    this.existingEntry,
    required this.onSaved,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DiaryFormBloc(
        createDiaryEntry: GetIt.instance<CreateDiaryEntry>(),
        updateDiaryEntry: GetIt.instance<UpdateDiaryEntry>(),
        existingEntry: existingEntry,
      ),
      child: _DiaryFormView(onSaved: onSaved),
    );
  }
}

class _DiaryFormView extends StatefulWidget {
  final VoidCallback onSaved;

  const _DiaryFormView({required this.onSaved});

  @override
  State<_DiaryFormView> createState() => _DiaryFormViewState();
}

class _DiaryFormViewState extends State<_DiaryFormView> {
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;

  @override
  void initState() {
    super.initState();
    final state = context.read<DiaryFormBloc>().state;
    _titleController = TextEditingController(text: state.title);
    _contentController = TextEditingController(text: state.content);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(BuildContext context, DateTime currentDate) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: currentDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && context.mounted) {
      context.read<DiaryFormBloc>().add(DiaryFormDateChanged(picked));
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// Shows the Save / Discard / Cancel dialog. Returns `true` if the
  /// screen should proceed to pop (either because the user chose Discard,
  /// or because Save completed successfully), `false` if it should stay
  /// (Cancel, or Save failed).
  Future<bool> _confirmDiscard(BuildContext context) async {
    final bloc = context.read<DiaryFormBloc>();

    final choice = await showDialog<_DiscardChoice>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Unsaved changes'),
        content: const Text(
          'You have unsaved changes. Save them before leaving, or discard them?',
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.of(dialogContext).pop(_DiscardChoice.cancel),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () =>
                Navigator.of(dialogContext).pop(_DiscardChoice.discard),
            child: const Text('Discard'),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.of(dialogContext).pop(_DiscardChoice.save),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    switch (choice) {
      case _DiscardChoice.save:
        bloc.add(const DiaryFormSubmitted());
        // The BlocConsumer's listener handles calling widget.onSaved() /
        // popping once the submit succeeds — we don't pop here directly,
        // since submit is async and might fail (e.g. validation,
        // DB error), in which case the user should stay on the form.
        return false;
      case _DiscardChoice.discard:
        return true;
      case _DiscardChoice.cancel:
      case null:
        return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DiaryFormBloc, DiaryFormState>(
      listener: (context, state) {
        if (state.status == DiaryFormStatus.success) {
          widget.onSaved();
        }
        if (state.status == DiaryFormStatus.failure &&
            state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage!)),
          );
        }
      },
      builder: (context, state) {
        return PopScope(
          // Only intercept back navigation when there's something to
          // lose — create mode and "no changes yet" edits pop normally.
          canPop: !state.hasUnsavedChanges,
          onPopInvokedWithResult: (didPop, result) async {
            if (didPop) return;
            final shouldPop = await _confirmDiscard(context);
            if (shouldPop && context.mounted) {
              Navigator.of(context).pop();
            }
          },
          child: Scaffold(
            appBar: AppBar(
              title: Text(state.isEditing ? 'Edit Entry' : 'New Entry'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.check),
                  onPressed: state.status == DiaryFormStatus.submitting
                      ? null
                      : () => context
                          .read<DiaryFormBloc>()
                          .add(const DiaryFormSubmitted()),
                ),
              ],
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(hintText: 'Title'),
                    onChanged: (value) => context
                        .read<DiaryFormBloc>()
                        .add(DiaryFormTitleChanged(value)),
                  ),
                  const SizedBox(height: 12),
                  InkWell(
                    onTap: () => _pickDate(context, state.date),
                    borderRadius: BorderRadius.circular(8),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Date',
                        suffixIcon: Icon(Icons.calendar_today, size: 20),
                      ),
                      child: Text(_formatDate(state.date)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Mood',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  const SizedBox(height: 8),
                  MoodPicker(
                    selectedMood: state.selectedMood,
                    onMoodSelected: (mood) => context
                        .read<DiaryFormBloc>()
                        .add(DiaryFormMoodChanged(mood)),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _contentController,
                    decoration: const InputDecoration(
                      hintText: 'Write your thoughts...',
                      border: InputBorder.none,
                    ),
                    maxLines: null,
                    minLines: 8,
                    textAlignVertical: TextAlignVertical.top,
                    onChanged: (value) => context
                        .read<DiaryFormBloc>()
                        .add(DiaryFormContentChanged(value)),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

enum _DiscardChoice { save, discard, cancel }