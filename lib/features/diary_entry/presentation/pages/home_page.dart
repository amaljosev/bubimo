// lib/features/diary_entry/presentation/pages/home_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Diary')),
      body: BlocBuilder<DiaryListBloc, DiaryListState>(
        builder: (context, state) {
          if (state is DiaryListLoading || state is DiaryListInitial) {
            return const LoadingScreen();
          }
          if (state is DiaryListError) {
            return ErrorScreen(
              message: state.message,
              onRetry: () =>
                  context.read<DiaryListBloc>().add(const DiaryListRequested()),
            );
          }
          if (state is DiaryListLoaded) {
            if (state.entries.isEmpty) {
              return const EmptyStateWidget();
            }
            return RefreshIndicator(
              onRefresh: () async {
                context.read<DiaryListBloc>().add(const DiaryListRequested());
              },
              child: ListView.builder(
                itemCount: state.entries.length,
                itemBuilder: (context, index) {
                  final entry = state.entries[index];
                  return DiaryListItem(
                    entry: entry,
                    onTap: () => _handleViewEntry(entry),
                    onDelete: () {},
                  );
                },
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _handleCreateEntry,
        child: const Icon(Icons.add),
      ),
    );
  }
}