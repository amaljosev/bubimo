// lib/features/theme/presentation/cubit/app_theme_cubit.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/theme_mapper.dart';
import '../../domain/entities/app_theme_data.dart';
import '../../domain/usecases/get_selected_theme.dart';
import '../../domain/usecases/select_theme.dart';

/// Holds the app's currently active [ThemeData], provided ABOVE
/// `MaterialApp` (see `main.dart`) so that any theme change triggers a
/// full app rebuild with the new theme live — no restart required.
///
/// State is `ThemeData` directly, since this Cubit sits at the
/// `MaterialApp` boundary specifically to serve `MaterialApp.theme`.
/// `loadInitialTheme`/`changeTheme` return `bool` (success/failure)
/// rather than folding failure silently, so callers (e.g.
/// `ThemeScreen`) can surface an error to the user.
///
/// Registered as a `LazySingleton` in GetIt — must persist for the app's
/// entire lifetime, shared by exactly one `BlocProvider` at the root of
/// the widget tree.
class AppThemeCubit extends Cubit<ThemeData> {
  final GetSelectedTheme getSelectedTheme;
  final SelectTheme selectTheme;

  /// The currently active theme's full domain entity — retained
  /// alongside the emitted `ThemeData` state so `ThemeListBloc`/
  /// `ThemeScreen` can compare "is this list item the selected one?" by
  /// id without this Cubit needing a second, parallel state shape.
  AppThemeData? _activeTheme;

  AppThemeData? get activeTheme => _activeTheme;

  AppThemeCubit({
    required this.getSelectedTheme,
    required this.selectTheme,
  }) : super(ThemeData.light());

  /// Loads the persisted selected theme and emits its `ThemeData`. Call
  /// once on app start (see `main.dart`). Returns `true` on success,
  /// `false` on failure (in which case the Cubit's initial fallback
  /// `ThemeData.light()` state remains active).
  Future<bool> loadInitialTheme() async {
    final result = await getSelectedTheme();
    return result.fold(
      (failure) => false,
      (theme) {
        _activeTheme = theme;
        emit(buildThemeData(theme));
        return true;
      },
    );
  }

  /// Changes the active theme to [theme]: persists the selection via
  /// [SelectTheme], then emits the new `ThemeData` on success — this
  /// emission is what makes the change apply app-wide immediately, since
  /// `MaterialApp` (in `main.dart`) rebuilds on every emission from this
  /// Cubit. Returns `true`/`false` so callers can show their own error
  /// feedback on failure.
  Future<bool> changeTheme(AppThemeData theme) async {
    final result = await selectTheme(theme.id);
    return result.fold(
      (failure) => false,
      (_) {
        _activeTheme = theme;
        emit(buildThemeData(theme));
        return true;
      },
    );
  }
}