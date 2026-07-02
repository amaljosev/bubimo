// lib/features/theme/domain/usecases/get_all_themes.dart

import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/app_theme_data.dart';
import '../repositories/theme_repository.dart';

/// Fetches all themes available for selection (defaults + custom).
class GetAllThemes {
  final ThemeRepository repository;

  const GetAllThemes(this.repository);

  Future<Either<Failure, List<AppThemeData>>> call() {
    return repository.getAllThemes();
  }
}