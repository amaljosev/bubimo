// lib/features/app_lock/presentation/bloc/settings_bloc/app_lock_settings_event.dart

part of 'app_lock_settings_bloc.dart';

sealed class AppLockSettingsEvent extends Equatable {
  const AppLockSettingsEvent();

  @override
  List<Object?> get props => [];
}

/// Loads the currently active lock method, plus which methods have
/// credentials already configured (so the listing screen can show
/// "tap to switch" vs "tap to set up").
class LoadLockSettings extends AppLockSettingsEvent {
  const LoadLockSettings();
}

/// User selected a method tile that already has credentials configured
/// (e.g. switching back to a previously-set-up PIN) — activates it
/// directly without going through setup again.
class ActivateConfiguredMethod extends AppLockSettingsEvent {
  final LockMethod method;

  const ActivateConfiguredMethod(this.method);

  @override
  List<Object?> get props => [method];
}

/// User toggled the master "App Lock" switch off.
class TurnOffAppLock extends AppLockSettingsEvent {
  const TurnOffAppLock();
}