// lib/features/theme/domain/usecases/select_theme.dart

import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../repositories/theme_repository.dart';

class SelectTheme {
  final ThemeRepository repository;

  const SelectTheme(this.repository);

  Future<Either<Failure, void>> call(String themeId) {
    return repository.selectTheme(themeId);
  }
}
