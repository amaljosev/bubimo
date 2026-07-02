// lib/features/diary_entry/presentation/bloc/diary_form/diary_form_state.dart
part of 'diary_form_bloc.dart';

enum DiaryFormStatus { initial, submitting, success, failure }

/// Single state object for the Create/Update form.
///
/// `original*` fields snapshot the entry's values as they were when the
/// form opened (null/defaults in create mode, where there's nothing to
/// compare against and [hasUnsavedChanges] is never consulted). Used by
/// [hasUnsavedChanges] to detect real edits — comparing current vs.
/// original values rather than a raw "something changed" flag, so
/// reverting a field back to its original value doesn't falsely trigger
/// the unsaved-changes prompt on back navigation.
class DiaryFormState extends Equatable {
  final DiaryFormStatus status;
  final String? id;
  final String title;
  final String content;
  final DateTime date;
  final DateTime? originalCreatedAt;
  final Mood? selectedMood;
  final String? errorMessage;

  final String? originalTitle;
  final String? originalContent;
  final DateTime? originalDate;
  final Mood? originalMood;

  const DiaryFormState({
    this.status = DiaryFormStatus.initial,
    this.id,
    this.title = '',
    this.content = '',
    required this.date,
    this.originalCreatedAt,
    this.selectedMood,
    this.errorMessage,
    this.originalTitle,
    this.originalContent,
    this.originalDate,
    this.originalMood,
  });

  bool get isEditing => id != null;

  /// True only in edit mode, when any field differs from its original
  /// value. Always false in create mode — there's nothing to "discard"
  /// when nothing existed before, so the unsaved-changes prompt is scoped
  /// to editing only, per product decision.
  bool get hasUnsavedChanges {
    if (!isEditing) return false;
    return title != (originalTitle ?? '') ||
        content != (originalContent ?? '') ||
        date != (originalDate ?? date) ||
        selectedMood != originalMood;
  }

  DiaryFormState copyWith({
    DiaryFormStatus? status,
    String? id,
    String? title,
    String? content,
    DateTime? date,
    DateTime? originalCreatedAt,
    Mood? selectedMood,
    String? errorMessage,
    String? originalTitle,
    String? originalContent,
    DateTime? originalDate,
    Mood? originalMood,
  }) {
    return DiaryFormState(
      status: status ?? this.status,
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      date: date ?? this.date,
      originalCreatedAt: originalCreatedAt ?? this.originalCreatedAt,
      selectedMood: selectedMood ?? this.selectedMood,
      errorMessage: errorMessage,
      originalTitle: originalTitle ?? this.originalTitle,
      originalContent: originalContent ?? this.originalContent,
      originalDate: originalDate ?? this.originalDate,
      originalMood: originalMood ?? this.originalMood,
    );
  }

  @override
  List<Object?> get props => [
        status,
        id,
        title,
        content,
        date,
        originalCreatedAt,
        selectedMood,
        errorMessage,
        originalTitle,
        originalContent,
        originalDate,
        originalMood,
      ];
}