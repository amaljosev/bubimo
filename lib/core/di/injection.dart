// lib/core/di/injection.dart

import 'package:bubimo/features/theme/%20data/datasources/theme_local_data_source.dart';
import 'package:bubimo/features/theme/%20data/repositories/theme_repository_impl.dart';
import 'package:get_it/get_it.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../../features/diary_entry/data/datasources/diary_local_data_source.dart';
import '../../features/diary_entry/data/repositories/diary_repository_impl.dart';
import '../../features/diary_entry/domain/repositories/diary_repository.dart';
import '../../features/diary_entry/domain/usecases/create_diary_entry.dart';
import '../../features/diary_entry/domain/usecases/delete_diary_entry.dart';
import '../../features/diary_entry/domain/usecases/get_all_diary_entries.dart';
import '../../features/diary_entry/domain/usecases/get_diary_entry_by_id.dart';
import '../../features/diary_entry/domain/usecases/update_diary_entry.dart';
import '../../features/diary_entry/presentation/bloc/diary_list/diary_list_bloc.dart';
import '../../features/diary_entry/presentation/bloc/diary_view/diary_view_bloc.dart';

import '../../features/theme/domain/repositories/theme_repository.dart';
import '../../features/theme/domain/usecases/delete_custom_theme.dart';
import '../../features/theme/domain/usecases/get_all_themes.dart';
import '../../features/theme/domain/usecases/get_selected_theme.dart';
import '../../features/theme/domain/usecases/save_custom_theme.dart';
import '../../features/theme/domain/usecases/select_theme.dart';
import '../../features/theme/presentation/bloc/theme_list/theme_list_bloc.dart';
import '../../features/theme/presentation/cubit/app_theme_cubit.dart';

/// Global service locator instance.
///
/// Accessed throughout the app via `getIt<SomeType>()`. This is deliberately
/// a plain top-level `GetIt` instance with manual registration — no
/// code generation, no `injectable` annotations, no `build_runner`.
final GetIt getIt = GetIt.instance;

/// Registers all app-wide dependencies with [getIt].
///
/// Call this once, before `runApp`, typically from `main()`:
/// ```dart
/// void main() async {
///   WidgetsFlutterBinding.ensureInitialized();
///   await configureDependencies();
///   runApp(const MyApp());
/// }
/// ```
///
/// Note on BLoCs and GetIt: only BLoCs with no route-time/runtime-only
/// constructor arguments are registered here (e.g. [DiaryListBloc],
/// [DiaryViewBloc] — both only need dependencies GetIt already knows how
/// to build; `DiaryViewBloc` takes its target entry's id via an event,
/// not the constructor). `DiaryFormBloc` and any other BLoC that needs a
/// value only known at navigation time (like an entry being edited) is
/// intentionally NOT registered in GetIt — it's constructed directly
/// where it's used (see `DiaryFormPage`'s `BlocProvider.create`), pulling
/// only its *actual* dependencies (the use cases) from `getIt`. This
/// avoids fighting GetIt's generic-type constraints for optional/
/// nullable runtime parameters.
Future<void> configureDependencies() async {
  await _registerCoreServices();
  _registerDataSources();
  _registerRepositories();
  _registerUseCases();
  _registerBlocs();
}

/// Core, app-wide services with no dependencies of their own.
Future<void> _registerCoreServices() async {
  getIt.registerLazySingleton<LoggerService>(() => LoggerService());

  final database = await _openDatabase();
  getIt.registerSingleton<Database>(database);
}

/// Opens (creating if necessary) the app's sqflite database.
///
/// Creates the `diary_entries` table on first run. Later milestones that
/// add columns should extend this via `onUpgrade` with a bumped
/// `version`, rather than editing `onCreate` in place, so existing
/// installs migrate correctly instead of just matching what a fresh
/// install would get.
Future<Database> _openDatabase() async {
  final databasesPath = await getDatabasesPath();
  final path = p.join(databasesPath, 'diary.db');

  return openDatabase(
    path,
    version: 3, // bumped from 2
    onCreate: (db, version) async {
      await db.execute('''
        CREATE TABLE diary_entries (
          id TEXT PRIMARY KEY,
          title TEXT NOT NULL,
          content TEXT NOT NULL,
          date TEXT NOT NULL,
          created_at TEXT NOT NULL,
          updated_at TEXT NOT NULL,
          mood TEXT
        )
      ''');
      await _createThemeTables(db);
    },
    onUpgrade: (db, oldVersion, newVersion) async {
      if (oldVersion < 2) {
        await db.execute('ALTER TABLE diary_entries ADD COLUMN mood TEXT');
      }
      if (oldVersion < 3) {
        await _createThemeTables(db);
      }
    },
  );
}

/// Creates the two tables backing the theme feature (Milestone 3):
/// `custom_themes` for user-created themes, and the generic key-value
/// `app_settings` table (currently only storing `selected_theme_id`, see
/// `ThemeLocalDataSource`, but named generically since future settings
/// can reuse it rather than each spawning their own single-purpose
/// table). `IF NOT EXISTS` guards both `onCreate` (fresh install) and
/// `onUpgrade` (existing install) calling this from the same place
/// without needing separate duplicated CREATE statements.
Future<void> _createThemeTables(Database db) async {
  await db.execute('''
    CREATE TABLE IF NOT EXISTS custom_themes (
      id TEXT PRIMARY KEY,
      name TEXT NOT NULL,
      primary_color INTEGER NOT NULL,
      background_color INTEGER NOT NULL,
      accent_color INTEGER NOT NULL,
      header_image_path TEXT
    )
  ''');
  await db.execute('''
    CREATE TABLE IF NOT EXISTS app_settings (
      key TEXT PRIMARY KEY,
      value TEXT NOT NULL
    )
  ''');
}

/// Dummy service to prove the manual-registration pattern.
///
/// Placeholder — a real logging solution (or a wrapper around one) will
/// likely replace this in a later milestone.
class LoggerService {
  void log(String message) {
    // ignore: avoid_print
    print('[LoggerService] $message');
  }

  void logError(String message, [Object? error, StackTrace? stackTrace]) {
    // ignore: avoid_print
    print('[LoggerService] ERROR: $message${error != null ? ' — $error' : ''}');
  }
}

/// Data sources — the layer directly touching sqflite.
void _registerDataSources() {
  getIt.registerLazySingleton<DiaryLocalDataSource>(
    () => DiaryLocalDataSourceImpl(getIt<Database>()),
  );
  getIt.registerLazySingleton<ThemeLocalDataSource>(
    () => ThemeLocalDataSourceImpl(getIt<Database>()),
  );
}

/// Repositories — translate data-source exceptions into `Either<Failure, T>`.
void _registerRepositories() {
  getIt.registerLazySingleton<DiaryRepository>(
    () => DiaryRepositoryImpl(getIt<DiaryLocalDataSource>()),
  );
  getIt.registerLazySingleton<ThemeRepository>(
    () => ThemeRepositoryImpl(getIt<ThemeLocalDataSource>()),
  );
}

/// Use cases — one per domain operation, each a thin callable wrapper
/// around a [DiaryRepository] method.
void _registerUseCases() {
  getIt.registerLazySingleton(() => CreateDiaryEntry(getIt<DiaryRepository>()));
  getIt.registerLazySingleton(
    () => GetAllDiaryEntries(getIt<DiaryRepository>()),
  );
  getIt.registerLazySingleton(
    () => GetDiaryEntryById(getIt<DiaryRepository>()),
  );
  getIt.registerLazySingleton(() => UpdateDiaryEntry(getIt<DiaryRepository>()));
  getIt.registerLazySingleton(() => DeleteDiaryEntry(getIt<DiaryRepository>()));

  getIt.registerLazySingleton(() => GetAllThemes(getIt<ThemeRepository>()));
  getIt.registerLazySingleton(() => GetSelectedTheme(getIt<ThemeRepository>()));
  getIt.registerLazySingleton(() => SelectTheme(getIt<ThemeRepository>()));
  getIt.registerLazySingleton(() => SaveCustomTheme(getIt<ThemeRepository>()));
  getIt.registerLazySingleton(() => DeleteCustomTheme(getIt<ThemeRepository>()));
}

/// BLoCs — registered as factories (not singletons), since each screen
/// visit should get a fresh BLoC instance rather than reusing state from a
/// previous visit.
///
/// Only BLoCs with no runtime-only constructor params live here.
/// `DiaryFormBloc` is deliberately absent — see the note on
/// [configureDependencies] above. `CustomThemeFormBloc` is absent for the
/// same reason: it takes an optional `existingTheme` known only at
/// navigation time, so it's constructed directly in
/// `CustomThemeScreen`'s `BlocProvider.create`, pulling only its actual
/// dependency ([SaveCustomTheme]) from `getIt`.
///
/// [AppThemeCubit] is the one exception to "factory, not singleton" — it
/// must persist for the app's entire lifetime and sits in exactly one
/// `BlocProvider` at the root of the widget tree (see `main.dart`), so a
/// `registerLazySingleton` is correct here, not a factory.
void _registerBlocs() {
  getIt.registerFactory<DiaryListBloc>(
    () => DiaryListBloc(getIt<GetAllDiaryEntries>()),
  );
  getIt.registerFactory<DiaryViewBloc>(
    () => DiaryViewBloc(getIt<GetDiaryEntryById>()),
  );

  getIt.registerFactory<ThemeListBloc>(
    () => ThemeListBloc(getAllThemes: getIt<GetAllThemes>()),
  );

  getIt.registerLazySingleton<AppThemeCubit>(
    () => AppThemeCubit(
      getSelectedTheme: getIt<GetSelectedTheme>(),
      selectTheme: getIt<SelectTheme>(),
    ),
  );
}