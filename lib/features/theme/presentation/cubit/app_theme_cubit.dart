// lib/features/theme/presentation/cubit/app_theme_cubit.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/theme_mapper.dart';
import '../../domain/entities/app_theme_data.dart';
import '../../domain/usecases/get_selected_theme.dart';
import '../../domain/usecases/select_theme.dart';

/// Holds the app's CURRENT active [ThemeData] and is provided ABOVE
/// `MaterialApp`, so any theme change rebuilds the whole app live —
/// no restart required.
///
/// This is registered as a lazy singleton in GetIt (not a factory),
/// since it must persist for the app's entire lifetime.
///
/// [ThemeData] construction (color scheme, font, header image
/// extension) is delegated to [buildThemeData] in `theme_mapper.dart`
/// rather than built inline here, so that conversion logic stays
/// independently readable/testable and isn't duplicated.
class AppThemeCubit extends Cubit<ThemeData> {
  final GetSelectedTheme getSelectedTheme;
  final SelectTheme selectTheme;

  /// The domain data behind the current [state], kept alongside it so
  /// screens (e.g. Theme Screen) can read which theme id is active
  /// without a separate query.
  AppThemeData? currentTheme;

  AppThemeCubit({
    required this.getSelectedTheme,
    required this.selectTheme,
  }) : super(AppTheme.light());

  /// Loads the user's previously selected theme. Call this once during
  /// app startup, before `runApp`, so the correct theme is active on
  /// first frame instead of flashing the fallback default.
  Future<void> loadInitialTheme() async {
    final result = await getSelectedTheme();
    result.match(
      (_) {
        // Fall back silently to the default ThemeData already set as
        // this cubit's initial state — there's nothing meaningful to
        // show the user for a startup theme-load failure.
      },
      (theme) {
        currentTheme = theme;
        emit(buildThemeData(theme));
      },
    );
  }

  /// Persists [themeId] as the selection and applies it immediately.
  Future<Either<Failure, void>> changeTheme(String themeId) async {
    final selectResult = await selectTheme(themeId);
    if (selectResult.isLeft()) return selectResult;

    final selectedResult = await getSelectedTheme();
    return selectedResult.match(
      (failure) => Left(failure),
      (theme) {
        currentTheme = theme;
        emit(buildThemeData(theme));
        return const Right(null);
      },
    );
  }
}