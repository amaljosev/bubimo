// lib/features/diary_entry/domain/entities/diary_entry.dart

import 'package:equatable/equatable.dart';

import 'mood.dart';

/// Core domain entity representing a single diary entry.
///
/// Matches the actual `diary_entries` table: `id` is a TEXT primary key
/// the entry is *about*/written for) distinct from `createdAt`/`updatedAt`
/// (which track actual DB record lifecycle timestamps).
///
/// Milestone 2 adds `mood` (nullable — Milestone 1 entries have none).
/// Fields for images, stickers, background, font, tags, word_count,
/// is_favorite, is_deleted etc. will be added in later milestones as the
/// schema evolves.
class DiaryEntry extends Equatable {
  final String? id;
  final String title;
  final String content;
  final DateTime date;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Mood? mood;

  const DiaryEntry({
    this.id,
    required this.title,
    required this.content,
    required this.date,
    required this.createdAt,
    required this.updatedAt,
    this.mood,
  });

  DiaryEntry copyWith({
    String? id,
    String? title,
    String? content,
    DateTime? date,
    DateTime? createdAt,
    DateTime? updatedAt,
    Mood? mood,
  }) {
    return DiaryEntry(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      mood: mood ?? this.mood,
    );
  }

  @override
  List<Object?> get props =>
      [id, title, content, date, createdAt, updatedAt, mood];
}