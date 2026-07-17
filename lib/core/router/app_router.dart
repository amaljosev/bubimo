// lib/core/router/app_router.dart

import 'package:bubimo/core/di/injection.dart';
import 'package:bubimo/core/navigation/main_shell.dart';
import 'package:bubimo/features/app_lock/presentation/bloc/settings_bloc/app_lock_settings_bloc.dart';
import 'package:bubimo/features/app_lock/presentation/pages/app_lock_listing_screen.dart';
import 'package:bubimo/features/app_lock/presentation/pages/biometric_setup_screen.dart';
import 'package:bubimo/features/app_lock/presentation/pages/device_credential_setup_screen.dart';
import 'package:bubimo/features/app_lock/presentation/pages/pattern_setup_screen.dart';
import 'package:bubimo/features/app_lock/presentation/pages/pin_setup_screen.dart';
import 'package:bubimo/features/app_lock/presentation/pages/security_question_recovery_screen.dart';
import 'package:bubimo/features/app_lock/presentation/pages/security_question_setup_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
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

  // App Lock — listing/settings screen plus one setup route per lock
  // method, and the security question setup step every method's
  // successful setup routes into. The runtime lock gate
  // (LockGateScreen) is intentionally NOT one of these routes — it
  // needs to intercept app launch/resume before any other screen is
  // visible, so it's inserted above GoRouter entirely rather than
  // pushed as a normal route. See lock_gate_screen.dart's doc comment
  // for the integration point.
  static const String lockListing = '/app-lock';
  static const String setupPin = '/app-lock/setup/pin';
  static const String setupPattern = '/app-lock/setup/pattern';
  static const String setupBiometric = '/app-lock/setup/biometric';
  static const String setupDeviceCredential =
      '/app-lock/setup/device-credential';
  static const String setupSecurityQuestion =
      '/app-lock/setup/security-question';

  // NOTE: Timeline, Diary, Themes, and Profile are the four
  // bottom-navigation tabs (reached via '/', inside MainShell) — none of
  // them are pushed routes on their own. Favorites is NOT a tab anymore;
  // it's reachable only as a pushed route (AppRoutes.favorites, above)
  // from the favorite-count pill on Timeline's header. That pushed route
  // still lands on the same FavoritesPage/shared DiaryListBloc as
  // before — only its bottom-nav entry was removed.
  //
  // Profile & Analytics is now a single combined tab (ProfileAnalyticsScreen,
  // rendered by MainShell) rather than a separate pushed screen — there is
  // no AppRoutes.analytics / AppRoutes.profile anymore. Anywhere that used
  // to push one of those should instead switch to the Profile tab (e.g.
  // context.go(AppRoutes.home) plus the shell's own tab index, or simply
  // rely on the bottom nav) rather than pushing a route.
  //
  // Settings used to be a tab; it's now reached only by pushing from
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
      path: AppRoutes.lockListing,
      // AppLockSettingsBloc is a factory (see injection.dart) — each
      // visit gets a fresh instance, mirroring AppRoutes.favorites and
      // AppRoutes.reminderSettings below.
      builder: (context, state) => BlocProvider(
        create: (_) => getIt<AppLockSettingsBloc>()
          ..add(const LoadLockSettings()),
        child: const AppLockListingScreen(),
      ),
    ),
    GoRoute(
      path: AppRoutes.setupPin,
      builder: (context, state) => const PinSetupScreen(),
    ),
    GoRoute(
      path: AppRoutes.setupPattern,
      builder: (context, state) => const PatternSetupScreen(),
    ),
    GoRoute(
      path: AppRoutes.setupBiometric,
      builder: (context, state) => const BiometricSetupScreen(),
    ),
    GoRoute(
      path: AppRoutes.setupDeviceCredential,
      builder: (context, state) => const DeviceCredentialSetupScreen(),
    ),
    GoRoute(
      path: AppRoutes.setupSecurityQuestion,
      builder: (context, state) => const SecurityQuestionSetupScreen(),
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

  ],
);