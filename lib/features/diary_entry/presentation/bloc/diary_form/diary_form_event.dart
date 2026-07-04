// lib/features/diary_entry/presentation/bloc/diary_form/diary_form_event.dart

import 'package:equatable/equatable.dart';

import '../../../domain/entities/mood.dart';

sealed class DiaryFormEvent extends Equatable {
  const DiaryFormEvent();

  @override
  List<Object?> get props => [];
}

/// Fired once when the form screen opens. Pass [entryId] to load an
/// existing entry for editing; leave it null to start a blank create form.
final class DiaryFormInitialized extends DiaryFormEvent {
  final String? entryId;

  const DiaryFormInitialized({this.entryId});

  @override
  List<Object?> get props => [entryId];
}

final class DiaryFormTitleChanged extends DiaryFormEvent {
  final String title;

  const DiaryFormTitleChanged(this.title);

  @override
  List<Object?> get props => [title];
}

/// Fired whenever the Quill document changes — content holds Delta JSON,
/// not plain text.
final class DiaryFormContentChanged extends DiaryFormEvent {
  final String content;

  const DiaryFormContentChanged(this.content);

  @override
  List<Object?> get props => [content];
}

final class DiaryFormDateChanged extends DiaryFormEvent {
  final DateTime date;

  const DiaryFormDateChanged(this.date);

  @override
  List<Object?> get props => [date];
}

final class DiaryFormMoodChanged extends DiaryFormEvent {
  final Mood? mood;

  const DiaryFormMoodChanged(this.mood);

  @override
  List<Object?> get props => [mood];
}

/// Fired when the font picker selects a family. Applies to the whole
/// entry (stored on the entity's `fontFamily` field), not per-selection
/// rich-text formatting.
final class DiaryFormFontFamilyChanged extends DiaryFormEvent {
  final String? fontFamily;

  const DiaryFormFontFamilyChanged(this.fontFamily);

  @override
  List<Object?> get props => [fontFamily];
}

/// Fired after a sticker is inserted into the document, so the
/// denormalized `stickers` list stays in sync with what's actually in
/// the content.
final class DiaryFormStickerAdded extends DiaryFormEvent {
  final String stickerPath;

  const DiaryFormStickerAdded(this.stickerPath);

  @override
  List<Object?> get props => [stickerPath];
}

/// Fired after a gallery photo is inserted into the document, so the
/// denormalized `images` list stays in sync with what's actually in the
/// content.
final class DiaryFormImageAdded extends DiaryFormEvent {
  final String imagePath;

  const DiaryFormImageAdded(this.imagePath);

  @override
  List<Object?> get props => [imagePath];
}

/// Fired when a background is chosen. Exactly one of [bgImagePath]
/// (bundled preset), [bgGalleryImagePath] (user's own photo), or
/// [bgLocalPath] (cached Supabase preset) is set per the app's
/// precedence rule (gallery > preset-local > preset-remote > color) —
/// the caller (diary_form_page) is responsible for nulling out the
/// other two based on `SelectedBackground.type` before dispatching.
final class DiaryFormBackgroundChanged extends DiaryFormEvent {
  final String? bgImagePath;
  final String? bgGalleryImagePath;
  final String? bgLocalPath;

  const DiaryFormBackgroundChanged({
    this.bgImagePath,
    this.bgGalleryImagePath,
    this.bgLocalPath,
  });

  @override
  List<Object?> get props => [bgImagePath, bgGalleryImagePath, bgLocalPath];
}

/// Fired when the user taps Save. The bloc itself guards against
/// duplicate submissions (see [DiaryFormBloc]) so rapid repeated taps of
/// this event are safe.
final class DiaryFormSubmitted extends DiaryFormEvent {
  const DiaryFormSubmitted();
}