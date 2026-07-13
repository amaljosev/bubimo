// lib/features/profile/domain/usecases/analytics_usecases/get_mood_counts.dart

import 'package:fpdart/fpdart.dart';

import '../../../../../core/error/failures.dart';
import '../../../../diary_entry/domain/entities/diary_entry.dart';
import '../../../../diary_entry/domain/entities/mood.dart';
import '../../../../diary_entry/domain/usecases/get_all_diary_entries.dart';

/// Pure calculation, split out so [GetAnalyticsSnapshot] can reuse it
/// against entries it already fetched, without forcing a second
/// `getAllDiaryEntries()` call.
///
/// Computes how many entries have each [Mood]. Entries with no mood set
/// are excluded from the counts.
Map<Mood, int> calculateMoodCounts(List<DiaryEntry> entries) {
  final counts = <Mood, int>{for (final mood in Mood.values) mood: 0};
  for (final entry in entries) {
    final mood = entry.mood;
    if (mood != null) {
      counts[mood] = (counts[mood] ?? 0) + 1;
    }
  }
  return counts;
}

/// Usage: `await getMoodCounts()`.
///
/// Kept as a standalone use case (in addition to
/// [GetAnalyticsSnapshot]) for call sites or tests that want just this
/// one metric without depending on the combined snapshot.
class GetMoodCounts {
  final GetAllDiaryEntries getAllDiaryEntries;

  const GetMoodCounts(this.getAllDiaryEntries);

  Future<Either<Failure, Map<Mood, int>>> call() async {
    final result = await getAllDiaryEntries();
    return result.map(calculateMoodCounts);
  }
}