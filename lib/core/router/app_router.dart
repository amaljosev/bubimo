// lib/core/router/app_router.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../features/diary_entry/presentation/pages/diary_entry_view_page.dart';
import '../../features/diary_entry/presentation/pages/diary_form_page.dart';
import '../../features/favorites/presentation/pages/favorites_page.dart';
import '../../features/home/presentation/bloc/diary_list/diary_list_bloc.dart';
import '../../features/reminders/presentation/bloc/reminder_settings/reminder_settings_bloc.dart';
import '../../features/reminders/presentation/bloc/reminder_settings/reminder_settings_event.dart';
import '../../features/reminders/presentation/pages/reminder_settings_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/theme/presentation/pages/custom_theme_screen.dart';
import '../di/injection.dart';
import '../navigation/main_shell.dart';

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

  // NOTE: Timeline, Favorites, Diary, Themes, and Profile are the five
  // bottom-navigation tabs (reached via '/', inside MainShell) — none of
  // them are pushed routes on their own. Favorites is the one exception
  // worth calling out: it's ALSO reachable as a pushed route
  // (AppRoutes.favorites, above) from the favorite-count pill on
  // Timeline's header, independent of switching bottom-nav tabs. Both
  // paths land on the same FavoritesPage/shared DiaryListBloc.
  //
  // Profile & Analytics is now a single combined tab (ProfileAnalyticsScreen,
  // rendered by MainShell) rather than a separate pushed screen — there is
  // no AppRoutes.analytics / AppRoutes.profile anymore. Anywhere that used
  // to push one of those should instead switch to the Profile tab (e.g.
  // context.go(AppRoutes.home) plus the shell's own tab index, or simply
  // rely on the bottom nav) rather than pushing a route.
  //
  // Settings used to be a tab; it's now reached only by pushing from
  // Profile (via its AppBar gear icon) — hence its own pushable route
  // here rather than a tab index.
}

/// App-wide router. Add new routes here as each milestone introduces new
/// screens — this file is updated incrementally, never regenerated from
/// scratch, so existing routes/behavior are preserved.
///
/// Diary Lock, Backup & Restore, Import & Export, Search, Onboarding,
/// and Settings Hub routes are intentionally not yet added — those
/// features haven't been generated yet.
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
      builder: (context, state) => const CustomThemeScreen(),
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
      // FavoritesPage reads the same shared DiaryListBloc singleton
      // Diary/Timeline use. Same ancestor-reachability note as above —
      // provided explicitly here since this route isn't nested under
      // MainShell's tree.
      builder: (context, state) =>
          BlocProvider.value(value: getIt<DiaryListBloc>(), child: const FavoritesPage()),
    ),
  ],
);