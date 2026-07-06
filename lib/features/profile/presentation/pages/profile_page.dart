// lib/features/profile/presentation/pages/profile_analytics_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/widgets/error_screen.dart';
import '../../../../core/widgets/loading_screen.dart';
import '../../../analytics/presentation/bloc/analytics/analytics_bloc.dart';
import '../../../analytics/presentation/bloc/analytics/analytics_event.dart';
import '../../../analytics/presentation/bloc/analytics/analytics_state.dart';
import '../../../analytics/presentation/widgets/heatmap_widget.dart';
import '../../../analytics/presentation/widgets/mood_count_chart.dart';
import '../../../analytics/presentation/widgets/stats_summary_card.dart';
import '../../../analytics/presentation/widgets/streak_display.dart';
import '../cubit/profile_cubit.dart';
import '../cubit/profile_state.dart';
import '../widgets/edit_profile_sheet.dart';
import '../widgets/profile_header.dart';

/// Combined Profile & Analytics screen.
///
/// Replaces the old standalone AnalyticsScreen and the old standalone
/// ProfilePage — this is now the Profile tab's body, rendered inside
/// MainShell's IndexedStack (kept alive across tab switches, same as
/// every other tab).
///
/// Both [ProfileCubit] and [AnalyticsBloc] are provided by whoever
/// mounts this screen (see MainShell, which creates both once in
/// initState and keeps them alive for the shell's lifetime) — this
/// widget only consumes them. It's a [StatelessWidget] rather than
/// stateful specifically so it can't accidentally re-trigger a load of
/// its own: the initial `loadProfile()` / `LoadAnalytics()` dispatch
/// happens exactly once, where the blocs are CREATED, matching the
/// pattern every other tab uses (LoadDiaryEntries/LoadThemes in
/// MainShell.initState) rather than inside the tab's own widget.
class ProfileAnalyticsScreen extends StatelessWidget {
  const ProfileAnalyticsScreen({super.key});

  Future<void> _onEditProfile(
    BuildContext context,
    ProfileState profileState,
  ) async {
    final current = profileState.profile;
    if (current == null) return;

    final updated = await EditProfileSheet.show(context, current);
    if (updated != null && context.mounted) {
      context.read<ProfileCubit>().saveProfile(updated);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        title: const Text('Profile & Analytics'),
      ),
      body: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, profileState) {
          return BlocBuilder<AnalyticsBloc, AnalyticsState>(
            builder: (context, analyticsState) {
              return _buildBody(context, profileState, analyticsState);
            },
          );
        },
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    ProfileState profileState,
    AnalyticsState analyticsState,
  ) {
    // The profile card and the analytics cards load somewhat
    // independently (two separate blocs); only block the whole screen
    // on a spinner while BOTH are still on their very first load.
    final profileStillLoading = profileState.status == ProfileStatus.initial ||
        profileState.status == ProfileStatus.loading;
    final analyticsStillLoading =
        analyticsState.status == AnalyticsStatus.initial ||
            analyticsState.status == AnalyticsStatus.loading;

    if (profileStillLoading && analyticsStillLoading) {
      return const LoadingScreen();
    }

    if (analyticsState.status == AnalyticsStatus.failure) {
      return ErrorScreen(
        message: analyticsState.errorMessage ?? 'Something went wrong.',
        onRetry: () =>
            context.read<AnalyticsBloc>().add(const LoadAnalytics()),
      );
    }

    return RefreshIndicator(
      // Pull-to-refresh is a deliberate, user-initiated reload — unlike
      // the initial load, this is fine to dispatch from here.
      onRefresh: () async {
        context.read<ProfileCubit>().loadProfile();
        context.read<AnalyticsBloc>().add(const LoadAnalytics());
      },
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          if (profileState.profile != null)
            ProfileHeader(
              profile: profileState.profile!,
              onEdit: () => _onEditProfile(context, profileState),
            ),
          if (analyticsState.status == AnalyticsStatus.loaded) ...[
            StreakDisplay(
              currentStreak: analyticsState.currentStreak,
              longestStreak: analyticsState.longestStreak,
            ),
            const SizedBox(height: 12),
            StatsSummaryCard(stats: analyticsState.entryStats),
            const SizedBox(height: 12),
            HeatmapWidget(heatmapData: analyticsState.heatmapData),
            const SizedBox(height: 12),
            MoodCountChart(moodCounts: analyticsState.moodCounts),
          ],
        ],
      ),
    );
  }
}