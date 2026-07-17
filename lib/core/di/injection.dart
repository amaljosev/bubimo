// lib/core/di/injection.dart

import 'package:bubimo/features/home/presentation/bloc/diary_list/diary_list_bloc.dart';
import 'package:bubimo/features/theme/data/datasources/theme_local_data_source.dart';
import 'package:bubimo/features/theme/data/repositories/theme_repository_impl.dart';
import 'package:bubimo/features/theme/domain/usecases/reset_to_default_theme.dart';
import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../database/app_database.dart';

// diary_entry
import '../../features/diary_entry/data/datasources/diary_local_data_source.dart';
import '../../features/diary_entry/data/repositories/diary_repository_impl.dart';
import '../../features/diary_entry/domain/repositories/diary_repository.dart';
import '../../features/diary_entry/domain/usecases/create_diary_entry.dart';
import '../../features/diary_entry/domain/usecases/delete_diary_entry.dart';
import '../../features/diary_entry/domain/usecases/get_all_diary_entries.dart';
import '../../features/diary_entry/domain/usecases/get_diary_entry_by_id.dart';
import '../../features/diary_entry/domain/usecases/update_diary_entry.dart';
import '../../features/diary_entry/presentation/bloc/diary_form/diary_form_bloc.dart';

// diary_entry (stickers)
import '../../features/diary_entry/data/datasources/supabase_sticker_data_source.dart';
import '../../features/diary_entry/data/repositories/sticker_repository_impl.dart';
import '../../features/diary_entry/domain/repositories/sticker_repository.dart';
import '../../features/diary_entry/presentation/bloc/sticker_picker/sticker_picker_bloc.dart';


import '../../features/theme/domain/repositories/theme_repository.dart';
import '../../features/theme/domain/usecases/delete_custom_theme.dart';
import '../../features/theme/domain/usecases/get_all_themes.dart';
import '../../features/theme/domain/usecases/get_selected_theme.dart';
import '../../features/theme/domain/usecases/save_custom_theme.dart';
import '../../features/theme/domain/usecases/select_theme.dart';
import '../../features/theme/presentation/bloc/custom_theme_form/custom_theme_form_bloc.dart';
import '../../features/theme/presentation/bloc/theme_list/theme_list_bloc.dart';
import '../../features/theme/presentation/cubit/app_theme_cubit.dart';

// analytics
import '../../features/profile/domain/usecases/analytics_usecases/get_analytics_snapshot.dart';
import '../../features/profile/domain/usecases/analytics_usecases/get_current_streak.dart';
import '../../features/profile/domain/usecases/analytics_usecases/get_entry_stats.dart';
import '../../features/profile/domain/usecases/analytics_usecases/get_heatmap_data.dart';
import '../../features/profile/domain/usecases/analytics_usecases/get_longest_streak.dart';
import '../../features/profile/domain/usecases/analytics_usecases/get_mood_counts.dart';
import '../../features/profile/domain/usecases/analytics_usecases/get_word_count_trend.dart';
import '../../features/profile/presentation/bloc/analytics_bloc.dart';

// profile
import '../../features/profile/data/datasources/profile_local_data_source.dart';
import '../../features/profile/data/repositories/profile_repository_impl.dart';
import '../../features/profile/domain/repositories/profile_repository.dart';
import '../../features/profile/domain/usecases/get_user_profile.dart';
import '../../features/profile/domain/usecases/update_user_profile.dart';
import '../../features/profile/presentation/cubit/profile_cubit.dart';

// backgrounds
import '../../features/backgrounds/data/datasources/supabase_background_data_source.dart';
import '../../features/backgrounds/presentation/bloc/background_picker/background_picker_bloc.dart';
import '../services/supabase_storage_asset_service.dart';

// rich_editor (remote stickers)

// reminders
import '../../features/reminders/data/datasources/local_notification_service.dart';
import '../../features/reminders/domain/usecases/cancel_reminder.dart';
import '../../features/reminders/domain/usecases/get_reminder_settings.dart';
import '../../features/reminders/domain/usecases/set_reminder.dart';
import '../../features/reminders/presentation/bloc/reminder_settings/reminder_settings_bloc.dart';

// app_lock
import 'package:local_auth/local_auth.dart';
import '../../features/app_lock/data/datasources/app_lock_local_datasource.dart';
import '../../features/app_lock/data/repositories/app_lock_repository_impl.dart';
import '../../features/app_lock/domain/repositories/app_lock_repository.dart';
import '../../features/app_lock/domain/usecases/authenticate_biometric.dart';
import '../../features/app_lock/domain/usecases/disable_lock.dart';
import '../../features/app_lock/domain/usecases/get_lock_settings.dart';
import '../../features/app_lock/domain/usecases/set_lock_method.dart';
import '../../features/app_lock/domain/usecases/set_pattern.dart';
import '../../features/app_lock/domain/usecases/set_pin.dart';
import '../../features/app_lock/domain/usecases/set_security_question.dart';
import '../../features/app_lock/domain/usecases/verify_pattern.dart';
import '../../features/app_lock/domain/usecases/verify_pin.dart';
import '../../features/app_lock/domain/usecases/verify_security_answer.dart';
import '../../features/app_lock/domain/entities/lock_method.dart';
import '../../features/app_lock/presentation/bloc/settings_bloc/app_lock_settings_bloc.dart';
import '../../features/app_lock/presentation/bloc/setup_bloc/lock_setup_bloc.dart';
import '../../features/app_lock/presentation/bloc/lock_gate_bloc/lock_gate_bloc.dart';

final GetIt getIt = GetIt.instance;

/// Registers every dependency the app needs, using manual GetIt
/// registration (no build_runner / injectable codegen).
///
/// Call this once, before `runApp` — see `main.dart`. Assumes
/// `Supabase.initialize(...)` has already run before this is called,
/// since the backgrounds feature registers a `SupabaseClient` here.
///
/// This file is updated incrementally as each milestone adds new
/// datasources, repositories, use cases, and blocs/cubits — never
/// regenerated from scratch. New registrations are always added AFTER
/// the bloc/use case classes they reference already exist.
Future<void> configureDependencies() async {
  // --- Core ---
  getIt.registerLazySingleton<AppDatabase>(() => AppDatabase());

  // Ensure the database is opened before any feature tries to use it.
  await getIt<AppDatabase>().database;

  // --- diary_entry ---
  getIt.registerLazySingleton<DiaryLocalDataSource>(
    () => DiaryLocalDataSourceImpl(getIt<AppDatabase>()),
  );
  getIt.registerLazySingleton<DiaryRepository>(
    () => DiaryRepositoryImpl(getIt<DiaryLocalDataSource>()),
  );
  getIt.registerLazySingleton(() => CreateDiaryEntry(getIt<DiaryRepository>()));
  getIt.registerLazySingleton(
    () => GetAllDiaryEntries(getIt<DiaryRepository>()),
  );
  getIt.registerLazySingleton(
    () => GetDiaryEntryById(getIt<DiaryRepository>()),
  );
  getIt.registerLazySingleton(() => UpdateDiaryEntry(getIt<DiaryRepository>()));
  getIt.registerLazySingleton(() => DeleteDiaryEntry(getIt<DiaryRepository>()));

  getIt.registerFactory(
    () => DiaryFormBloc(
      createDiaryEntry: getIt<CreateDiaryEntry>(),
      updateDiaryEntry: getIt<UpdateDiaryEntry>(),
      getDiaryEntryById: getIt<GetDiaryEntryById>(),
    ),
  );

  // --- diary_entry (stickers) ---
  // Assumes Supabase.initialize(...) has already run in main(). The
  // SupabaseClient singleton is registered once here and reused by the
  // backgrounds feature below — registration order doesn't matter for
  // lazy singletons (resolved on first use), but it's registered here
  // since stickers are the first section that needs it.
  getIt.registerLazySingleton<SupabaseClient>(() => Supabase.instance.client);
  getIt.registerLazySingleton(
    () => SupabaseStickerDataSource(getIt<SupabaseClient>()),
  );
  getIt.registerLazySingleton<StickerRepository>(
    () => StickerRepositoryImpl(getIt<SupabaseStickerDataSource>()),
  );
  // Factory (not singleton) — a fresh StickerPickerBloc is created each
  // time the picker sheet opens, mirroring BackgroundPickerBloc.
  getIt.registerFactory(
    () => StickerPickerBloc(stickerRepository: getIt<StickerRepository>()),
  );

  // --- home ---
  getIt.registerFactory(
    () => DiaryListBloc(getAllDiaryEntries: getIt<GetAllDiaryEntries>()),
  );

  // --- theme ---
  getIt.registerLazySingleton<ThemeLocalDataSource>(
    () => ThemeLocalDataSourceImpl(getIt<AppDatabase>()),
  );
  getIt.registerLazySingleton<ThemeRepository>(
    () => ThemeRepositoryImpl(getIt<ThemeLocalDataSource>()),
  );
  getIt.registerLazySingleton(() => GetAllThemes(getIt<ThemeRepository>()));
  getIt.registerLazySingleton(
    () => GetSelectedTheme(getIt<ThemeRepository>()),
  );
  getIt.registerLazySingleton(() => SelectTheme(getIt<ThemeRepository>()));
  getIt.registerLazySingleton(
    () => ResetToDefaultTheme(getIt<ThemeRepository>()),
  );
  getIt.registerLazySingleton(
    () => SaveCustomTheme(getIt<ThemeRepository>()),
  );
  getIt.registerLazySingleton(
    () => DeleteCustomTheme(getIt<ThemeRepository>()),
  );

  // AppThemeCubit is a lazy singleton (not a factory) — it must persist
  // for the app's entire lifetime since it drives MaterialApp's theme.
  getIt.registerLazySingleton(
    () => AppThemeCubit(
      getSelectedTheme: getIt<GetSelectedTheme>(),
      selectTheme: getIt<SelectTheme>(),
      resetToDefaultTheme: getIt<ResetToDefaultTheme>(),
    ),
  );

  getIt.registerFactory(
    () => ThemeListBloc(
      getAllThemes: getIt<GetAllThemes>(),
      getSelectedTheme: getIt<GetSelectedTheme>(),
      deleteCustomTheme: getIt<DeleteCustomTheme>(),
      appThemeCubit: getIt<AppThemeCubit>(),
    ),
  );
  getIt.registerFactory(
    () => CustomThemeFormBloc(
      saveCustomTheme: getIt<SaveCustomTheme>(),
      appThemeCubit: getIt<AppThemeCubit>(),
    ),
  );

  // --- analytics ---
  // Individual per-metric use cases are still registered (kept as thin
  // wrappers around shared pure calculation functions — see each
  // Get*'s doc comment) for any call site or test that wants just one
  // metric. AnalyticsBloc itself depends only on GetAnalyticsSnapshot,
  // which does a SINGLE getAllDiaryEntries() fetch and derives every
  // metric from that one result, instead of the previous pattern of 5
  // independent use cases each re-fetching every entry from scratch.
  getIt.registerLazySingleton(
    () => GetMoodCounts(getIt<GetAllDiaryEntries>()),
  );
  getIt.registerLazySingleton(
    () => GetCurrentStreak(getIt<GetAllDiaryEntries>()),
  );
  getIt.registerLazySingleton(
    () => GetLongestStreak(getIt<GetAllDiaryEntries>()),
  );
  getIt.registerLazySingleton(
    () => GetHeatmapData(getIt<GetAllDiaryEntries>()),
  );
  getIt.registerLazySingleton(
    () => GetEntryStats(getIt<GetAllDiaryEntries>()),
  );
  getIt.registerLazySingleton(
    () => GetWordCountTrend(getIt<GetAllDiaryEntries>()),
  );
  getIt.registerLazySingleton(
    () => GetAnalyticsSnapshot(getIt<GetAllDiaryEntries>()),
  );

  getIt.registerFactory(
    () => AnalyticsBloc(
      getAnalyticsSnapshot: getIt<GetAnalyticsSnapshot>(),
    ),
  );

  // --- profile ---
  // Backs the combined Profile & Analytics screen's profile section
  // (photo, username, diary name, header image). AnalyticsBloc above
  // is reused as-is for that screen's analytics section.
  getIt.registerLazySingleton<ProfileLocalDataSource>(
    () => ProfileLocalDataSourceImpl(getIt<AppDatabase>()),
  );
  getIt.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(getIt<ProfileLocalDataSource>()),
  );
  getIt.registerLazySingleton(() => GetUserProfile(getIt<ProfileRepository>()));
  getIt.registerLazySingleton(
    () => UpdateUserProfile(getIt<ProfileRepository>()),
  );

  getIt.registerFactory(
    () => ProfileCubit(
      getUserProfile: getIt<GetUserProfile>(),
      updateUserProfile: getIt<UpdateUserProfile>(),
    ),
  );

  // --- backgrounds ---
  // SupabaseClient is registered above (diary_entry stickers section).
  getIt.registerLazySingleton(
    () => SupabaseStorageAssetService(getIt<SupabaseClient>()),
  );
  getIt.registerLazySingleton(
    () => SupabaseBackgroundDataSource(getIt<SupabaseStorageAssetService>()),
  );
  getIt.registerFactory(
    () => BackgroundPickerBloc(
      remoteDataSource: getIt<SupabaseBackgroundDataSource>(),
    ),
  );



  // --- reminders ---
  getIt.registerLazySingleton(
    () => LocalNotificationService(getIt<AppDatabase>()),
  );
  getIt.registerLazySingleton(
    () => GetReminderSettings(getIt<LocalNotificationService>()),
  );
  getIt.registerLazySingleton(
    () => SetReminder(getIt<LocalNotificationService>()),
  );
  getIt.registerLazySingleton(
    () => CancelReminder(getIt<LocalNotificationService>()),
  );

  getIt.registerFactory(
    () => ReminderSettingsBloc(
      getReminderSettings: getIt<GetReminderSettings>(),
      setReminder: getIt<SetReminder>(),
      cancelReminder: getIt<CancelReminder>(),
    ),
  );

  // --- app_lock ---
  if (!getIt.isRegistered<LocalAuthentication>()) {
    getIt.registerLazySingleton<LocalAuthentication>(
      () => LocalAuthentication(),
    );
  }

  getIt.registerLazySingleton<AppLockLocalDataSource>(
    () => AppLockLocalDataSource(
      appDatabase: getIt<AppDatabase>(),
      localAuth: getIt<LocalAuthentication>(),
    ),
  );
  getIt.registerLazySingleton<AppLockRepository>(
    () => AppLockRepositoryImpl(getIt<AppLockLocalDataSource>()),
  );

  getIt.registerLazySingleton(() => GetLockSettings(getIt<AppLockRepository>()));
  getIt.registerLazySingleton(() => SetLockMethod(getIt<AppLockRepository>()));
  getIt.registerLazySingleton(() => DisableLock(getIt<AppLockRepository>()));
  getIt.registerLazySingleton(() => SetPin(getIt<AppLockRepository>()));
  getIt.registerLazySingleton(() => VerifyPin(getIt<AppLockRepository>()));
  getIt.registerLazySingleton(() => SetPattern(getIt<AppLockRepository>()));
  getIt.registerLazySingleton(
    () => VerifyPattern(getIt<AppLockRepository>()),
  );
  getIt.registerLazySingleton(
    () => AuthenticateBiometric(getIt<AppLockRepository>()),
  );
  getIt.registerLazySingleton(
    () => SetSecurityQuestion(getIt<AppLockRepository>()),
  );
  getIt.registerLazySingleton(
    () => VerifySecurityAnswer(getIt<AppLockRepository>()),
  );

  getIt.registerFactory(
    () => AppLockSettingsBloc(
      getLockSettings: getIt<GetLockSettings>(),
      setLockMethod: getIt<SetLockMethod>(),
      disableLock: getIt<DisableLock>(),
      repository: getIt<AppLockRepository>(),
    ),
  );

  // LockSetupBloc needs a LockMethod param at creation time (shared
  // across PIN/Pattern/SecurityQuestion setup pages) — registered
  // with registerFactoryParam so callers do
  // `getIt<LockSetupBloc>(param1: LockMethod.pin)`.
  getIt.registerFactoryParam<LockSetupBloc, LockMethod, void>(
    (method, _) => LockSetupBloc(
      method: method,
      setPin: getIt<SetPin>(),
      setPattern: getIt<SetPattern>(),
      setSecurityQuestion: getIt<SetSecurityQuestion>(),
    ),
  );

  getIt.registerFactory(
    () => LockGateBloc(
      getLockSettings: getIt<GetLockSettings>(),
      verifyPin: getIt<VerifyPin>(),
      verifyPattern: getIt<VerifyPattern>(),
      authenticateBiometric: getIt<AuthenticateBiometric>(),
      verifySecurityAnswer: getIt<VerifySecurityAnswer>(),
    ),
  );

  // --- Feature registrations go above this line, added milestone by ---
  // --- milestone, grouped by feature with a comment header each time. ---
}