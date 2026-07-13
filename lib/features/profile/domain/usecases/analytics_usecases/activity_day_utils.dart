// lib/features/profile/domain/usecases/analytics_usecases/activity_day_utils.dart

import '../../../../../core/utils/date_utils.dart';
import '../../../../diary_entry/domain/entities/diary_entry.dart';

/// Single source of truth for the "activity day" definition shared by
/// streaks and the heatmap: a calendar day on which the user wrote OR
/// edited at least one entry (`createdAt` OR `updatedAt` falling on
/// that day).
///
/// Previously duplicated verbatim inside [GetCurrentStreak],
/// [GetLongestStreak], and [GetHeatmapData] — consolidated here so the
/// activity definition can only ever be changed in one place.
Set<DateTime> buildActivityDaySet(List<DiaryEntry> entries) {
  final days = <DateTime>{};
  for (final entry in entries) {
    days.add(AppDateUtils.dateOnly(entry.createdAt));
    days.add(AppDateUtils.dateOnly(entry.updatedAt));
  }
  return days;
}