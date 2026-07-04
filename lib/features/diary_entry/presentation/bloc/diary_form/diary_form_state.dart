// lib/features/diary_entry/presentation/bloc/diary_form/diary_form_state.dart

import 'package:equatable/equatable.dart';

import '../../../domain/entities/mood.dart';

enum DiaryFormStatus {
  /// Blank create form, or existing entry not loaded yet.
  initial,

  /// Loading an existing entry for edit mode.
  loadingEntry,

  /// Entry loaded (or blank create form ready), user can edit fields.
  ready,

  /// Save in progress — UI should disable the Save button to prevent
  /// duplicate submissions.
  submitting,

  /// Save succeeded — presentation layer should pop with a success
  /// result so the calling screen (Home) refreshes.
  success,

  /// Loading or saving failed.
  failure,
}

class DiaryFormState extends Equatable {
  final DiaryFormStatus status;

  /// Null while creating a new entry; set once an existing entry has
  /// been loaded for editing.
  final String? entryId;

  final String title;

  /// Quill Delta JSON, not plain text.
  final String content;

  final DateTime date;
  final Mood? mood;
  final String? fontFamily;

  /// Denormalized cache of sticker/image asset paths inserted into
  /// [content] via the rich editor's pickers. Kept in sync by
  /// [DiaryFormStickerAdded]/[DiaryFormImageAdded] rather than
  /// re-parsed from the Delta JSON on every change.
  final List<String> stickers;
  final List<String> images;

  /// Background fields — precedence when rendering is gallery >
  /// preset-local > preset-remote (cached) > color. Only one is
  /// typically non-null at a time; [copyWith]'s `clearBackgrounds` flag
  /// enforces that when a new selection is made.
  final String? bgImagePath;
  final String? bgGalleryImagePath;
  final String? bgLocalPath;

  final String? errorMessage;

  const DiaryFormState({
    this.status = DiaryFormStatus.initial,
    this.entryId,
    this.title = '',
    this.content = '',
    required this.date,
    this.mood,
    this.fontFamily,
    this.stickers = const [],
    this.images = const [],
    this.bgImagePath,
    this.bgGalleryImagePath,
    this.bgLocalPath,
    this.errorMessage,
  });

  factory DiaryFormState.initial() => DiaryFormState(date: DateTime.now());

  bool get isEditMode => entryId != null;
  bool get isSubmitting => status == DiaryFormStatus.submitting;

  /// When [clearBackgrounds] is true, all three background fields are
  /// set to EXACTLY the values passed in (null if omitted) rather than
  /// merged with the existing state — this is how a new background
  /// selection replaces whichever of the three was previously active,
  /// instead of leaving a stale value in one of the other two fields.
  DiaryFormState copyWith({
    DiaryFormStatus? status,
    String? entryId,
    String? title,
    String? content,
    DateTime? date,
    Mood? mood,
    bool clearMood = false,
    String? fontFamily,
    List<String>? stickers,
    List<String>? images,
    String? bgImagePath,
    String? bgGalleryImagePath,
    String? bgLocalPath,
    bool clearBackgrounds = false,
    String? errorMessage,
  }) {
    return DiaryFormState(
      status: status ?? this.status,
      entryId: entryId ?? this.entryId,
      title: title ?? this.title,
      content: content ?? this.content,
      date: date ?? this.date,
      mood: clearMood ? null : (mood ?? this.mood),
      fontFamily: fontFamily ?? this.fontFamily,
      stickers: stickers ?? this.stickers,
      images: images ?? this.images,
      bgImagePath:
          clearBackgrounds ? bgImagePath : (bgImagePath ?? this.bgImagePath),
      bgGalleryImagePath: clearBackgrounds
          ? bgGalleryImagePath
          : (bgGalleryImagePath ?? this.bgGalleryImagePath),
      bgLocalPath:
          clearBackgrounds ? bgLocalPath : (bgLocalPath ?? this.bgLocalPath),
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        entryId,
        title,
        content,
        date,
        mood,
        fontFamily,
        stickers,
        images,
        bgImagePath,
        bgGalleryImagePath,
        bgLocalPath,
        errorMessage,
      ];
}