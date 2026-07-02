// lib/features/theme/domain/usecases/select_theme.dart

import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../repositories/theme_repository.dart';

/// Persists [id] as the selected theme.
class SelectTheme {
  final ThemeRepository repository;

  const SelectTheme(this.repository);

  Future<Either<Failure, Unit>> call(String id) {
    return repository.selectTheme(id);
  }
}