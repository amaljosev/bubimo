// lib/features/home/presentation/pages/home_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/widgets/error_screen.dart';
import '../../../../core/widgets/loading_screen.dart';
import '../bloc/diary_list/diary_list_bloc.dart';
import '../bloc/diary_list/diary_list_event.dart';
import '../bloc/diary_list/diary_list_state.dart';
import '../widgets/diary_list_item.dart';
import '../widgets/empty_state_widget.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<DiaryListBloc>()..add(const LoadDiaryEntries()),
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
  // Guards against rapid repeated taps on the FAB opening multiple
  // stacked Create screens.
  bool _isNavigatingToCreate = false;

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Diary'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: BlocBuilder<DiaryListBloc, DiaryListState>(
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
          ),
        ),
      ),
      body: BlocBuilder<DiaryListBloc, DiaryListState>(
        builder: (context, state) {
          switch (state.status) {
            case DiaryListStatus.initial:
            case DiaryListStatus.loading:
              return const LoadingScreen();

            case DiaryListStatus.failure:
              return ErrorScreen(
                message: state.errorMessage ?? 'Something went wrong.',
                onRetry: () => context
                    .read<DiaryListBloc>()
                    .add(const LoadDiaryEntries()),
              );

            case DiaryListStatus.loaded:
              if (state.isEmpty) {
                return EmptyStateWidget(
                  isFavoritesFilter: state.showFavoritesOnly,
                  onCreatePressed: () => _openCreateEntry(context),
                );
              }
              return RefreshIndicator(
                onRefresh: () async => context
                    .read<DiaryListBloc>()
                    .add(const LoadDiaryEntries()),
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openCreateEntry(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}