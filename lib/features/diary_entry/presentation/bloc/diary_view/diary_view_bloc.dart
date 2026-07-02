// lib/features/diary_entry/presentation/bloc/diary_view/diary_view_bloc.dart

import 'package:bubimo/features/diary_entry/domain/entities/diary_entry.dart';
import 'package:bubimo/features/diary_entry/domain/usecases/get_diary_entry_by_id.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'diary_view_event.dart';
part 'diary_view_state.dart';

/// Drives the Diary Entry View screen: loads a single entry fresh by id.
///
/// Deliberately fetch-by-id-only, no navigation-time entry passed in — one
/// code path whether the entry is reached from Home, returning from Edit,
/// or (in a later milestone) a deep link/notification. Guarantees the
/// displayed data is always current rather than a possibly-stale copy
/// carried over from wherever the user navigated from.
class DiaryViewBloc extends Bloc<DiaryViewEvent, DiaryViewState> {
  final GetDiaryEntryById getDiaryEntryById;

  DiaryViewBloc(this.getDiaryEntryById) : super(const DiaryViewInitial()) {
    on<DiaryViewRequested>(_onRequested);
  }

  Future<void> _onRequested(
    DiaryViewRequested event,
    Emitter<DiaryViewState> emit,
  ) async {
    emit(const DiaryViewLoading());
    final result = await getDiaryEntryById(event.id);
    result.fold(
      (failure) => emit(DiaryViewError(failure.message)),
      (entry) => emit(DiaryViewLoaded(entry)),
    );
  }
}