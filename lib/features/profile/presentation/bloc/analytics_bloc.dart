// lib/features/profile/presentation/bloc/analytics_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../domain/usecases/analytics_usecases/get_current_streak.dart';
import '../../domain/usecases/analytics_usecases/get_entry_stats.dart';
import '../../domain/usecases/analytics_usecases/get_heatmap_data.dart';
import '../../domain/usecases/analytics_usecases/get_longest_streak.dart';
import '../../domain/usecases/analytics_usecases/get_mood_counts.dart';
import 'analytics_event.dart';
import 'analytics_state.dart';

/// Loads every analytics metric concurrently. All five use cases read
/// from the same underlying `GetAllDiaryEntries` call independently —
/// intentional per-use-case simplicity over one combined query, since
/// diary entry counts are small enough for this not to matter
/// performance-wise on a local SQLite database.
class AnalyticsBloc extends Bloc<AnalyticsEvent, AnalyticsState> {
  final GetMoodCounts getMoodCounts;
  final GetCurrentStreak getCurrentStreak;
  final GetLongestStreak getLongestStreak;
  final GetHeatmapData getHeatmapData;
  final GetEntryStats getEntryStats;

  AnalyticsBloc({
    required this.getMoodCounts,
    required this.getCurrentStreak,
    required this.getLongestStreak,
    required this.getHeatmapData,
    required this.getEntryStats,
  }) : super(const AnalyticsState()) {
    on<LoadAnalytics>(_onLoadAnalytics);
  }

  Future<void> _onLoadAnalytics(
    LoadAnalytics event,
    Emitter<AnalyticsState> emit,
  ) async {
    emit(state.copyWith(status: AnalyticsStatus.loading));

    // Start all five requests before awaiting any of them, so they run
    // concurrently rather than one after another.
    final moodCountsFuture = getMoodCounts();
    final currentStreakFuture = getCurrentStreak();
    final longestStreakFuture = getLongestStreak();
    final heatmapFuture = getHeatmapData();
    final statsFuture = getEntryStats();

    final moodCountsResult = await moodCountsFuture;
    final currentStreakResult = await currentStreakFuture;
    final longestStreakResult = await longestStreakFuture;
    final heatmapResult = await heatmapFuture;
    final statsResult = await statsFuture;

    // If any metric failed to load, show the first failure encountered
    // rather than a partially-populated dashboard.
    Failure? firstFailure;
    moodCountsResult.match((f) => firstFailure ??= f, (_) => null);
    currentStreakResult.match((f) => firstFailure ??= f, (_) => null);
    longestStreakResult.match((f) => firstFailure ??= f, (_) => null);
    heatmapResult.match((f) => firstFailure ??= f, (_) => null);
    statsResult.match((f) => firstFailure ??= f, (_) => null);

    if (firstFailure != null) {
      emit(
        state.copyWith(
          status: AnalyticsStatus.failure,
          errorMessage: firstFailure!.message,
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        status: AnalyticsStatus.loaded,
        moodCounts: moodCountsResult.match((_) => {}, (v) => v),
        currentStreak: currentStreakResult.match((_) => 0, (v) => v),
        longestStreak: longestStreakResult.match((_) => 0, (v) => v),
        heatmapData: heatmapResult.match((_) => [], (v) => v),
        entryStats: statsResult.match(
          (_) => const EntryStats(totalEntries: 0, totalWords: 0),
          (v) => v,
        ),
      ),
    );
  }
}
