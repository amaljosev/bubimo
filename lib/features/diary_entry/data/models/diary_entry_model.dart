// lib/features/diary_entry/data/models/diary_entry_model.dart

import '../../domain/entities/diary_entry.dart';
import '../../domain/entities/mood.dart';

/// Data model for `diary_entries` table row.
///
/// Matches the actual schema from `core/di/injection.dart`'s `onCreate`:
/// `id TEXT PRIMARY KEY`, `date TEXT`, `created_at TEXT`, `updated_at TEXT`
/// — all timestamps stored as ISO-8601 strings (`DateTime.toIso8601String()`
/// / `DateTime.parse()`), not millisecond ints. Milestone 2 adds `mood TEXT`
/// (nullable), read/written via `Mood.toStorageString()`/`fromStorageString()`.
///
/// Later milestones will extend `toMap`/`fromMap` further for images,
/// stickers, bg_*, font_family, tags, word_count, is_favorite, is_deleted
/// etc. as those columns are introduced — this model is expected to grow,
/// not be replaced.
class DiaryEntryModel extends DiaryEntry {
  const DiaryEntryModel({
    super.id,
    required super.title,
    required super.content,
    required super.date,
    required super.createdAt,
    required super.updatedAt,
    super.mood,
  });

  factory DiaryEntryModel.fromMap(Map<String, dynamic> map) {
    return DiaryEntryModel(
      id: map['id'] as String?,
      title: map['title'] as String,
      content: map['content'] as String,
      date: DateTime.parse(map['date'] as String),
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
      mood: Mood.fromStorageString(map['mood'] as String?),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'content': content,
      'date': date.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'mood': mood?.toStorageString(),
    };
  }

  factory DiaryEntryModel.fromEntity(DiaryEntry entry) {
    return DiaryEntryModel(
      id: entry.id,
      title: entry.title,
      content: entry.content,
      date: entry.date,
      createdAt: entry.createdAt,
      updatedAt: entry.updatedAt,
      mood: entry.mood,
    );
  }
}