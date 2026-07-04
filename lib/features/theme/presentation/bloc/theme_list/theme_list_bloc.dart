// lib/features/theme/presentation/bloc/theme_list/theme_list_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/usecases/get_all_themes.dart';
import '../../../domain/usecases/get_selected_theme.dart';
import 'theme_list_event.dart';
import 'theme_list_state.dart';

/// Drives the Theme Screen's list — all available themes (defaults +
/// custom) plus which one is currently selected, so the UI can
/// highlight it.
class ThemeListBloc extends Bloc<ThemeListEvent, ThemeListState> {
  final GetAllThemes getAllThemes;
  final GetSelectedTheme getSelectedTheme;

  ThemeListBloc({
    required this.getAllThemes,
    required this.getSelectedTheme,
  }) : super(const ThemeListState()) {
    on<LoadThemes>(_onLoadThemes);
  }

  Future<void> _onLoadThemes(
    LoadThemes event,
    Emitter<ThemeListState> emit,
  ) async {
    emit(state.copyWith(status: ThemeListStatus.loading));

    final themesResult = await getAllThemes();

    await themesResult.match(
      (failure) async => emit(
        state.copyWith(
          status: ThemeListStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (themes) async {
        final selectedResult = await getSelectedTheme();
        selectedResult.match(
          (failure) => emit(
            state.copyWith(
              status: ThemeListStatus.failure,
              errorMessage: failure.message,
            ),
          ),
          (selected) => emit(
            state.copyWith(
              status: ThemeListStatus.loaded,
              themes: themes,
              selectedThemeId: selected.id,
            ),
          ),
        );
      },
    );
  }
}