// lib/features/theme/domain/usecases/select_theme.dart

import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../repositories/theme_repository.dart';

/// Persists the user's theme choice and is the trigger `AppThemeCubit`
/// uses to make the change apply app-wide immediately.
///
/// Usage: `await selectTheme(themeId)`.
class SelectTheme {
  final ThemeRepository repository;

  const SelectTheme(this.repository);

  Future<Either<Failure, void>> call(String themeId) {
    return repository.selectTheme(themeId);
  }
}