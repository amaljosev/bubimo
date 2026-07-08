// lib/features/favorites/presentation/pages/favorites_page.dart

import 'package:bubimo/core/router/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/error_screen.dart';
import '../../../../core/widgets/loading_screen.dart';
import '../../../home/presentation/bloc/diary_list/diary_list_bloc.dart';
import '../../../home/presentation/bloc/diary_list/diary_list_event.dart';
import '../../../home/presentation/bloc/diary_list/diary_list_state.dart';
import '../../../home/presentation/widgets/diary_list_item.dart';
import '../../../shared/presentation/widgets/empty_state_widget.dart';

/// Dedicated Favorites screen — every entry with `isFavorite == true`,
/// pulled from the same shared [DiaryListBloc] Diary and Timeline use
/// (no separate favorites fetch/bloc). Reachable both as a bottom-nav
/// tab and via the favorite-count pill on [TimelinePage]'s header.
///
/// Entries are grouped by day the same way [HomePage] groups them: one
/// date tile per day, with every favorite from that day listed beneath
/// it inside a single shared card — the date is never repeated per
/// entry.
class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _FavoritesView();
  }
}

/// One calendar day's worth of favorite entries, plus the day itself —
/// mirrors [HomePage]'s `_DayGroup`.
class _DayGroup {
  const _DayGroup({required this.date, required this.entries});

  final DateTime date;
  final List<dynamic> entries;
}

class _FavoritesView extends StatefulWidget {
  const _FavoritesView();

  @override
  State<_FavoritesView> createState() => _FavoritesViewState();
}

class _FavoritesViewState extends State<_FavoritesView> {
  static const _monthAbbreviations = [
    'JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN',
    'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC',
  ];
  static const double _dateTileWidth = 56;

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

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  /// Groups favorite entries into consecutive same-day buckets,
  /// preserving [entries]'s original ordering. Assumes entries arrive
  /// already sorted by date (as [DiaryListBloc] provides them) — this
  /// does NOT re-sort, it only collapses adjacent same-day entries into
  /// one group.
  List<_DayGroup> _groupByDay(List<dynamic> entries) {
    final groups = <_DayGroup>[];

    for (final entry in entries) {
      final entryDate = entry.date as DateTime;
      final dayOnly = DateTime(entryDate.year, entryDate.month, entryDate.day);

      if (groups.isNotEmpty && _isSameDay(groups.last.date, dayOnly)) {
        groups.last.entries.add(entry);
      } else {
        groups.add(_DayGroup(date: dayOnly, entries: [entry]));
      }
    }

    return groups;
  }

  Widget _dateTile(BuildContext context, DateTime date) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      width: _dateTileWidth,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _monthAbbreviations[date.month - 1],
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              letterSpacing: 0.5,
            ),
          ),
          Text(
            date.day.toString().padLeft(2, '0'),
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
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
            // App bar only cares about the favorites *count*, not the
            // full entries list identity, so it gets its own narrow
            // BlocBuilder with buildWhen.
            BlocBuilder<DiaryListBloc, DiaryListState>(
              buildWhen: (previous, current) =>
                  _favoritesCount(previous.entries) !=
                  _favoritesCount(current.entries),
              builder: (context, state) {
                return _FavoritesSliverAppBar(
                  count: _favoritesCount(state.entries),
                );
              },
            ),
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
                        .toList(growable: false);

                    if (favorites.isEmpty) {
                      return SliverFillRemaining(
                        child: EmptyStateWidget(
                          isFavoritesFilter: true,
                          onCreatePressed: () => _openCreateEntry(context),
                        ),
                      );
                    }

                    final dayGroups = _groupByDay(favorites);

                    return SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                      sliver: SliverList.separated(
                        itemCount: dayGroups.length,
                        // Keying by the group's day lets Flutter reuse
                        // existing elements for unaffected days when a
                        // single entry is un-favorited elsewhere in the
                        // list, instead of rebuilding every group.
                        itemBuilder: (context, groupIndex) {
                          final group = dayGroups[groupIndex];
                          return _FavoriteDayGroupTile(
                            key: ValueKey(group.date),
                            date: group.date,
                            entries: group.entries,
                            dateTileBuilder: _dateTile,
                            onEntryTap: (id) => _openEntry(context, id),
                          );
                        },
                        separatorBuilder: (_, _) => const SizedBox(height: 16),
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

  static int _favoritesCount(List<dynamic> entries) =>
      entries.where((e) => e.isFavorite as bool).length;
}

/// Extracted so the sliver app bar is a stable, const-constructible widget
/// that only rebuilds when [count] changes — never on unrelated list state.
class _FavoritesSliverAppBar extends StatelessWidget {
  const _FavoritesSliverAppBar({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SliverAppBar(
            backgroundColor: colorScheme.surface,
            foregroundColor: colorScheme.onSurface,
            centerTitle: true,
            automaticallyImplyLeading: false,
            elevation: 0,
            title: const Text('Favorites'),
          );
  }
}


/// One day's row: the date tile on the left, and every favorite entry
/// from that day stacked inside a single shared background container
/// on the right — the date renders exactly once per group, matching
/// [HomePage]'s layout. [DiaryListItem] is used with
/// `showDateColumn: false` since the date tile here already covers it.
class _FavoriteDayGroupTile extends StatelessWidget {
  const _FavoriteDayGroupTile({
    super.key,
    required this.date,
    required this.entries,
    required this.dateTileBuilder,
    required this.onEntryTap,
  });

  final DateTime date;
  final List<dynamic> entries;
  final Widget Function(BuildContext, DateTime) dateTileBuilder;
  final void Function(String entryId) onEntryTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        dateTileBuilder(context, date),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              children: [
                for (var i = 0; i < entries.length; i++) ...[
                  if (i > 0) const SizedBox(height: 8),
                  DiaryListItem(
                    key: ValueKey(entries[i].id),
                    entry: entries[i],
                    showDateColumn: false,
                    onTap: () => onEntryTap(entries[i].id as String),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}