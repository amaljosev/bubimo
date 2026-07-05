// lib/features/home/presentation/bloc/diary_list/diary_list_state.dart

import 'package:equatable/equatable.dart';

import '../../../../diary_entry/domain/entities/diary_entry.dart';

enum DiaryListStatus { initial, loading, loaded, failure }

class DiaryListState extends Equatable {
  final DiaryListStatus status;
  final List<DiaryEntry> entries;
  final bool showFavoritesOnly;
  final String? errorMessage;

  const DiaryListState({
    this.status = DiaryListStatus.initial,
    this.entries = const [],
    this.showFavoritesOnly = false,
    this.errorMessage,
  });

  /// Entries actually shown on screen — either all loaded entries, or
  /// just the favorited ones, depending on [showFavoritesOnly]. This is
  /// a plain in-memory filter, computed from data already loaded by
  /// [LoadDiaryEntries] — no separate favorites fetch.
  List<DiaryEntry> get visibleEntries {
    if (!showFavoritesOnly) return entries;
    return entries.where((entry) => entry.isFavorite).toList();
  }

  bool get isEmpty =>
      status == DiaryListStatus.loaded && visibleEntries.isEmpty;

  DiaryListState copyWith({
    DiaryListStatus? status,
    List<DiaryEntry>? entries,
    bool? showFavoritesOnly,
    String? errorMessage,
  }) {
    return DiaryListState(
      status: status ?? this.status,
      entries: entries ?? this.entries,
      showFavoritesOnly: showFavoritesOnly ?? this.showFavoritesOnly,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props =>
      [status, entries, showFavoritesOnly, errorMessage];
}