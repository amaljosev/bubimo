// lib/features/favorites/presentation/pages/favorites_page.dart

import 'package:bubimo/core/router/app_router.dart';
import 'package:bubimo/core/utils/date_utils.dart';
import 'package:bubimo/core/utils/entry_grouping_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/error_screen.dart';
import '../../../../core/widgets/loading_screen.dart';
import '../../../diary_entry/domain/entities/diary_entry.dart';
import '../../../home/presentation/widgets/diary_list_item.dart';
import '../../../home/presentation/bloc/diary_list/diary_list_bloc.dart';
import '../../../home/presentation/bloc/diary_list/diary_list_event.dart';
import '../../../home/presentation/bloc/diary_list/diary_list_state.dart';

/// Favorites screen with a timeline-style, month-grouped layout.
/// Features:
/// - Minimal, flat app bar (matches the Diary tab's plain title style)
/// - Collapsible month sections with an entry-count pill
/// - Per-day timeline with a connecting line + circular date marker
/// - Entries rendered with the shared [DiaryListItem] (same look/feel
///   as Diary and Timeline), with its own date column hidden since the
///   timeline marker already shows the date once per day
///
/// Data comes from the same shared [DiaryListBloc] Diary and Timeline
/// use — no separate favorites fetch/bloc.
class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _FavoritesView();
  }
}

class _FavoritesView extends StatefulWidget {
  const _FavoritesView();

  @override
  State<_FavoritesView> createState() => _FavoritesViewState();
}

class _FavoritesViewState extends State<_FavoritesView> {
  // Month expansion state, keyed by "yyyy-mm" (see [AppDateUtils.monthKey]).
  // Lives here (not in the stateless section widget) so it survives
  // list rebuilds triggered by BlocBuilder.
  final Map<String, bool> _expandedMonths = {};

  Future<void> _openEntry(BuildContext context, String entryId) async {
    final result = await context.push<bool>(
      AppRoutes.diaryView,
      extra: entryId,
    );
    if (result == true && context.mounted) {
      context.read<DiaryListBloc>().add(const LoadDiaryEntries());
    }
  }

  Future<void> _openCreateEntry(BuildContext context) async {
    final result = await context.push<bool>(AppRoutes.diaryForm);
    if (result == true && context.mounted) {
      context.read<DiaryListBloc>().add(const LoadDiaryEntries());
    }
  }

  Future<void> _onRefresh(BuildContext context) {
    context.read<DiaryListBloc>().add(const LoadDiaryEntries());
    return Future<void>.delayed(const Duration(milliseconds: 400));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => _onRefresh(context),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          slivers: [
            // Static, minimal app bar — no state dependency at all, so
            // it is built once and never rebuilds with the list below.
            const _FavoritesSliverAppBar(),
            BlocBuilder<DiaryListBloc, DiaryListState>(
              buildWhen: (previous, current) =>
                  previous.status != current.status ||
                  previous.entries != current.entries ||
                  previous.errorMessage != current.errorMessage,
              builder: (context, state) {
                switch (state.status) {
                  case DiaryListStatus.initial:
                  case DiaryListStatus.loading:
                    return const SliverFillRemaining(child: LoadingScreen());

                  case DiaryListStatus.failure:
                    return SliverFillRemaining(
                      child: ErrorScreen(
                        message: state.errorMessage ?? 'Something went wrong.',
                        onRetry: () => context.read<DiaryListBloc>().add(
                          const LoadDiaryEntries(),
                        ),
                      ),
                    );

                  case DiaryListStatus.loaded:
                    final favorites = state.entries
                        .where((e) => e.isFavorite)
                        .toList(growable: false)
                      ..sort((a, b) => b.date.compareTo(a.date));

                    if (favorites.isEmpty) {
                      return SliverFillRemaining(
                        child: _ModernEmptyState(
                          onCreatePressed: () => _openCreateEntry(context),
                        ),
                      );
                    }

                    final groupedData =
                        EntryGroupingUtils.groupByMonthAndDay<DiaryEntry>(
                      favorites,
                      (entry) => entry.date,
                    );
                    // Ensure every month bucket has a default expanded
                    // state the first time it's seen, then sort newest
                    // month first.
                    for (final monthKey in groupedData.keys) {
                      _expandedMonths.putIfAbsent(monthKey, () => true);
                    }
                    final monthKeys = groupedData.keys.toList()
                      ..sort((a, b) => b.compareTo(a));

                    return SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                      sliver: SliverList.builder(
                        itemCount: monthKeys.length,
                        itemBuilder: (context, index) {
                          final monthKey = monthKeys[index];
                          final monthData = groupedData[monthKey]!;
                          final isExpanded = _expandedMonths[monthKey] ?? true;

                          return _MonthSection(
                            key: ValueKey(monthKey),
                            monthLabel: AppDateUtils.monthKeyLabel(monthKey),
                            daysData: monthData,
                            isExpanded: isExpanded,
                            onToggle: () {
                              setState(() {
                                _expandedMonths[monthKey] = !isExpanded;
                              });
                            },
                            onEntryTap: (id) => _openEntry(context, id),
                          );
                        },
                      ),
                    );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// Minimal sliver app bar — plain flat title, matching the original
/// (first) design. Kept as its own widget so it never rebuilds along
/// with the list below it.
class _FavoritesSliverAppBar extends StatelessWidget {
  const _FavoritesSliverAppBar();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SliverAppBar(
      backgroundColor: colorScheme.surface,
      foregroundColor: colorScheme.onSurface,
      centerTitle: true,
      // Favorites is no longer a bottom-nav tab — it's reached by
      // pushing this route (e.g. from Timeline), so it needs the
      // default back button to return to the previous screen.
      automaticallyImplyLeading: true,
      elevation: 0,
      title: const Text('Favorites'),
    );
  }
}

/// Month section with collapsible header and day-based entries.
class _MonthSection extends StatelessWidget {
  const _MonthSection({
    super.key,
    required this.monthLabel,
    required this.daysData,
    required this.isExpanded,
    required this.onToggle,
    required this.onEntryTap,
  });

  final String monthLabel;
  final Map<DateTime, List<DiaryEntry>> daysData;
  final bool isExpanded;
  final VoidCallback onToggle;
  final void Function(String) onEntryTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final dayKeys = daysData.keys.toList();
    final totalCount = daysData.values.fold<int>(
      0,
      (sum, list) => sum + list.length,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onToggle,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
              child: Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Text(
                          monthLabel,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            '$totalCount',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ),
        ),
        if (isExpanded)
          ...dayKeys.map((day) {
            final entries = daysData[day]!;
            return _DayTimeline(
              key: ValueKey(day),
              date: day,
              entries: entries,
              onEntryTap: onEntryTap,
            );
          }),
        const SizedBox(height: 8),
      ],
    );
  }
}

/// Timeline-style day group with connecting dots and entries.
class _DayTimeline extends StatelessWidget {
  const _DayTimeline({
    super.key,
    required this.date,
    required this.entries,
    required this.onEntryTap,
  });

  final DateTime date;
  final List<DiaryEntry> entries;
  final void Function(String) onEntryTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isToday = AppDateUtils.isToday(date);

    return IntrinsicHeight(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Timeline left column: date marker + connecting line.
            SizedBox(
              width: 48,
              child: Column(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: isToday
                          ? colorScheme.primary
                          : colorScheme.surfaceContainerLowest,
                      shape: BoxShape.circle,
                      border: isToday
                          ? null
                          : Border.all(
                              color: colorScheme.outlineVariant,
                              width: 1,
                            ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      date.day.toString(),
                      style: TextStyle(
                        fontSize: isToday ? 16 : 14,
                        fontWeight: FontWeight.w700,
                        color: isToday
                            ? colorScheme.onPrimary
                            : colorScheme.onSurface,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            colorScheme.outlineVariant.withValues(alpha: 0.5),
                            colorScheme.outlineVariant.withValues(alpha: 0.2),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            // Entry cards for this day — reuse the shared DiaryListItem
            // so favorites look and behave identically to Diary/Timeline
            // rows (mood, title, preview, favorite icon). The date is
            // already shown once by the timeline marker on the left, so
            // showDateColumn is off here.
            Expanded(
              child: Column(
                children: [
                  for (var i = 0; i < entries.length; i++) ...[
                    if (i > 0) const SizedBox(height: 6),
                    DiaryListItem(
                      key: ValueKey(entries[i].id),
                      entry: entries[i],
                      showDateColumn: false,
                      onTap: () => onEntryTap(entries[i].id),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Enhanced empty state with visual appeal.
class _ModernEmptyState extends StatelessWidget {
  const _ModernEmptyState({required this.onCreatePressed});

  final VoidCallback onCreatePressed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 380),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      colorScheme.primaryContainer,
                      colorScheme.primaryContainer.withValues(alpha: 0.3),
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(
                      Icons.favorite_rounded,
                      size: 48,
                      color: colorScheme.primary.withValues(alpha: 0.4),
                    ),
                    Positioned(
                      bottom: 20,
                      right: 20,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: colorScheme.surface,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.add, size: 16),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              Text(
                'Collect your favorite moments',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                'Tap the star ❤️ on any diary entry\nto save it here for quick access.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),
              // FilledButton.icon(
              //   onPressed: onCreatePressed,
              //   icon: const Icon(Icons.add_rounded),
              //   label: const Text('Create first entry'),
              //   style: FilledButton.styleFrom(
              //     padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
              //     shape: RoundedRectangleBorder(
              //       borderRadius: BorderRadius.circular(14),
              //     ),
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}