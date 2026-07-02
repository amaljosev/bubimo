// lib/features/diary_entry/presentation/bloc/diary_list/diary_list_event.dart
part of 'diary_list_bloc.dart';

abstract class DiaryListEvent extends Equatable {
  const DiaryListEvent();
 
  @override
  List<Object?> get props => [];
}
 
/// Triggers loading (or reloading) of all diary entries.
class DiaryListRequested extends DiaryListEvent {
  const DiaryListRequested();
}
 