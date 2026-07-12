// lib/features/profile/domain/usecases/analytics_usecases/get_heatmap_data.dart

import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../../core/error/failures.dart';
import '../../../../../core/utils/date_utils.dart';
import '../../../../diary_entry/domain/entities/diary_entry.dart';
import '../../../../diary_entry/domain/usecases/get_all_diary_entries.dart';

/// A single cell in the GitHub-style heatmap grid.
class HeatmapDay extends Equatable {
  final DateTime date;
  final bool hasEntry;

  const HeatmapDay({required this.date, required this.hasEntry});

  @override
  List<Object?> get props => [date, hasEntry];
}

/// Builds a 365-day binary grid (oldest first, today last) showing
/// which calendar days had diary WRITING ACTIVITY.
///
/// "Has entry" is based on `createdAt`/`updatedAt`, the same activity
/// definition used by the streak calculations — so editing an old entry
/// lights up today's heatmap cell, consistent with the locked streak
/// rule. It intentionally does NOT use the entry's `date` field (the
/// diary date the user picked), since that's about entry content, not
/// when the user actually wrote/edited.
///
/// Usage: `await getHeatmapData()`.
class GetHeatmapData {
  final GetAllDiaryEntries getAllDiaryEntries;

  const GetHeatmapData(this.getAllDiaryEntries);

  Future<Either<Failure, List<HeatmapDay>>> call() async {
    final result = await getAllDiaryEntries();

    return result.map((entries) {
      final activityDays = _buildActivityDaySet(entries);
      final last365Days = AppDateUtils.lastNDays(365);

      return last365Days
          .map(
            (day) => HeatmapDay(
              date: day,
              hasEntry: activityDays.contains(day),
            ),
          )
          .toList();
    });
  }

  /// Builds the set of distinct calendar days on which the user wrote
  /// or edited at least one entry. Duplicated from
  /// GetCurrentStreak/GetLongestStreak intentionally — each use case
  /// stays self-contained rather than sharing a private helper across
  /// files.
  Set<DateTime> _buildActivityDaySet(List<DiaryEntry> entries) {
    final days = <DateTime>{};
    for (final entry in entries) {
      days.add(AppDateUtils.dateOnly(entry.createdAt));
      days.add(AppDateUtils.dateOnly(entry.updatedAt));
    }
    return days;
  }
}