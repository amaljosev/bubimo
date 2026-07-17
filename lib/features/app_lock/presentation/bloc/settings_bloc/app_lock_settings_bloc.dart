// lib/features/app_lock/presentation/bloc/settings_bloc/app_lock_settings_bloc.dart

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../domain/entities/lock_method.dart';
import '../../../domain/repositories/app_lock_repository.dart';
import '../../../domain/usecases/disable_lock.dart';
import '../../../domain/usecases/get_lock_settings.dart';
import '../../../domain/usecases/set_lock_method.dart';

part 'app_lock_settings_event.dart';
part 'app_lock_settings_state.dart';

/// Drives the app lock listing/settings screen: shows the active
/// method, lets the user switch to an already-configured method
/// directly, and turns the lock off entirely.
///
/// Selecting a method that ISN'T configured yet is handled by
/// navigation (page pushes the relevant setup page) rather than an
/// event here — this bloc only activates methods that already have
/// stored credentials.
class AppLockSettingsBloc
    extends Bloc<AppLockSettingsEvent, AppLockSettingsState> {
  final GetLockSettings getLockSettings;
  final SetLockMethod setLockMethod;
  final DisableLock disableLock;
  final AppLockRepository repository;

  AppLockSettingsBloc({
    required this.getLockSettings,
    required this.setLockMethod,
    required this.disableLock,
    required this.repository,
  }) : super(const AppLockSettingsLoading()) {
    on<LoadLockSettings>(_onLoadLockSettings);
    on<ActivateConfiguredMethod>(_onActivateConfiguredMethod);
    on<TurnOffAppLock>(_onTurnOffAppLock);
  }

  Future<void> _onLoadLockSettings(
    LoadLockSettings event,
    Emitter<AppLockSettingsState> emit,
  ) async {
    emit(const AppLockSettingsLoading());

    final methodResult = await getLockSettings();
    final pinConfiguredResult = await repository.hasPinConfigured();
    final patternConfiguredResult = await repository.hasPatternConfigured();
    final biometricAvailableResult = await repository.isBiometricAvailable();

    methodResult.fold(
      (failure) => emit(AppLockSettingsError(failure.message)),
      (activeMethod) {
        final isPinConfigured = pinConfiguredResult.fold(
          (_) => false,
          (value) => value,
        );
        final isPatternConfigured = patternConfiguredResult.fold(
          (_) => false,
          (value) => value,
        );
        final isBiometricAvailable = biometricAvailableResult.fold(
          (_) => false,
          (value) => value,
        );

        emit(
          AppLockSettingsLoaded(
            activeMethod: activeMethod,
            isPinConfigured: isPinConfigured,
            isPatternConfigured: isPatternConfigured,
            isBiometricAvailable: isBiometricAvailable,
          ),
        );
      },
    );
  }

  Future<void> _onActivateConfiguredMethod(
    ActivateConfiguredMethod event,
    Emitter<AppLockSettingsState> emit,
  ) async {
    final currentState = state;
    if (currentState is! AppLockSettingsLoaded) return;

    final result = await setLockMethod(event.method);

    result.fold(
      (failure) => emit(AppLockSettingsError(failure.message)),
      (_) => emit(currentState.copyWith(activeMethod: event.method)),
    );
  }

  Future<void> _onTurnOffAppLock(
    TurnOffAppLock event,
    Emitter<AppLockSettingsState> emit,
  ) async {
    final currentState = state;
    if (currentState is! AppLockSettingsLoaded) return;

    final result = await disableLock();

    result.fold(
      (failure) => emit(AppLockSettingsError(failure.message)),
      (_) => emit(currentState.copyWith(activeMethod: LockMethod.none)),
    );
  }
}