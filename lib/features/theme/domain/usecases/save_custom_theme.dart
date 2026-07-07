// lib/features/theme/domain/usecases/save_custom_theme.dart

import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/app_theme_data.dart';
import '../repositories/theme_repository.dart';

/// Maximum number of custom themes a user may have saved at once.
const int kMaxCustomThemes = 3;

/// Saves (creates or edits) a custom theme.
///
/// The 3-theme limit is enforced here, in the domain layer, rather than
/// only in the data layer — this use case fetches the current theme
/// list first so the check is a single well-named place any caller can
/// rely on, independent of how the data source enforces (or doesn't
/// enforce) it internally.
///
/// Editing an existing custom theme (same [AppThemeData.id] already
/// present among the saved custom themes) never counts against the
/// limit — only brand-new ids do.
class SaveCustomTheme {
  final ThemeRepository repository;

  const SaveCustomTheme(this.repository);

  Future<Either<Failure, void>> call(AppThemeData theme) async {
    final allThemesResult = await repository.getAllThemes();

    if (allThemesResult.isLeft()) {
      return allThemesResult.match((f) => Left(f), (_) => const Right(null));
    }

    final themes = allThemesResult.getOrElse((_) => const []);
    final isEditingExisting =
        themes.any((t) => t.id == theme.id && !t.isBuiltIn);
    final customCount = themes.where((t) => !t.isBuiltIn).length;

    if (!isEditingExisting && customCount >= kMaxCustomThemes) {
      return const Left(
        ValidationFailure(
          'You can only save up to $kMaxCustomThemes custom themes.',
        ),
      );
    }

    return repository.saveCustomTheme(theme);
  }
}
