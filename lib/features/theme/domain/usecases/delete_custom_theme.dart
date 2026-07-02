// lib/features/theme/domain/usecases/delete_custom_theme.dart

import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../repositories/theme_repository.dart';

/// Deletes the custom theme identified by [id].
class DeleteCustomTheme {
  final ThemeRepository repository;

  const DeleteCustomTheme(this.repository);

  Future<Either<Failure, Unit>> call(String id) {
    return repository.deleteCustomTheme(id);
  }
}