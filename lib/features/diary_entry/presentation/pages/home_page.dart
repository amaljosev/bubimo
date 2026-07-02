// lib/features/diary_entry/presentation/pages/home_page.dart

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/background_image_theme_extension.dart';
import '../../../../core/widgets/error_screen.dart';
import '../../../../core/widgets/loading_screen.dart';
import '../../domain/entities/diary_entry.dart';
import '../bloc/diary_list/diary_list_bloc.dart';
import '../widgets/diary_list_item.dart';
import '../widgets/empty_state_widget.dart';

/// Home Screen — list of diary entries.
///
/// `HomePage` owns its own navigation calls so it can `await` each push's
/// result and conditionally re-dispatch [DiaryListRequested] on return.
/// Re-entrancy guard (`_isNavigating`) prevents duplicate pushes on rapid
/// taps.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          GetIt.instance<DiaryListBloc>()..add(const DiaryListRequested()),
      child: const _HomeView(),
    );
  }
}

class _HomeView extends StatefulWidget {
  const _HomeView();

  @override
  State<_HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<_HomeView> {
  bool _isNavigating = false;

  Future<void> _handleCreateEntry() async {
    if (_isNavigating) return;
    _isNavigating = true;
    try {
      final result = await context.pushNamed<bool>(AppRoutes.diaryForm);
      if (result == true && mounted) {
        context.read<DiaryListBloc>().add(const DiaryListRequested());
      }
    } finally {
      _isNavigating = false;
    }
  }

  /// Diary Entry View now needs an `id` path parameter, not the full
  /// entry as `extra` — see `app_router.dart`'s `/diary-entry/:id` route.
  Future<void> _handleViewEntry(DiaryEntry entry) async {
    if (_isNavigating) return;
    _isNavigating = true;
    try {
      final result = await context.pushNamed<bool>(
        AppRoutes.diaryEntryView,
        pathParameters: {'id': entry.id!},
      );
      if (result == true && mounted) {
        context.read<DiaryListBloc>().add(const DiaryListRequested());
      }
    } finally {
      _isNavigating = false;
    }
  }

  /// Opens the Theme Screen. No result is expected back (theme changes
  /// apply live via `AppThemeCubit` regardless of how this screen is
  /// dismissed), so unlike the other two handlers this doesn't
  /// conditionally re-dispatch [DiaryListRequested] — there's nothing
  /// about diary entries that a theme change would invalidate.
  Future<void> _handleOpenThemes() async {
    if (_isNavigating) return;
    _isNavigating = true;
    try {
      await context.pushNamed(AppRoutes.themeScreen);
    } finally {
      _isNavigating = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final headerImagePath =
        Theme.of(context).extension<BackgroundImageTheme>()?.imagePath;

    return Scaffold(
      body: BlocBuilder<DiaryListBloc, DiaryListState>(
        builder: (context, state) {
          Widget sliverBody;
          if (state is DiaryListLoading || state is DiaryListInitial) {
            sliverBody = const SliverFillRemaining(child: LoadingScreen());
          } else if (state is DiaryListError) {
            sliverBody = SliverFillRemaining(
              child: ErrorScreen(
                message: state.message,
                onRetry: () => context
                    .read<DiaryListBloc>()
                    .add(const DiaryListRequested()),
              ),
            );
          } else if (state is DiaryListLoaded && state.entries.isEmpty) {
            sliverBody = const SliverFillRemaining(child: EmptyStateWidget());
          } else if (state is DiaryListLoaded) {
            sliverBody = SliverList.builder(
              itemCount: state.entries.length,
              itemBuilder: (context, index) {
                final entry = state.entries[index];
                return DiaryListItem(
                  entry: entry,
                  onTap: () => _handleViewEntry(entry),
                  onDelete: () {},
                );
              },
            );
          } else {
            sliverBody = const SliverFillRemaining(child: SizedBox.shrink());
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<DiaryListBloc>().add(const DiaryListRequested());
            },
            child: CustomScrollView(
              // CustomScrollView needs `physics` that always allow a
              // drag for pull-to-refresh to work even when content is
              // shorter than the viewport (e.g. the empty state) — same
              // reasoning `ListView` gets for free from `RefreshIndicator`
              // normally, but a `SliverFillRemaining` child doesn't
              // scroll on its own.
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverAppBar(
                  title: const Text('My Diary'),
                  centerTitle: true,
                  pinned: true,
                  // Expands to show the header image when the active
                  // theme has one; collapses to a plain AppBar height
                  // otherwise (headerImagePath == null), so themes
                  // without a header image don't waste vertical space
                  // on an empty expanded band.
                  expandedHeight: headerImagePath != null ? 200 : null,
                  flexibleSpace: headerImagePath != null
                      ? FlexibleSpaceBar(
                          background: Image.file(
                            File(headerImagePath),
                            fit: BoxFit.cover,
                            // A theme's header image path can go stale
                            // (e.g. the app's cache dir was cleared) —
                            // fall back to a plain color rather than
                            // letting Image.file's default red error
                            // box break the AppBar's look.
                            errorBuilder: (context, error, stackTrace) =>
                                ColoredBox(
                              color: Theme.of(context).colorScheme.surface,
                            ),
                          ),
                        )
                      : null,
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.palette_outlined),
                      tooltip: 'Themes',
                      onPressed: _handleOpenThemes,
                    ),
                  ],
                ),
                sliverBody,
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _handleCreateEntry,
        child: const Icon(Icons.add),
      ),
    );
  }
}