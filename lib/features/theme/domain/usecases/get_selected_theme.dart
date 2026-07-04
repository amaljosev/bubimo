// lib/features/theme/domain/usecases/get_selected_theme.dart

import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/app_theme_data.dart';
import '../repositories/theme_repository.dart';

/// Fetches the currently active theme. Called once on app start by
/// `AppThemeCubit` to determine the initial `ThemeData` before
/// `MaterialApp` first builds.
///
/// Usage: `await getSelectedTheme()`.
class GetSelectedTheme {
  final ThemeRepository repository;

  const GetSelectedTheme(this.repository);

  Future<Either<Failure, AppThemeData>> call() {
    return repository.getSelectedTheme();
  }
}