// lib/features/theme/presentation/bloc/theme_list/theme_list_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/usecases/delete_custom_theme.dart';
import '../../../domain/usecases/get_all_themes.dart';
import '../../../domain/usecases/get_selected_theme.dart';
import '../../cubit/app_theme_cubit.dart';
import 'theme_list_event.dart';
import 'theme_list_state.dart';

/// Drives the Theme Switcher screen's list of built-in + custom themes.
///
/// Applying/resetting a theme is delegated to [AppThemeCubit] (injected
/// directly, not via a use case) since that's the single source of
/// truth for the app's live [ThemeData] — this bloc only needs to
/// re-fetch the list afterward to refresh [ThemeListState.activeThemeId]
/// and re-render tiles.
class ThemeListBloc extends Bloc<ThemeListEvent, ThemeListState> {
  final GetAllThemes getAllThemes;
  final GetSelectedTheme getSelectedTheme;
  final DeleteCustomTheme deleteCustomTheme;
  final AppThemeCubit appThemeCubit;

  ThemeListBloc({
    required this.getAllThemes,
    required this.getSelectedTheme,
    required this.deleteCustomTheme,
    required this.appThemeCubit,
  }) : super(const ThemeListState()) {
    on<ThemeListLoaded>(_onLoaded);
    on<ThemeListThemeApplied>(_onThemeApplied);
    on<ThemeListResetToDefaultRequested>(_onResetToDefaultRequested);
    on<ThemeListCustomThemeDeleted>(_onCustomThemeDeleted);
  }

  Future<void> _onLoaded(
    ThemeListLoaded event,
    Emitter<ThemeListState> emit,
  ) async {
    emit(state.copyWith(status: ThemeListStatus.loading, clearError: true));

    final themesResult = await getAllThemes();
    final selectedResult = await getSelectedTheme();

    themesResult.match(
      (failure) => emit(
        state.copyWith(
          status: ThemeListStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (themes) {
        final builtIns = themes.where((t) => t.isBuiltIn).toList();
        final customs = themes.where((t) => !t.isBuiltIn).toList();
        final activeId = selectedResult.match((_) => null, (t) => t.id);

        emit(
          state.copyWith(
            status: ThemeListStatus.loaded,
            builtInThemes: builtIns,
            customThemes: customs,
            activeThemeId: activeId,
          ),
        );
      },
    );
  }

  Future<void> _onThemeApplied(
    ThemeListThemeApplied event,
    Emitter<ThemeListState> emit,
  ) async {
    emit(state.copyWith(isActionInProgress: true, clearError: true));

    final result = await appThemeCubit.changeTheme(event.themeId);

    result.match(
      (failure) => emit(
        state.copyWith(
          isActionInProgress: false,
          errorMessage: failure.message,
        ),
      ),
      (_) => emit(
        state.copyWith(
          isActionInProgress: false,
          activeThemeId: event.themeId,
        ),
      ),
    );
  }

  Future<void> _onResetToDefaultRequested(
    ThemeListResetToDefaultRequested event,
    Emitter<ThemeListState> emit,
  ) async {
    emit(state.copyWith(isActionInProgress: true, clearError: true));

    final result = await appThemeCubit.resetToDefault();

    result.match(
      (failure) => emit(
        state.copyWith(
          isActionInProgress: false,
          errorMessage: failure.message,
        ),
      ),
      (_) => emit(
        state.copyWith(
          isActionInProgress: false,
          activeThemeId: appThemeCubit.currentTheme?.id,
        ),
      ),
    );
  }

  Future<void> _onCustomThemeDeleted(
    ThemeListCustomThemeDeleted event,
    Emitter<ThemeListState> emit,
  ) async {
    emit(state.copyWith(isActionInProgress: true, clearError: true));

    final result = await deleteCustomTheme(event.themeId);

    final deletedWasActive = state.activeThemeId == event.themeId;

    await result.match(
      (failure) async {
        emit(
          state.copyWith(
            isActionInProgress: false,
            errorMessage: failure.message,
          ),
        );
      },
      (_) async {
        // If the deleted theme was currently applied, fall back to the
        // default so the app is never left pointing at a nonexistent
        // theme id.
        if (deletedWasActive) {
          await appThemeCubit.resetToDefault();
        }
        emit(state.copyWith(isActionInProgress: false));
        add(const ThemeListLoaded());
      },
    );
  }
}
