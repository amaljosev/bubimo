// lib/features/theme/domain/usecases/get_all_themes.dart

import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/app_theme_data.dart';
import '../repositories/theme_repository.dart';

/// Fetches every available theme (defaults + custom) for the Theme
/// Screen's list.
///
/// Usage: `await getAllThemes()`.
class GetAllThemes {
  final ThemeRepository repository;

  const GetAllThemes(this.repository);

  Future<Either<Failure, List<AppThemeData>>> call() {
    return repository.getAllThemes();
  }
}