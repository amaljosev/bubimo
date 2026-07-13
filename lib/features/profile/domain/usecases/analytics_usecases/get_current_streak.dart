// lib/features/profile/domain/usecases/analytics_usecases/get_current_streak.dart

import 'package:fpdart/fpdart.dart';

import '../../../../../core/error/failures.dart';
import '../../../../../core/utils/date_utils.dart';
import '../../../../diary_entry/domain/usecases/get_all_diary_entries.dart';
import 'activity_day_utils.dart';

/// Pure calculation, split out so [GetAnalyticsSnapshot] can reuse it
/// against an activity-day set it already built, without forcing a
/// second `getAllDiaryEntries()` fetch.
///
/// Computes the current streak: the number of consecutive calendar days
/// (ending today) with at least one entry created OR updated.
///
/// Per the locked streak definition, editing an old entry counts toward
/// TODAY's streak — so "activity days" are built from both `createdAt`
/// and `updatedAt` timestamps, not just entry creation.
int calculateCurrentStreak(Set<DateTime> activityDays) {
  if (activityDays.isEmpty) return 0;

  var streak = 0;
  var cursor = AppDateUtils.dateOnly(DateTime.now());

  // Today must have activity for a streak to be "alive"; otherwise
  // it's broken (0), even if yesterday had activity.
  if (!activityDays.contains(cursor)) return 0;

  while (activityDays.contains(cursor)) {
    streak++;
    cursor = cursor.subtract(const Duration(days: 1));
  }

  return streak;
}

/// Usage: `await getCurrentStreak()`.
///
/// Kept as a standalone use case (in addition to
/// [GetAnalyticsSnapshot]) for call sites or tests that want just this
/// one metric without depending on the combined snapshot.
class GetCurrentStreak {
  final GetAllDiaryEntries getAllDiaryEntries;

  const GetCurrentStreak(this.getAllDiaryEntries);

  Future<Either<Failure, int>> call() async {
    final result = await getAllDiaryEntries();
    return result.map(
      (entries) => calculateCurrentStreak(buildActivityDaySet(entries)),
    );
  }
}