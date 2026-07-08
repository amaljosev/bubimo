// lib/features/home/presentation/pages/home_page.dart

import 'dart:io';

import 'package:bubimo/core/router/app_router.dart';
import 'package:bubimo/core/theme/background_image_theme_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';


import '../../../../core/widgets/error_screen.dart';
import '../../../../core/widgets/loading_screen.dart';
import '../bloc/diary_list/diary_list_bloc.dart';
import '../bloc/diary_list/diary_list_event.dart';
import '../bloc/diary_list/diary_list_state.dart';
import '../widgets/diary_list_item.dart';
import '../../../shared/presentation/widgets/empty_state_widget.dart';

/// The Diary tab's content.
///
/// Unlike the other tabs, this screen provides its OWN AppBar (a
/// collapsing [SliverAppBar]) rather than consuming [MainShell]'s shared
/// one — the active theme's header image needs to sit behind the app
/// bar and collapse with scroll, which only works if the app bar is
/// part of the same [CustomScrollView] as the list. [MainShell] must
/// skip rendering its shared AppBar specifically for this tab; see the
/// note in [MainShell] where tabs are built.
///
/// Its [DiaryListBloc] is provided by [MainShell] (created once, kept
/// alive across tab switches) — this widget only consumes it via
/// [BlocBuilder]/[context.read], it does not create it.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _HomeView();
  }
}

class _HomeView extends StatefulWidget {
  const _HomeView();

  @override
  State<_HomeView> createState() => _HomeViewState();
}

/// One calendar day's worth of entries, plus the day itself — used to
/// render a single date tile per day instead of repeating it per entry.
class _DayGroup {
  const _DayGroup({required this.date, required this.entries});

  final DateTime date;
  final List<dynamic> entries;
}

class _HomeViewState extends State<_HomeView> {
  // Guards against rapid repeated taps on the FAB opening multiple
  // stacked Create screens.
  bool _isNavigatingToCreate = false;

  static const double _headerExpandedHeight = 200;
  static const double _dateTileWidth = 56;

  static const _monthAbbreviations = [
    'JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN',
    'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC',
  ];

  Future<void> _openCreateEntry(BuildContext context) async {
    if (_isNavigatingToCreate) return;
    _isNavigatingToCreate = true;

    final result = await context.push<bool>(AppRoutes.diaryForm);

    _isNavigatingToCreate = false;

    if (result == true && context.mounted) {
      context.read<DiaryListBloc>().add(const LoadDiaryEntries());
    }
  }

  Future<void> _openEntry(BuildContext context, String entryId) async {
    final result = await context.push<bool>(
      AppRoutes.diaryView,
      extra: entryId,
    );

    if (result == true && context.mounted) {
      context.read<DiaryListBloc>().add(const LoadDiaryEntries());
    }
  }

  /// Header images follow the same asset-vs-file convention used on the
  /// Theme Screen's cards: default-preset images are bundled assets
  /// (`assets/theme/theme_N.jpg`), custom-theme images are `image_picker`
  /// file paths. Both live in the same string field, distinguished here
  /// by the `assets/` prefix.
  Widget _headerImage(String path) {
    if (path.startsWith('assets/')) {
      return Image.asset(path, fit: BoxFit.cover);
    }
    return Image.file(File(path), fit: BoxFit.cover);
  }

  /// Groups entries into consecutive same-day buckets, preserving the
  /// original ordering of [entries]. Assumes entries arrive already
  /// sorted by date (as [DiaryListBloc] provides them) — this does NOT
  /// re-sort, it only collapses adjacent same-day entries into one
  /// group, so a non-chronological list would produce duplicate date
  /// tiles for the same day if it appears in two non-adjacent runs.
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

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  /// The left-side "date tile": month abbreviation + big day number,
  /// matching the reference screenshot. Shown once per day group.
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
    final headerImagePath = Theme.of(
      context,
    ).extension<BackgroundImageTheme>()?.imagePath;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: headerImagePath != null
                ? _headerExpandedHeight
                : kToolbarHeight,
            backgroundColor: colorScheme.surface,
            foregroundColor: colorScheme.onSurface,
            centerTitle: true,
            // No back button on a tab root, and no theme-agnostic
            // elevation shadow riding on top of the header image.
            automaticallyImplyLeading: false,
            elevation: 0,
            flexibleSpace: headerImagePath == null
                ? null
                : FlexibleSpaceBar(
                    // Collapsed title is handled by the pinned bar's own
                    // `title` below; this stays purely visual so the
                    // title doesn't double-render during the collapse
                    // animation.
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        _headerImage(headerImagePath),
                        // Gradient so the pinned title text stays
                        // readable over busy header images at any
                        // scroll position, regardless of the theme's
                        // own foreground color.
                        DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withValues(alpha: 0.35),
                                Colors.transparent,
                                Colors.black.withValues(alpha: 0.45),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
            title: Text(
              'Diary',
              style: TextStyle(
                color: headerImagePath != null
                    ? Colors.white
                    : colorScheme.onSurface,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                const SizedBox(height: 8),
                BlocBuilder<DiaryListBloc, DiaryListState>(
                  builder: (context, state) {
                    return Center(
                      child: SegmentedButton<bool>(
                        segments: const [
                          ButtonSegment(value: false, label: Text('All')),
                          ButtonSegment(
                            value: true,
                            label: Text('Favorites'),
                            icon: Icon(Icons.favorite, size: 16),
                          ),
                        ],
                        selected: {state.showFavoritesOnly},
                        onSelectionChanged: (selection) => context
                            .read<DiaryListBloc>()
                            .add(FavoritesFilterChanged(selection.first)),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
          BlocBuilder<DiaryListBloc, DiaryListState>(
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
                  if (state.isEmpty) {
                    return SliverFillRemaining(
                      child: EmptyStateWidget(
                        isFavoritesFilter: state.showFavoritesOnly,
                        onCreatePressed: () => _openCreateEntry(context),
                      ),
                    );
                  }

                  final dayGroups = _groupByDay(state.visibleEntries);

                  return SliverPadding(
                    padding: const EdgeInsets.all(16),
                    sliver: SliverList.separated(
                      itemCount: dayGroups.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 16),
                      itemBuilder: (context, groupIndex) {
                        final group = dayGroups[groupIndex];

                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _dateTile(context, group.date),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                children: [
                                  for (
                                    var i = 0;
                                    i < group.entries.length;
                                    i++
                                  ) ...[
                                    if (i > 0) const SizedBox(height: 8),
                                    DiaryListItem(
                                      entry: group.entries[i],
                                      showDateColumn: false,
                                      onTap: () => _openEntry(
                                        context,
                                        group.entries[i].id,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  );
              }
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'diary_new_entry_fab',
        onPressed: () => _openCreateEntry(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}