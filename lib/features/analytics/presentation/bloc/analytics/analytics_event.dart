// lib/features/analytics/presentation/bloc/analytics/analytics_event.dart

import 'package:equatable/equatable.dart';

sealed class AnalyticsEvent extends Equatable {
  const AnalyticsEvent();

  @override
  List<Object?> get props => [];
}

/// Loads all analytics data (mood counts, streaks, heatmap, stats) in
/// one pass. Fired on screen init.
final class LoadAnalytics extends AnalyticsEvent {
  const LoadAnalytics();
}