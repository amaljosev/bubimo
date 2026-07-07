// lib/features/theme/data/repositories/theme_repository_impl.dart

import 'package:fpdart/fpdart.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/theme/built_in_themes.dart';
import '../../domain/entities/app_theme_data.dart';
import '../../domain/repositories/theme_repository.dart';
import '../datasources/theme_local_data_source.dart';
import '../models/custom_theme_model.dart';

class ThemeRepositoryImpl implements ThemeRepository {
  final ThemeLocalDataSource _localDataSource;

  ThemeRepositoryImpl(this._localDataSource);

  @override
  Future<Either<Failure, List<AppThemeData>>> getAllThemes() async {
    try {
      final customModels = await _localDataSource.getCustomThemes();
      final customThemes = customModels.map((m) => m.theme).toList();
      return Right([...BuiltInThemes.all, ...customThemes]);
    } on AppException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AppThemeData>> getSelectedTheme() async {
    try {
      final activeId = await _localDataSource.getActiveThemeId();
      if (activeId == null) return Right(BuiltInThemes.defaultTheme);

      final builtIn = BuiltInThemes.all.where((t) => t.id == activeId);
      if (builtIn.isNotEmpty) return Right(builtIn.first);

      final customModels = await _localDataSource.getCustomThemes();
      final match = customModels.where((m) => m.theme.id == activeId);
      if (match.isNotEmpty) return Right(match.first.theme);

      // The persisted id doesn't match any known theme (e.g. its custom
      // theme was deleted elsewhere) — fall back to default rather than
      // erroring.
      return Right(BuiltInThemes.defaultTheme);
    } on AppException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> selectTheme(String themeId) async {
    try {
      await _localDataSource.setActiveThemeId(themeId);
      return const Right(null);
    } on AppException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> resetToDefaultTheme() async {
    return selectTheme(BuiltInThemes.defaultBuiltInThemeId);
  }

  @override
  Future<Either<Failure, void>> saveCustomTheme(AppThemeData theme) async {
    try {
      await _localDataSource.saveCustomTheme(CustomThemeModel(theme));
      return const Right(null);
    } on AppException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteCustomTheme(String themeId) async {
    try {
      await _localDataSource.deleteCustomTheme(themeId);
      return const Right(null);
    } on AppException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }
}
