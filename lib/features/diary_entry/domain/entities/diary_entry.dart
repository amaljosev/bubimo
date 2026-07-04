// lib/features/diary_entry/domain/entities/diary_entry.dart

import 'package:equatable/equatable.dart';

import 'mood.dart';

/// Core domain entity representing a single diary entry.
///
/// This entity covers every field from the app's final database schema,
/// including fields not yet used by any milestone (e.g. [stickers],
/// [images], [tags]). Fields unused by a not-yet-built feature stay
/// nullable/defaulted so this entity never needs another field added
/// later — future milestones only add behavior (use cases, bloc, UI)
/// that reads/writes fields that already exist here.
class DiaryEntry extends Equatable {
  final String id;
  final String? title;
  final DateTime date;
  final String? content;
  final String? preview;
  final Mood? mood;
  final String? imagePath;

  // Background — precedence when rendering: gallery > preset-local >
  // preset-remote (Supabase, cached to bgLocalPath after download) > color.
  final String? bgColor;
  final String? bgImagePath;
  final String? bgGalleryImagePath;
  final String? bgLocalPath;

  final List<String> stickers;
  final List<String> images;
  final List<String> tags;

  final int wordCount;
  final String? fontFamily;

  final bool isFavorite;
  final bool isDeleted;
  final DateTime? deletedAt;

  final DateTime createdAt;
  final DateTime updatedAt;

  const DiaryEntry({
    required this.id,
    this.title,
    required this.date,
    this.content,
    this.preview,
    this.mood,
    this.imagePath,
    this.bgColor,
    this.bgImagePath,
    this.bgGalleryImagePath,
    this.bgLocalPath,
    this.stickers = const [],
    this.images = const [],
    this.tags = const [],
    this.wordCount = 0,
    this.fontFamily,
    this.isFavorite = false,
    this.isDeleted = false,
    this.deletedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Returns a copy of this entry with the given fields replaced.
  ///
  /// This is the mechanism every feature milestone uses to "add" its own
  /// update behavior without new use cases — e.g. favorites calls
  /// `entry.copyWith(isFavorite: true)`, mood picker calls
  /// `entry.copyWith(mood: selectedMood)`, then both pass the result to
  /// the same generic `UpdateDiaryEntry` use case.
  ///
  /// Nullable fields that should be explicitly clearable (set back to
  /// null) use a sentinel-free approach here for simplicity — pass the
  /// current value explicitly if you don't want to change a field.
  DiaryEntry copyWith({
    String? id,
    String? title,
    DateTime? date,
    String? content,
    String? preview,
    Mood? mood,
    String? imagePath,
    String? bgColor,
    String? bgImagePath,
    String? bgGalleryImagePath,
    String? bgLocalPath,
    List<String>? stickers,
    List<String>? images,
    List<String>? tags,
    int? wordCount,
    String? fontFamily,
    bool? isFavorite,
    bool? isDeleted,
    DateTime? deletedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DiaryEntry(
      id: id ?? this.id,
      title: title ?? this.title,
      date: date ?? this.date,
      content: content ?? this.content,
      preview: preview ?? this.preview,
      mood: mood ?? this.mood,
      imagePath: imagePath ?? this.imagePath,
      bgColor: bgColor ?? this.bgColor,
      bgImagePath: bgImagePath ?? this.bgImagePath,
      bgGalleryImagePath: bgGalleryImagePath ?? this.bgGalleryImagePath,
      bgLocalPath: bgLocalPath ?? this.bgLocalPath,
      stickers: stickers ?? this.stickers,
      images: images ?? this.images,
      tags: tags ?? this.tags,
      wordCount: wordCount ?? this.wordCount,
      fontFamily: fontFamily ?? this.fontFamily,
      isFavorite: isFavorite ?? this.isFavorite,
      isDeleted: isDeleted ?? this.isDeleted,
      deletedAt: deletedAt ?? this.deletedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        date,
        content,
        preview,
        mood,
        imagePath,
        bgColor,
        bgImagePath,
        bgGalleryImagePath,
        bgLocalPath,
        stickers,
        images,
        tags,
        wordCount,
        fontFamily,
        isFavorite,
        isDeleted,
        deletedAt,
        createdAt,
        updatedAt,
      ];
}