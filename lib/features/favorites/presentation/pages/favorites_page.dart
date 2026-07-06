// lib/features/favorites/presentation/pages/favorites_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
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

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: colorScheme.surface,
            foregroundColor: colorScheme.onSurface,
            centerTitle: true,
            automaticallyImplyLeading: false,
            elevation: 0,
            title: const Text('Favorites'),
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
                  final favorites = state.entries
                      .where((e) => e.isFavorite)
                      .toList();

                  if (favorites.isEmpty) {
                    return SliverFillRemaining(
                      child: EmptyStateWidget(
                        isFavoritesFilter: true,
                        onCreatePressed: () => _openCreateEntry(context),
                      ),
                    );
                  }
                  return SliverPadding(
                    padding: const EdgeInsets.all(16),
                    sliver: SliverList.separated(
                      itemCount: favorites.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final entry = favorites[index];
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
    );
  }
}