// lib/features/diary_entry/presentation/bloc/diary_form/diary_form_bloc.dart

import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;

import '../../../../../core/utils/id_generator.dart';
import '../../../domain/entities/diary_entry.dart';
import '../../../domain/entities/overlay_image.dart';
import '../../../domain/usecases/create_diary_entry.dart';
import '../../../domain/usecases/get_diary_entry_by_id.dart';
import '../../../domain/usecases/update_diary_entry.dart';
import 'diary_form_event.dart';
import 'diary_form_state.dart';

/// Handles both create and update flows for a single diary entry.
///
/// Edit mode is determined by whether [DiaryFormInitialized] was given
/// an `entryId`. On save, this bloc always calls the single generic
/// [UpdateDiaryEntry] use case (via `existingEntry.copyWith(...)`) when
/// editing, or [CreateDiaryEntry] when creating — no per-field use cases.
///
/// [DiaryFormState.content] holds Quill Delta JSON (a string), not
/// plain text, since the rich editor milestone — [_buildPreview] and
/// [_countWords] parse that Delta JSON into plain text before deriving
/// the `preview`/`wordCount` fields stored on the entity.
///
/// [DiaryFormState.stickers]/[DiaryFormState.images] are denormalized
/// caches kept in sync by the picker widgets as items are inserted into
/// the document — this bloc doesn't re-derive them from the Delta JSON.
///
/// Background fields (`bgImagePath`/`bgGalleryImagePath`/`bgLocalPath`)
/// are set as a group by [DiaryFormBackgroundChanged] — the background
/// picker widget determines which one to populate.
class DiaryFormBloc extends Bloc<DiaryFormEvent, DiaryFormState> {
  final CreateDiaryEntry createDiaryEntry;
  final UpdateDiaryEntry updateDiaryEntry;
  final GetDiaryEntryById getDiaryEntryById;

  /// The full existing entry, kept around in edit mode so save can
  /// `copyWith` only the fields the form actually changes without
  /// discarding fields this milestone's UI doesn't expose yet
  /// (tags, etc.).
  DiaryEntry? _loadedEntry;

  DiaryFormBloc({
    required this.createDiaryEntry,
    required this.updateDiaryEntry,
    required this.getDiaryEntryById,
  }) : super(DiaryFormState.initial()) {
    on<DiaryFormInitialized>(_onInitialized);
    on<DiaryFormTitleChanged>(_onTitleChanged);
    on<DiaryFormContentChanged>(_onContentChanged);
    on<DiaryFormDateChanged>(_onDateChanged);
    on<DiaryFormMoodChanged>(_onMoodChanged);
    on<DiaryFormFontFamilyChanged>(_onFontFamilyChanged);
    on<DiaryFormStickerAdded>(_onStickerAdded);
    on<DiaryFormImageAdded>(_onImageAdded);
    on<DiaryFormOverlayImageAdded>(_onOverlayImageAdded);
    on<DiaryFormOverlayImageTransformed>(_onOverlayImageTransformed);
    on<DiaryFormOverlayImageRemoved>(_onOverlayImageRemoved);
    on<DiaryFormOverlayImageSelected>(_onOverlayImageSelected);
    on<DiaryFormBackgroundChanged>(_onBackgroundChanged);
    on<DiaryFormSubmitted>(_onSubmitted);
  }

  Future<void> _onInitialized(
    DiaryFormInitialized event,
    Emitter<DiaryFormState> emit,
  ) async {
    if (event.entryId == null) {
      emit(state.copyWith(status: DiaryFormStatus.ready));
      return;
    }

    emit(state.copyWith(status: DiaryFormStatus.loadingEntry));

    final result = await getDiaryEntryById(event.entryId!);

    result.match(
      (failure) => emit(
        state.copyWith(
          status: DiaryFormStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (entry) {
        _loadedEntry = entry;
        emit(
          state.copyWith(
            status: DiaryFormStatus.ready,
            entryId: entry.id,
            title: entry.title ?? '',
            content: entry.content ?? '',
            date: entry.date,
            mood: entry.mood,
            fontFamily: entry.fontFamily,
            stickers: entry.stickers,
            images: entry.images,
            overlayImages: entry.overlayImages,
            bgImagePath: entry.bgImagePath,
            bgGalleryImagePath: entry.bgGalleryImagePath,
            bgLocalPath: entry.bgLocalPath,
          ),
        );
      },
    );
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
    emit(state.copyWith(mood: event.mood, clearMood: event.mood == null));
  }

  void _onFontFamilyChanged(
    DiaryFormFontFamilyChanged event,
    Emitter<DiaryFormState> emit,
  ) {
    emit(state.copyWith(fontFamily: event.fontFamily));
  }

  void _onStickerAdded(
    DiaryFormStickerAdded event,
    Emitter<DiaryFormState> emit,
  ) {
    emit(state.copyWith(stickers: [...state.stickers, event.stickerPath]));
  }

  void _onImageAdded(
    DiaryFormImageAdded event,
    Emitter<DiaryFormState> emit,
  ) {
    emit(state.copyWith(images: [...state.images, event.imagePath]));
  }

  void _onOverlayImageAdded(
    DiaryFormOverlayImageAdded event,
    Emitter<DiaryFormState> emit,
  ) {
    final newImage = OverlayImage(
      id: event.id,
      path: event.path,
      x: event.x,
      y: event.y,
    );
    emit(
      state.copyWith(
        overlayImages: [...state.overlayImages, newImage],
        selectedOverlayImageId: event.id,
      ),
    );
  }

  void _onOverlayImageTransformed(
    DiaryFormOverlayImageTransformed event,
    Emitter<DiaryFormState> emit,
  ) {
    final updated = state.overlayImages
        .map(
          (img) => img.id == event.id
              ? img.copyWith(
                  x: event.x,
                  y: event.y,
                  scale: event.scale,
                  rotation: event.rotation,
                )
              : img,
        )
        .toList();
    emit(state.copyWith(overlayImages: updated));
  }

  void _onOverlayImageRemoved(
    DiaryFormOverlayImageRemoved event,
    Emitter<DiaryFormState> emit,
  ) {
    final updated =
        state.overlayImages.where((img) => img.id != event.id).toList();
    final clearSelection = state.selectedOverlayImageId == event.id;
    emit(
      state.copyWith(
        overlayImages: updated,
        clearSelectedOverlayImage: clearSelection,
      ),
    );
  }

  void _onOverlayImageSelected(
    DiaryFormOverlayImageSelected event,
    Emitter<DiaryFormState> emit,
  ) {
    emit(
      state.copyWith(
        selectedOverlayImageId: event.id,
        clearSelectedOverlayImage: event.id == null,
      ),
    );
  }

  void _onBackgroundChanged(
    DiaryFormBackgroundChanged event,
    Emitter<DiaryFormState> emit,
  ) {
    // Clear all three first, then set only the one the caller provided
    // — enforces that exactly one background source is active at a
    // time, per the app's rendering precedence rule.
    emit(
      state.copyWith(
        clearBackgrounds: true,
        bgImagePath: event.bgImagePath,
        bgGalleryImagePath: event.bgGalleryImagePath,
        bgLocalPath: event.bgLocalPath,
      ),
    );
  }

  Future<void> _onSubmitted(
    DiaryFormSubmitted event,
    Emitter<DiaryFormState> emit,
  ) async {
    // Guard against duplicate submissions from rapid repeated taps —
    // once a save is in flight, ignore further submit events until it
    // resolves.
    if (state.isSubmitting) return;

    emit(state.copyWith(status: DiaryFormStatus.submitting));

    final now = DateTime.now();
    final plainText = _extractPlainText(state.content);
    final preview = _buildPreview(plainText);
    final wordCount = _countWords(plainText);

    final entry = state.isEditMode
        ? _loadedEntry!.copyWith(
            title: state.title,
            content: state.content,
            date: state.date,
            mood: state.mood,
            fontFamily: state.fontFamily,
            stickers: state.stickers,
            images: state.images,
            overlayImages: state.overlayImages,
            bgImagePath: state.bgImagePath,
            bgGalleryImagePath: state.bgGalleryImagePath,
            bgLocalPath: state.bgLocalPath,
            preview: preview,
            wordCount: wordCount,
            updatedAt: now,
          )
        : DiaryEntry(
            id: IdGenerator.generate(),
            title: state.title,
            content: state.content,
            date: state.date,
            mood: state.mood,
            fontFamily: state.fontFamily,
            stickers: state.stickers,
            images: state.images,
            overlayImages: state.overlayImages,
            bgImagePath: state.bgImagePath,
            bgGalleryImagePath: state.bgGalleryImagePath,
            bgLocalPath: state.bgLocalPath,
            preview: preview,
            wordCount: wordCount,
            createdAt: now,
            updatedAt: now,
          );

    final result = state.isEditMode
        ? await updateDiaryEntry(entry)
        : await createDiaryEntry(entry);

    result.match(
      (failure) => emit(
        state.copyWith(
          status: DiaryFormStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (_) => emit(state.copyWith(status: DiaryFormStatus.success)),
    );
  }

  /// Parses Quill Delta JSON into plain text. Falls back to returning
  /// the raw string unchanged if it isn't valid Delta JSON — this
  /// covers any legacy plain-text entries saved before the rich editor
  /// existed.
  String _extractPlainText(String content) {
    final trimmed = content.trim();
    if (trimmed.isEmpty) return '';

    try {
      final decoded = jsonDecode(trimmed);
      final document = quill.Document.fromJson(decoded as List);
      return document.toPlainText().trim();
    } catch (_) {
      return trimmed;
    }
  }

  String _buildPreview(String plainText) {
    if (plainText.length <= 120) return plainText;
    return '${plainText.substring(0, 120)}…';
  }

  int _countWords(String plainText) {
    if (plainText.isEmpty) return 0;
    return plainText.split(RegExp(r'\s+')).length;
  }
}