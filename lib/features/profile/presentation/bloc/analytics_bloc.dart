// lib/features/profile/presentation/bloc/analytics_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/analytics_usecases/get_analytics_snapshot.dart';
import 'analytics_event.dart';
import 'analytics_state.dart';

/// Loads every analytics metric from a single [GetAnalyticsSnapshot]
/// call, which itself does exactly one `getAllDiaryEntries()` fetch and
/// derives mood counts, both streaks, the heatmap, entry stats, and the
/// word-count trend from that one result — see
/// [GetAnalyticsSnapshot]'s doc comment for why this replaced 5
/// independent per-metric use cases.
class AnalyticsBloc extends Bloc<AnalyticsEvent, AnalyticsState> {
  final GetAnalyticsSnapshot getAnalyticsSnapshot;

  AnalyticsBloc({required this.getAnalyticsSnapshot})
      : super(const AnalyticsState()) {
    on<LoadAnalytics>(_onLoadAnalytics);
  }

  Future<void> _onLoadAnalytics(
    LoadAnalytics event,
    Emitter<AnalyticsState> emit,
  ) async {
    emit(state.copyWith(status: AnalyticsStatus.loading));

    final result = await getAnalyticsSnapshot();

    result.match(
      (failure) => emit(
        state.copyWith(
          status: AnalyticsStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (snapshot) => emit(
        state.copyWith(
          status: AnalyticsStatus.loaded,
          moodCounts: snapshot.moodCounts,
          currentStreak: snapshot.currentStreak,
          longestStreak: snapshot.longestStreak,
          heatmapData: snapshot.heatmapData,
          entryStats: snapshot.entryStats,
          wordCountTrend: snapshot.wordCountTrend,
        ),
      ),
    );
  }
}