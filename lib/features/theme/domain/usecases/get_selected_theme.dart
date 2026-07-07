// lib/features/theme/domain/usecases/get_selected_theme.dart

import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/app_theme_data.dart';
import '../repositories/theme_repository.dart';

class GetSelectedTheme {
  final ThemeRepository repository;

  const GetSelectedTheme(this.repository);

  Future<Either<Failure, AppThemeData>> call() {
    return repository.getSelectedTheme();
  }
}
