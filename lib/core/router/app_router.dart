// lib/core/router/app_router.dart

import 'package:bubimo/core/di/injection.dart';
import 'package:bubimo/core/navigation/main_shell.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../features/backup/presentation/pages/backup_restore_page.dart';
import '../../../features/diary_entry/presentation/pages/diary_entry_view_page.dart';
import '../../../features/diary_entry/presentation/pages/diary_form_page.dart';
import '../../../features/favorites/presentation/pages/favorites_page.dart';
import '../../../features/home/presentation/bloc/diary_list/diary_list_bloc.dart';
import '../../../features/home/presentation/bloc/diary_list/diary_list_event.dart';
import '../../../features/reminders/presentation/bloc/reminder_settings/reminder_settings_bloc.dart';
import '../../../features/reminders/presentation/bloc/reminder_settings/reminder_settings_event.dart';
import '../../../features/reminders/presentation/pages/reminder_settings_page.dart';
import '../../../features/settings/presentation/pages/settings_page.dart';
import '../../../features/theme/domain/entities/app_theme_data.dart';
import '../../../features/theme/presentation/pages/custom_theme_screen.dart';


/// Centralized route path constants. Use these instead of raw strings
/// when navigating, to avoid typos and make renames a one-line change.
class AppRoutes {
  AppRoutes._();

  static const String home = '/';
  static const String diaryForm = '/diary-form';
  static const String diaryView = '/diary-view';
  static const String customThemeScreen = '/theme/custom';
  static const String reminderSettings = '/settings/reminders';
  static const String settings = '/settings';
  static const String favorites = '/favorites';
  static const String importExport = '/import-export';
}
final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.home,
  routes: [
    GoRoute(
      path: AppRoutes.home,
      builder: (context, state) => const MainShell(),
    ),
    
    GoRoute(
      path: AppRoutes.diaryForm,
      builder: (context, state) {
        // Pass an existing entry id via `extra` to open in edit mode;
        // omit it (or pass null) to open in create mode.
        final entryId = state.extra as String?;
        return DiaryFormPage(entryId: entryId);
      },
    ),
    GoRoute(
      path: AppRoutes.diaryView,
      builder: (context, state) {
        final entryId = state.extra as String;
        return DiaryEntryViewPage(entryId: entryId);
      },
    ),
    GoRoute(
      path: AppRoutes.customThemeScreen,
      // `extra` carries the AppThemeData to edit when navigating here
      // to EDIT an existing custom theme; omit it (push with no extra)
      // to open in create mode. See CustomThemeScreen's `existingTheme`
      // param.
      builder: (context, state) {
        final existingTheme = state.extra as AppThemeData?;
        return CustomThemeScreen(existingTheme: existingTheme);
      },
    ),
    GoRoute(
      path: AppRoutes.reminderSettings,
      // ReminderSettingsBloc is a lazySingleton (was previously provided
      // by MainShell when Reminders was a tab). Now that it's reached
      // via a pushed route from Settings instead, this route provides
      // it directly — re-dispatching LoadReminderSettings on each visit
      // since the page is no longer kept alive in an IndexedStack.
      builder: (context, state) => BlocProvider.value(
        value: getIt<ReminderSettingsBloc>()..add(const LoadReminderSettings()),
        child: const ReminderSettingsPage(),
      ),
    ),
    GoRoute(
      path: AppRoutes.settings,
      builder: (context, state) => const SettingsPage(),
    ),
    GoRoute(
      path: AppRoutes.favorites,
      // DiaryListBloc is registered as a FACTORY (see injection.dart),
      // not a singleton — so `getIt<DiaryListBloc>()` here always
      // builds a brand-new instance, starting at
      // DiaryListStatus.initial, completely independent from whatever
      // instance MainShell's Diary/Timeline tabs are using. FavoritesPage
      // itself never dispatches an initial load (it only reacts to
      // pull-to-refresh / returning from create-edit), so without the
      // explicit `..add(...)` here this screen would sit on its loading
      // spinner forever. Mirrors the same pattern already used just
      // above for AppRoutes.reminderSettings.
      builder: (context, state) => BlocProvider.value(
        value: getIt<DiaryListBloc>()..add(const LoadDiaryEntries()),
        child: const FavoritesPage(),
      ),
    ),
    GoRoute(
      path: AppRoutes.importExport,
      // BackupRestorePage provides its own BackupBloc internally (via
      // getIt, registered as a factory) rather than this route
      // providing it — unlike AppRoutes.favorites/reminderSettings
      // above, there's no initial data load to dispatch here; the bloc
      // starts at BackupStatus.idle and only does anything once the
      // user taps Export or picks an import file.
      builder: (context, state) => const BackupRestorePage(),
    ),

  ],
);