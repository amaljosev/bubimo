// lib/core/router/app_router.dart

import 'package:go_router/go_router.dart';

import '../../features/diary_entry/presentation/pages/diary_entry_view_page.dart';
import '../../features/diary_entry/presentation/pages/diary_form_page.dart';
import '../../features/theme/presentation/pages/custom_theme_screen.dart';
import '../navigation/main_shell.dart';

/// Centralized route path constants. Use these instead of raw strings
/// when navigating, to avoid typos and make renames a one-line change.
class AppRoutes {
  AppRoutes._();

  static const String home = '/';
  static const String diaryForm = '/diary-form';
  static const String diaryView = '/diary-view';
  static const String customThemeScreen = '/theme/custom';

  // NOTE: Themes, Analytics, and Reminders no longer have standalone
  // top-level routes. As of the bottom-navigation shell, they're tabs
  // inside MainShell (reached via '/'), not pushed routes. If a future
  // feature needs to deep-link directly into one of those tabs (e.g. a
  // notification opening Reminders), reintroduce a route here that
  // navigates to '/' and passes the target tab index via `extra`.
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
  ],
);