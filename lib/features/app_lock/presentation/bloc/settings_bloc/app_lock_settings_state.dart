// lib/features/app_lock/presentation/bloc/settings_bloc/app_lock_settings_state.dart

part of 'app_lock_settings_bloc.dart';

sealed class AppLockSettingsState extends Equatable {
  const AppLockSettingsState();

  @override
  List<Object?> get props => [];
}

class AppLockSettingsLoading extends AppLockSettingsState {
  const AppLockSettingsLoading();
}

class AppLockSettingsLoaded extends AppLockSettingsState {
  final LockMethod activeMethod;
  final bool isPinConfigured;
  final bool isPatternConfigured;
  final bool isBiometricAvailable;

  const AppLockSettingsLoaded({
    required this.activeMethod,
    required this.isPinConfigured,
    required this.isPatternConfigured,
    required this.isBiometricAvailable,
  });

  bool isConfigured(LockMethod method) {
    switch (method) {
      case LockMethod.pin:
        return isPinConfigured;
      case LockMethod.pattern:
        return isPatternConfigured;
      case LockMethod.biometric:
      case LockMethod.deviceCredential:
        // These rely on device-level enrollment rather than an
        // app-stored credential, so there's nothing to "configure"
        // ahead of time — activating them is itself the setup step.
        return true;
      case LockMethod.none:
        return true;
    }
  }

  /// Whether [method]'s tile should be shown on the listing screen at
  /// all. Biometric is hidden entirely (not just disabled) when the
  /// device has no biometric hardware/enrollment — device credential,
  /// PIN, and pattern have no such hardware dependency.
  bool isVisible(LockMethod method) {
    if (method == LockMethod.biometric) return isBiometricAvailable;
    return true;
  }

  AppLockSettingsLoaded copyWith({
    LockMethod? activeMethod,
    bool? isPinConfigured,
    bool? isPatternConfigured,
    bool? isBiometricAvailable,
  }) {
    return AppLockSettingsLoaded(
      activeMethod: activeMethod ?? this.activeMethod,
      isPinConfigured: isPinConfigured ?? this.isPinConfigured,
      isPatternConfigured: isPatternConfigured ?? this.isPatternConfigured,
      isBiometricAvailable: isBiometricAvailable ?? this.isBiometricAvailable,
    );
  }

  @override
  List<Object?> get props => [
        activeMethod,
        isPinConfigured,
        isPatternConfigured,
        isBiometricAvailable,
      ];
}

class AppLockSettingsError extends AppLockSettingsState {
  final String message;

  const AppLockSettingsError(this.message);

  @override
  List<Object?> get props => [message];
}