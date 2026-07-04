// lib/features/analytics/domain/usecases/get_longest_streak.dart

import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../diary_entry/domain/entities/diary_entry.dart';
import '../../../diary_entry/domain/usecases/get_all_diary_entries.dart';

/// Computes the longest streak ever achieved: the longest run of
/// consecutive calendar days with at least one entry created OR
/// updated, anywhere in the user's history (not just ending today).
///
/// Usage: `await getLongestStreak()`.
class GetLongestStreak {
  final GetAllDiaryEntries getAllDiaryEntries;

  const GetLongestStreak(this.getAllDiaryEntries);

  Future<Either<Failure, int>> call() async {
    final result = await getAllDiaryEntries();

    return result.map((entries) {
      final activityDays = _buildActivityDaySet(entries);
      if (activityDays.isEmpty) return 0;

      final sortedDays = activityDays.toList()..sort();

      var longest = 1;
      var current = 1;

      for (var i = 1; i < sortedDays.length; i++) {
        final previous = sortedDays[i - 1];
        final day = sortedDays[i];

        if (AppDateUtils.isDayBefore(previous, day)) {
          current++;
          if (current > longest) longest = current;
        } else {
          current = 1;
        }
      }

      return longest;
    });
  }

  /// Builds the set of distinct calendar days on which the user wrote
  /// or edited at least one entry.
  Set<DateTime> _buildActivityDaySet(List<DiaryEntry> entries) {
    final days = <DateTime>{};
    for (final entry in entries) {
      days.add(AppDateUtils.dateOnly(entry.createdAt));
      days.add(AppDateUtils.dateOnly(entry.updatedAt));
    }
    return days;
  }
}