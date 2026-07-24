// lib/features/app_lock/presentation/routing/lock_redirect.dart

import 'package:go_router/go_router.dart';
import '../../domain/entities/lock_type.dart';
import '../bloc/lock_bloc.dart';
import 'app_lock_route_paths.dart';

/// Paths that must never themselves be redirected away from — the
/// lock-gate route and the verify screens it can show, plus the setup
/// screens the settings page pushes to (a user actively re-configuring
/// their lock shouldn't get bounced mid-setup if e.g. `LockApp` fires
/// from an app-lifecycle pause while they're on the PIN-create screen).
const _exemptPaths = <String>{
  AppLockRoutePaths.lockGate,
  AppLockRoutePaths.pinVerify,
  AppLockRoutePaths.securityQuestionVerify,
  AppLockRoutePaths.settings,
  AppLockRoutePaths.pinCreate,
  AppLockRoutePaths.securityQuestionSetup,
};

/// Top-level GoRouter `redirect` — added to `appRouter` in
/// app_router.dart. Sends any navigation to [AppLockRoutePaths.lockGate]
/// whenever the app is locked, for any destination outside the
/// exempt set above.
///
/// This is the ONLY thing that changes app_router.dart's existing
/// navigation behavior: nothing here alters how any of the app's
/// existing routes/BlocProviders work, and appRouter keeps using
/// MaterialApp.router exactly as it already does in main.dart.
String? lockRedirect(LockBloc lockBloc, GoRouterState state) {
  final lock = lockBloc.state;

  if (lock.isLoading) return null;
  if (lock.lockType == LockType.none) return null;
  if (!lock.isLocked) return null;
  if (_exemptPaths.contains(state.matchedLocation)) return null;

  return AppLockRoutePaths.lockGate;
}
