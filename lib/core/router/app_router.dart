// lib/core/router/app_router.dart

import 'package:bubimo/features/diary_entry/presentation/pages/home_page.dart';
import 'package:go_router/go_router.dart';

import '../../features/analytics/presentation/pages/analytics_screen.dart';
import '../../features/diary_entry/presentation/pages/diary_entry_view_page.dart';
import '../../features/diary_entry/presentation/pages/diary_form_page.dart';
import '../../features/reminders/presentation/pages/reminder_settings_page.dart';
import '../../features/theme/presentation/pages/custom_theme_screen.dart';
import '../../features/theme/presentation/pages/theme_screen.dart';

/// Centralized route path constants. Use these instead of raw strings
/// when navigating, to avoid typos and make renames a one-line change.
class AppRoutes {
  AppRoutes._();

  static const String home = '/';
  static const String diaryForm = '/diary-form';
  static const String diaryView = '/diary-view';
  static const String themeScreen = '/theme';
  static const String customThemeScreen = '/theme/custom';
  static const String analyticsScreen = '/analytics';
  static const String reminderSettings = '/reminders';
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
      builder: (context, state) => const HomePage(),
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
      path: AppRoutes.themeScreen,
      builder: (context, state) => const ThemeScreen(),
    ),
    GoRoute(
      path: AppRoutes.customThemeScreen,
      builder: (context, state) => const CustomThemeScreen(),
    ),
    GoRoute(
      path: AppRoutes.analyticsScreen,
      builder: (context, state) => const AnalyticsScreen(),
    ),
    GoRoute(
      path: AppRoutes.reminderSettings,
      builder: (context, state) => const ReminderSettingsPage(),
    ),
  ],
);