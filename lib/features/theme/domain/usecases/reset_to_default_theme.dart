// lib/features/theme/domain/usecases/reset_to_default_theme.dart

import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../repositories/theme_repository.dart';

class ResetToDefaultTheme {
  final ThemeRepository repository;

  const ResetToDefaultTheme(this.repository);

  Future<Either<Failure, void>> call() {
    return repository.resetToDefaultTheme();
  }
}
