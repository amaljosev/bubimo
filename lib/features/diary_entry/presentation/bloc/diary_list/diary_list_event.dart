// lib/features/home/presentation/bloc/diary_list/diary_list_event.dart

import 'package:equatable/equatable.dart';

sealed class DiaryListEvent extends Equatable {
  const DiaryListEvent();

  @override
  List<Object?> get props => [];
}

/// Loads (or reloads) all diary entries. Fired once on Home's init, and
/// again any time a save/edit/delete/favorite-toggle on another screen
/// reports back that data changed.
final class LoadDiaryEntries extends DiaryListEvent {
  const LoadDiaryEntries();
}

/// Switches Home between showing all entries and favorites only. This
/// is a pure in-memory filter over entries already loaded by
/// [LoadDiaryEntries] — no new fetch, no new use case.
final class FavoritesFilterChanged extends DiaryListEvent {
  final bool showFavoritesOnly;

  const FavoritesFilterChanged(this.showFavoritesOnly);

  @override
  List<Object?> get props => [showFavoritesOnly];
}