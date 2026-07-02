// lib/features/diary_entry/presentation/bloc/diary_view/diary_view_state.dart
part of 'diary_view_bloc.dart';

abstract class DiaryViewState extends Equatable {
  const DiaryViewState();

  @override
  List<Object?> get props => [];
}

class DiaryViewInitial extends DiaryViewState {
  const DiaryViewInitial();
}

class DiaryViewLoading extends DiaryViewState {
  const DiaryViewLoading();
}

class DiaryViewLoaded extends DiaryViewState {
  final DiaryEntry entry;

  const DiaryViewLoaded(this.entry);

  @override
  List<Object?> get props => [entry];
}

class DiaryViewError extends DiaryViewState {
  final String message;

  const DiaryViewError(this.message);

  @override
  List<Object?> get props => [message];
}