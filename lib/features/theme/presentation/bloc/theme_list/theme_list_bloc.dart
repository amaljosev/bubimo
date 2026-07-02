
// lib/features/theme/presentation/bloc/theme_list/theme_list_bloc.dart
import 'package:bubimo/features/theme/domain/entities/app_theme_data.dart';
import 'package:bubimo/features/theme/domain/usecases/get_all_themes.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'theme_list_event.dart';
part 'theme_list_state.dart';


/// Drives the Theme Screen's list of default + custom themes.
///
/// Purely a read/list Bloc — selecting a theme is handled directly by
/// `ThemeScreen` calling `AppThemeCubit.changeTheme(...)`, not routed
/// through this Bloc, since the active-theme state that needs to live
/// above `MaterialApp` already belongs to `AppThemeCubit`.
class ThemeListBloc extends Bloc<ThemeListEvent, ThemeListState> {
  final GetAllThemes getAllThemes;

  ThemeListBloc({required this.getAllThemes}) : super(const ThemeListState()) {
    on<ThemeListRequested>(_onRequested);
  }

  Future<void> _onRequested(
    ThemeListRequested event,
    Emitter<ThemeListState> emit,
  ) async {
    emit(state.copyWith(status: ThemeListStatus.loading));

    final result = await getAllThemes();
    result.fold(
      (failure) => emit(state.copyWith(
        status: ThemeListStatus.error,
        errorMessage: failure.message,
      )),
      (themes) => emit(state.copyWith(
        status: ThemeListStatus.loaded,
        themes: themes,
      )),
    );
  }
}