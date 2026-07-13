// lib/features/profile/domain/usecases/analytics_usecases/get_word_count_trend.dart

import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../../core/error/failures.dart';
import '../../../../../core/utils/date_utils.dart';
import '../../../../diary_entry/domain/entities/diary_entry.dart';
import '../../../../diary_entry/domain/usecases/get_all_diary_entries.dart';

/// One point on the writing-consistency trend: total words written (or
/// edited) on a given calendar day.
class WordCountDay extends Equatable {
  final DateTime date;
  final int wordCount;

  const WordCountDay({required this.date, required this.wordCount});

  @override
  List<Object?> get props => [date, wordCount];
}

/// Number of days shown on the writing-consistency chart. 30 days is a
/// deliberately shorter window than the 365-day heatmap: this chart is
/// about recent effort/momentum ("am I writing more or less lately"),
/// not long-term presence, so a month keeps it readable as a line chart
/// instead of an unreadably dense 365-point series.
const int kWordCountTrendDays = 30;

/// Pure calculation, split out so [GetAnalyticsSnapshot] can reuse it
/// against entries it already fetched, without forcing a second
/// `getAllDiaryEntries()` call.
///
/// Buckets [entries] by calendar day (attributed to `updatedAt`, so
/// editing an old entry today adds today's edited word count to
/// today's bar — consistent with the same "activity is measured by
/// createdAt/updatedAt" rule the heatmap and streaks use) and sums
/// `wordCount` per day for the last [kWordCountTrendDays] days.
///
/// Deliberately attributes the entry's FULL current `wordCount` to the
/// day it was last touched, not just the words added in that edit
/// (this app doesn't store word-count deltas per edit) — so this chart
/// reads as "how much total writing was active on this day," not
/// "how many new words were typed this day." That's a reasonable and
/// clearly-scoped proxy for writing consistency without needing new
/// schema/tracking.
List<WordCountDay> calculateWordCountTrend(List<DiaryEntry> entries) {
  final wordsByDay = <DateTime, int>{};
  for (final entry in entries) {
    final day = AppDateUtils.dateOnly(entry.updatedAt);
    wordsByDay[day] = (wordsByDay[day] ?? 0) + entry.wordCount;
  }

  final lastNDays = AppDateUtils.lastNDays(kWordCountTrendDays);
  return lastNDays
      .map((day) => WordCountDay(date: day, wordCount: wordsByDay[day] ?? 0))
      .toList();
}

/// Usage: `await getWordCountTrend()`.
///
/// Kept as a standalone use case (in addition to
/// [GetAnalyticsSnapshot]) for call sites or tests that want just this
/// one metric without depending on the combined snapshot.
class GetWordCountTrend {
  final GetAllDiaryEntries getAllDiaryEntries;

  const GetWordCountTrend(this.getAllDiaryEntries);

  Future<Either<Failure, List<WordCountDay>>> call() async {
    final result = await getAllDiaryEntries();
    return result.map(calculateWordCountTrend);
  }
}