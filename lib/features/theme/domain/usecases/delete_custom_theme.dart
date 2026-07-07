// lib/features/theme/domain/usecases/delete_custom_theme.dart

import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../repositories/theme_repository.dart';

class DeleteCustomTheme {
  final ThemeRepository repository;

  const DeleteCustomTheme(this.repository);

  Future<Either<Failure, void>> call(String themeId) {
    return repository.deleteCustomTheme(themeId);
  }
}
