// lib/features/timeline/presentation/cubit/timeline_state.dart

import 'package:equatable/equatable.dart';

/// Pure calendar-navigation state for the Timeline screen: which month
/// is currently in view ([focusedDay]) and which single day is
/// highlighted/expanded below the calendar ([selectedDay]).
///
/// Deliberately holds no diary entries — those come from the shared
/// [DiaryListBloc] that [MainShell] already keeps alive, so Timeline
/// reads the same data Diary/Favorites do rather than re-fetching.
class TimelineState extends Equatable {
  final DateTime focusedDay;
  final DateTime selectedDay;

  TimelineState({DateTime? focusedDay, DateTime? selectedDay})
    : focusedDay = focusedDay ?? DateTime.now(),
      selectedDay = selectedDay ?? focusedDay ?? DateTime.now();

  TimelineState copyWith({DateTime? focusedDay, DateTime? selectedDay}) {
    return TimelineState(
      focusedDay: focusedDay ?? this.focusedDay,
      selectedDay: selectedDay ?? this.selectedDay,
    );
  }

  @override
  List<Object?> get props => [focusedDay, selectedDay];
}