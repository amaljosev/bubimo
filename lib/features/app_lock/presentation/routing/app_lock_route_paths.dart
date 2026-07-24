// lib/features/app_lock/presentation/routing/app_lock_route_paths.dart

/// Route path constants for the app_lock feature, defined here (inside
/// the feature) rather than only inside AppRoutes in app_router.dart —
/// app_lock_settings_page.dart needs these paths to push to, and it
/// can't import app_router.dart for them without creating a circular
/// import (app_router.dart already imports the app_lock pages).
///
/// AppRoutes in lib/core/router/app_router.dart re-exposes the same
/// values (see its appLockSettings / appLockPinCreate /
/// appLockSecurityQuestionSetup constants) for consistency with how
/// every other feature's routes are referenced elsewhere in the app —
/// keep both in sync if you ever rename one.
class AppLockRoutePaths {
  const AppLockRoutePaths._();

  static const settings = '/settings/app-lock';
  static const pinCreate = '/settings/app-lock/pin-create';
  static const securityQuestionSetup = '/settings/app-lock/security-question-setup';

  /// Root-level paths for the lock gate + its verify screens — these
  /// are what `lockRedirect` (see lock_redirect.dart) sends navigation
  /// to when the app is locked, and are exempted from that same
  /// redirect so the user can actually reach them.
  static const lockGate = '/lock';
  static const pinVerify = '/lock/pin';
  static const securityQuestionVerify = '/lock/security-question';
}
