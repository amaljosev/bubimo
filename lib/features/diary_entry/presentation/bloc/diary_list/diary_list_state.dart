// lib/features/diary_entry/presentation/bloc/diary_list/diary_list_state.dart
part of 'diary_list_bloc.dart';


abstract class DiaryListState extends Equatable {
  const DiaryListState();
 
  @override
  List<Object?> get props => [];
}
 
class DiaryListInitial extends DiaryListState {
  const DiaryListInitial();
}
 
class DiaryListLoading extends DiaryListState {
  const DiaryListLoading();
}
 
class DiaryListLoaded extends DiaryListState {
  final List<DiaryEntry> entries;
 
  const DiaryListLoaded(this.entries);
 
  @override
  List<Object?> get props => [entries];
}
 
class DiaryListError extends DiaryListState {
  final String message;
 
  const DiaryListError(this.message);
 
  @override
  List<Object?> get props => [message];
}