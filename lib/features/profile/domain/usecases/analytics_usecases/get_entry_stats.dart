// lib/features/profile/domain/usecases/analytics_usecases/get_entry_stats.dart

import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../../core/error/failures.dart';
import '../../../../diary_entry/domain/entities/diary_entry.dart';
import '../../../../diary_entry/domain/usecases/get_all_diary_entries.dart';

/// Simple aggregate stats derived from all diary entries.
class EntryStats extends Equatable {
  final int totalEntries;
  final int totalWords;

  const EntryStats({required this.totalEntries, required this.totalWords});

  @override
  List<Object?> get props => [totalEntries, totalWords];
}

/// Pure calculation, split out so [GetAnalyticsSnapshot] can reuse it
/// against entries it already fetched, without forcing a second
/// `getAllDiaryEntries()` call.
///
/// `wordCount` is precomputed and stored per-entry on save (see
/// diary_entry's rich editor milestone), so this is just a fast
/// summation — no re-parsing of content.
EntryStats calculateEntryStats(List<DiaryEntry> entries) {
  final totalWords = entries.fold<int>(
    0,
    (sum, entry) => sum + entry.wordCount,
  );
  return EntryStats(totalEntries: entries.length, totalWords: totalWords);
}

/// Usage: `await getEntryStats()`.
///
/// Kept as a standalone use case (in addition to
/// [GetAnalyticsSnapshot]) for call sites or tests that want just this
/// one metric without depending on the combined snapshot.
class GetEntryStats {
  final GetAllDiaryEntries getAllDiaryEntries;

  const GetEntryStats(this.getAllDiaryEntries);

  Future<Either<Failure, EntryStats>> call() async {
    final result = await getAllDiaryEntries();
    return result.map(calculateEntryStats);
  }
}