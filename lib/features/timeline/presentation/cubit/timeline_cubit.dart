// lib/features/timeline/presentation/cubit/timeline_cubit.dart

import 'package:flutter_bloc/flutter_bloc.dart';

import 'timeline_state.dart';

/// Drives calendar navigation on the Timeline screen (month paging, day
/// selection). Entry data itself comes from the shared [DiaryListBloc]
/// via [BlocBuilder] in the page — this cubit is intentionally "dumb",
/// it has no knowledge of diary entries at all.
class TimelineCubit extends Cubit<TimelineState> {
  TimelineCubit() : super(TimelineState());

  void daySelected(DateTime day) {
    emit(state.copyWith(selectedDay: day, focusedDay: day));
  }

  void pageChanged(DateTime focusedDay) {
    emit(state.copyWith(focusedDay: focusedDay));
  }
}