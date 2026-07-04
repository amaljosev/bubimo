// lib/features/analytics/presentation/bloc/analytics/analytics_state.dart

import 'package:equatable/equatable.dart';

import '../../../../diary_entry/domain/entities/mood.dart';
import '../../../domain/usecases/get_entry_stats.dart';
import '../../../domain/usecases/get_heatmap_data.dart';

enum AnalyticsStatus { initial, loading, loaded, failure }

class AnalyticsState extends Equatable {
  final AnalyticsStatus status;
  final Map<Mood, int> moodCounts;
  final int currentStreak;
  final int longestStreak;
  final List<HeatmapDay> heatmapData;
  final EntryStats entryStats;
  final String? errorMessage;

  const AnalyticsState({
    this.status = AnalyticsStatus.initial,
    this.moodCounts = const {},
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.heatmapData = const [],
    this.entryStats = const EntryStats(totalEntries: 0, totalWords: 0),
    this.errorMessage,
  });

  AnalyticsState copyWith({
    AnalyticsStatus? status,
    Map<Mood, int>? moodCounts,
    int? currentStreak,
    int? longestStreak,
    List<HeatmapDay>? heatmapData,
    EntryStats? entryStats,
    String? errorMessage,
  }) {
    return AnalyticsState(
      status: status ?? this.status,
      moodCounts: moodCounts ?? this.moodCounts,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      heatmapData: heatmapData ?? this.heatmapData,
      entryStats: entryStats ?? this.entryStats,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        moodCounts,
        currentStreak,
        longestStreak,
        heatmapData,
        entryStats,
        errorMessage,
      ];
}