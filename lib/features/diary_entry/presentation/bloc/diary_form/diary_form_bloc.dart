// lib/features/diary_entry/presentation/bloc/diary_form/diary_form_bloc.dart

import 'package:bubimo/features/diary_entry/domain/entities/diary_entry.dart';
import 'package:bubimo/features/diary_entry/domain/entities/mood.dart';
import 'package:bubimo/features/diary_entry/domain/usecases/create_diary_entry.dart';
import 'package:bubimo/features/diary_entry/domain/usecases/update_diary_entry.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'diary_form_event.dart';
part 'diary_form_state.dart';

/// Drives the Create/Update Screen.
///
/// Same bloc handles both flows: pass [existingEntry] to edit, or omit it
/// to create a new one. Seeds `original*` state fields from
/// [existingEntry] so [DiaryFormState.hasUnsavedChanges] can detect real
/// edits for the back-navigation discard-changes prompt (edit mode only).
class DiaryFormBloc extends Bloc<DiaryFormEvent, DiaryFormState> {
  final CreateDiaryEntry createDiaryEntry;
  final UpdateDiaryEntry updateDiaryEntry;

  DiaryFormBloc({
    required this.createDiaryEntry,
    required this.updateDiaryEntry,
    DiaryEntry? existingEntry,
  }) : super(
          DiaryFormState(
            id: existingEntry?.id,
            title: existingEntry?.title ?? '',
            content: existingEntry?.content ?? '',
            date: existingEntry?.date ?? DateTime.now(),
            originalCreatedAt: existingEntry?.createdAt,
            selectedMood: existingEntry?.mood,
            originalTitle: existingEntry?.title,
            originalContent: existingEntry?.content,
            originalDate: existingEntry?.date,
            originalMood: existingEntry?.mood,
          ),
        ) {
    on<DiaryFormTitleChanged>(_onTitleChanged);
    on<DiaryFormContentChanged>(_onContentChanged);
    on<DiaryFormDateChanged>(_onDateChanged);
    on<DiaryFormMoodChanged>(_onMoodChanged);
    on<DiaryFormSubmitted>(_onSubmitted);
  }

  void _onTitleChanged(
    DiaryFormTitleChanged event,
    Emitter<DiaryFormState> emit,
  ) {
    emit(state.copyWith(title: event.title));
  }

  void _onContentChanged(
    DiaryFormContentChanged event,
    Emitter<DiaryFormState> emit,
  ) {
    emit(state.copyWith(content: event.content));
  }

  void _onDateChanged(
    DiaryFormDateChanged event,
    Emitter<DiaryFormState> emit,
  ) {
    emit(state.copyWith(date: event.date));
  }

  void _onMoodChanged(
    DiaryFormMoodChanged event,
    Emitter<DiaryFormState> emit,
  ) {
    emit(state.copyWith(selectedMood: event.mood));
  }

  Future<void> _onSubmitted(
    DiaryFormSubmitted event,
    Emitter<DiaryFormState> emit,
  ) async {
    emit(state.copyWith(status: DiaryFormStatus.submitting));

    final now = DateTime.now();

    if (state.isEditing) {
      final updated = DiaryEntry(
        id: state.id,
        title: state.title,
        content: state.content,
        date: state.date,
        createdAt: state.originalCreatedAt ?? now,
        updatedAt: now,
        mood: state.selectedMood,
      );
      final result = await updateDiaryEntry(updated);
      result.fold(
        (failure) => emit(state.copyWith(
          status: DiaryFormStatus.failure,
          errorMessage: failure.message,
        )),
        (_) => emit(state.copyWith(status: DiaryFormStatus.success)),
      );
    } else {
      final newEntry = DiaryEntry(
        title: state.title,
        content: state.content,
        date: state.date,
        createdAt: now,
        updatedAt: now,
        mood: state.selectedMood,
      );
      final result = await createDiaryEntry(newEntry);
      result.fold(
        (failure) => emit(state.copyWith(
          status: DiaryFormStatus.failure,
          errorMessage: failure.message,
        )),
        (_) => emit(state.copyWith(status: DiaryFormStatus.success)),
      );
    }
  }
}