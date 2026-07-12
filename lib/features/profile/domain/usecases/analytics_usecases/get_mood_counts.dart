// lib/features/profile/domain/usecases/analytics_usecases/get_mood_counts.dart

import 'package:fpdart/fpdart.dart';

import '../../../../../core/error/failures.dart';
import '../../../../diary_entry/domain/entities/mood.dart';
import '../../../../diary_entry/domain/usecases/get_all_diary_entries.dart';

/// Computes how many entries have each [Mood], derived live from all
/// diary entries — nothing is stored separately. Entries with no mood
/// set are excluded from the counts.
///
/// Usage: `await getMoodCounts()`.
class GetMoodCounts {
  final GetAllDiaryEntries getAllDiaryEntries;

  const GetMoodCounts(this.getAllDiaryEntries);

  Future<Either<Failure, Map<Mood, int>>> call() async {
    final result = await getAllDiaryEntries();

    return result.map((entries) {
      final counts = <Mood, int>{for (final mood in Mood.values) mood: 0};
      for (final entry in entries) {
        final mood = entry.mood;
        if (mood != null) {
          counts[mood] = (counts[mood] ?? 0) + 1;
        }
      }
      return counts;
    });
  }
}