// lib/features/analytics/presentation/pages/analytics_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/widgets/error_screen.dart';
import '../../../../core/widgets/loading_screen.dart';
import '../bloc/analytics/analytics_bloc.dart';
import '../bloc/analytics/analytics_event.dart';
import '../bloc/analytics/analytics_state.dart';
import '../widgets/heatmap_widget.dart';
import '../widgets/mood_count_chart.dart';
import '../widgets/stats_summary_card.dart';
import '../widgets/streak_display.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<AnalyticsBloc>()..add(const LoadAnalytics()),
      child: const _AnalyticsScreenView(),
    );
  }
}

class _AnalyticsScreenView extends StatelessWidget {
  const _AnalyticsScreenView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Analytics')),
      body: BlocBuilder<AnalyticsBloc, AnalyticsState>(
        builder: (context, state) {
          switch (state.status) {
            case AnalyticsStatus.initial:
            case AnalyticsStatus.loading:
              return const LoadingScreen();

            case AnalyticsStatus.failure:
              return ErrorScreen(
                message: state.errorMessage ?? 'Something went wrong.',
                onRetry: () =>
                    context.read<AnalyticsBloc>().add(const LoadAnalytics()),
              );

            case AnalyticsStatus.loaded:
              return RefreshIndicator(
                onRefresh: () async => context
                    .read<AnalyticsBloc>()
                    .add(const LoadAnalytics()),
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    StreakDisplay(
                      currentStreak: state.currentStreak,
                      longestStreak: state.longestStreak,
                    ),
                    const SizedBox(height: 12),
                    StatsSummaryCard(stats: state.entryStats),
                    const SizedBox(height: 12),
                    HeatmapWidget(heatmapData: state.heatmapData),
                    const SizedBox(height: 12),
                    MoodCountChart(moodCounts: state.moodCounts),
                  ],
                ),
              );
          }
        },
      ),
    );
  }
}