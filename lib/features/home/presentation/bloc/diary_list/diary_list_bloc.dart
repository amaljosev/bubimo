// lib/features/home/presentation/bloc/diary_list/diary_list_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../diary_entry/domain/usecases/get_all_diary_entries.dart';
import 'diary_list_event.dart';
import 'diary_list_state.dart';

/// Drives Home's entry list. Reuses [GetAllDiaryEntries] from the
/// diary_entry feature directly — this bloc owns no data of its own,
/// it's purely presentation state for the Home screen.
///
/// The favorites filter ([FavoritesFilterChanged]) does NOT re-fetch —
/// it just flips a flag and [DiaryListState.visibleEntries] filters the
/// already-loaded list in memory. No separate favorites feature/use
/// case exists; this is intentional.
class DiaryListBloc extends Bloc<DiaryListEvent, DiaryListState> {
  final GetAllDiaryEntries getAllDiaryEntries;

  DiaryListBloc({required this.getAllDiaryEntries})
      : super(const DiaryListState()) {
    on<LoadDiaryEntries>(_onLoadDiaryEntries);
    on<FavoritesFilterChanged>(_onFavoritesFilterChanged);
  }

  Future<void> _onLoadDiaryEntries(
    LoadDiaryEntries event,
    Emitter<DiaryListState> emit,
  ) async {
    emit(state.copyWith(status: DiaryListStatus.loading));

    final result = await getAllDiaryEntries();

    result.match(
      (failure) => emit(
        state.copyWith(
          status: DiaryListStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (entries) => emit(
        state.copyWith(status: DiaryListStatus.loaded, entries: entries),
      ),
    );
  }

  void _onFavoritesFilterChanged(
    FavoritesFilterChanged event,
    Emitter<DiaryListState> emit,
  ) {
    emit(state.copyWith(showFavoritesOnly: event.showFavoritesOnly));
  }
}