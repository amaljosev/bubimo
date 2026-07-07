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
                  return SliverPadding(
                    padding: const EdgeInsets.all(16),
                    sliver: SliverList.separated(
                      itemCount: state.visibleEntries.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final entry = state.visibleEntries[index];
                        return DiaryListItem(
                          entry: entry,
                          onTap: () => _openEntry(context, entry.id),
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
