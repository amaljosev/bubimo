// lib/features/diary_entry/presentation/bloc/diary_form/diary_form_event.dart

part of 'diary_form_bloc.dart';


abstract class DiaryFormEvent extends Equatable {
  const DiaryFormEvent();
 
  @override
  List<Object?> get props => [];
}
 
/// Title field changed.
class DiaryFormTitleChanged extends DiaryFormEvent {
  final String title;
 
  const DiaryFormTitleChanged(this.title);
 
  @override
  List<Object?> get props => [title];
}
 
/// Content field changed.
class DiaryFormContentChanged extends DiaryFormEvent {
  final String content;
 
  const DiaryFormContentChanged(this.content);
 
  @override
  List<Object?> get props => [content];
}

/// Date field changed via the date picker.
class DiaryFormDateChanged extends DiaryFormEvent {
  final DateTime date;

  const DiaryFormDateChanged(this.date);

  @override
  List<Object?> get props => [date];
}

/// Mood selection changed via [MoodPicker].
class DiaryFormMoodChanged extends DiaryFormEvent {
  final Mood mood;

  const DiaryFormMoodChanged(this.mood);

  @override
  List<Object?> get props => [mood];
}
 
/// Save pressed — creates if [DiaryFormState.id] is null, updates otherwise.
class DiaryFormSubmitted extends DiaryFormEvent {
  const DiaryFormSubmitted();
}