// lib/features/theme/data/repositories/theme_repository_impl.dart

import 'package:fpdart/fpdart.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/app_theme_data.dart';
import '../../domain/repositories/theme_repository.dart';
import '../datasources/theme_local_data_source.dart';
import '../models/app_theme_model.dart';

/// Implements [ThemeRepository] by merging the static default themes with
/// custom themes from [ThemeLocalDataSource], and converting thrown
/// exceptions into [Failure]s.
class ThemeRepositoryImpl implements ThemeRepository {
  final ThemeLocalDataSource localDataSource;

  const ThemeRepositoryImpl(this.localDataSource);

  @override
  Future<Either<Failure, List<AppThemeData>>> getAllThemes() async {
    try {
      final customThemes = await localDataSource.getCustomThemes();
      return Right([...AppThemeModel.defaultThemes, ...customThemes]);
    } on AppDatabaseException catch (e) {
      return Left(DatabaseFailure( e.message));
    } catch (e) {
      return Left(UnexpectedFailure( e.toString()));
    }
  }

  @override
  Future<Either<Failure, AppThemeData>> getSelectedTheme() async {
    try {
      final selectedId = await localDataSource.getSelectedThemeId();

      // Fresh install, or the id was somehow cleared: fall back to the
      // first default theme rather than surfacing an error — there's
      // always a sensible theme to show, so this isn't a failure case.
      if (selectedId == null) {
        return Right(AppThemeModel.defaultThemes.first);
      }

      final defaultMatch = AppThemeModel.defaultThemes
          .where((t) => t.id == selectedId)
          .firstOrNull;
      if (defaultMatch != null) return Right(defaultMatch);

      final customThemes = await localDataSource.getCustomThemes();
      final customMatch =
          customThemes.where((t) => t.id == selectedId).firstOrNull;
      if (customMatch != null) return Right(customMatch);

      // The previously-selected custom theme was deleted since it was
      // selected — fall back to the first default rather than erroring,
      // consistent with the fresh-install case above.
      return Right(AppThemeModel.defaultThemes.first);
    } on AppDatabaseException catch (e) {
      return Left(DatabaseFailure( e.message));
    } catch (e) {
      return Left(UnexpectedFailure( e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> selectTheme(String id) async {
    try {
      await localDataSource.setSelectedThemeId(id);
      return const Right(unit);
    } on AppDatabaseException catch (e) {
      return Left(DatabaseFailure( e.message));
    } catch (e) {
      return Left(UnexpectedFailure( e.toString()));
    }
  }

  @override
Future<Either<Failure, Unit>> saveCustomTheme(AppThemeData theme) async {
  try {
    final model = AppThemeModel.fromEntity(theme);
    await localDataSource.saveCustomTheme(model);
    return const Right(unit);
  } on AppDatabaseException catch (e) {
    return Left(DatabaseFailure(e.message));
  } catch (e) {
    return Left(UnexpectedFailure(e.toString()));
  }
}

  @override
  Future<Either<Failure, Unit>> deleteCustomTheme(String id) async {
    try {
      await localDataSource.deleteCustomTheme(id);
      return const Right(unit);
    } on AppDatabaseException catch (e) {
      return Left(DatabaseFailure( e.message));
    } catch (e) {
      return Left(UnexpectedFailure( e.toString()));
    }
  }
}