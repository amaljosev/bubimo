// lib/features/diary_entry/presentation/bloc/diary_list/diary_list_bloc.dart

import 'package:bubimo/features/diary_entry/domain/entities/diary_entry.dart';
import 'package:bubimo/features/diary_entry/domain/usecases/get_all_diary_entries.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'diary_list_event.dart';
part 'diary_list_state.dart';

/// Drives the Home Screen: loads all entries.
///
/// Delete is NOT handled here — per the actual router/DI setup, deletion
/// happens from the Diary Entry View screen (`onDeleted` callback), which
/// pops back to Home; Home then simply reloads via [DiaryListRequested].
/// This keeps this bloc's dependencies matching its GetIt registration
/// (`DiaryListBloc(GetAllDiaryEntries)` — no `DeleteDiaryEntry`).
class DiaryListBloc extends Bloc<DiaryListEvent, DiaryListState> {
  final GetAllDiaryEntries getAllDiaryEntries;
 
  DiaryListBloc(this.getAllDiaryEntries) : super(const DiaryListInitial()) {
    on<DiaryListRequested>(_onRequested);
  }
 
  Future<void> _onRequested(
    DiaryListRequested event,
    Emitter<DiaryListState> emit,
  ) async {
    emit(const DiaryListLoading());
    final result = await getAllDiaryEntries();
    result.fold(
      (failure) => emit(DiaryListError(failure.message)),
      (entries) => emit(DiaryListLoaded(entries)),
    );
  }
}