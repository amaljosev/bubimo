// lib/features/home/presentation/pages/home_page.dart

import 'package:bubimo/core/router/app_router.dart';
import 'package:bubimo/core/theme/background_image_theme_extension.dart';
import 'package:bubimo/core/utils/entry_grouping_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/error_screen.dart';
import '../../../../core/widgets/loading_screen.dart';
import '../../../diary_entry/domain/entities/diary_entry.dart';
import '../../../home/presentation/widgets/diary_list_item.dart';
import '../../../shared/presentation/widgets/background_header_image.dart';
import '../../../shared/presentation/widgets/date_tile.dart';
import '../../../shared/presentation/widgets/empty_state_widget.dart';
import '../bloc/diary_list/diary_list_bloc.dart';
import '../bloc/diary_list/diary_list_event.dart';
import '../bloc/diary_list/diary_list_state.dart';

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

class _HomeViewState extends State<_HomeView> {
  // Guards against rapid repeated taps on the FAB opening multiple
  // stacked Create screens.
  bool _isNavigatingToCreate = false;

  static const double _headerExpandedHeight = 200;

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
                        BackgroundHeaderImage(path: headerImagePath),
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

                  final dayGroups = EntryGroupingUtils.groupByDay<DiaryEntry>(
                    state.visibleEntries,
                    (entry) => entry.date,
                  );

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
                            DateTile(date: group.date),
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