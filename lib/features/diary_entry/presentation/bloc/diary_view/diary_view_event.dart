// lib/features/diary_entry/presentation/bloc/diary_view/diary_view_event.dart
part of 'diary_view_bloc.dart';

abstract class DiaryViewEvent extends Equatable {
  const DiaryViewEvent();

  @override
  List<Object?> get props => [];
}

/// Requests that the entry with [id] be (re)loaded. Dispatched on screen
/// open, and re-dispatched whenever the screen needs fresh data — e.g.
/// after returning from a successful edit.
class DiaryViewRequested extends DiaryViewEvent {
  final String id;

  const DiaryViewRequested(this.id);

  @override
  List<Object?> get props => [id];
}