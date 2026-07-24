// lib/features/app_lock/presentation/bloc/lock_bloc.dart

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/lock_type.dart';
import '../../domain/usecases/authenticate_with_biometrics.dart';
import '../../domain/usecases/check_biometric_availability.dart';
import '../../domain/usecases/get_lock_config.dart';
import '../../domain/usecases/set_biometric_enabled.dart';
import '../../domain/usecases/set_lock_type.dart' as usecase;
import '../../domain/usecases/verify_pin.dart';
import '../../domain/usecases/verify_security_answer.dart';

part 'lock_event.dart';
part 'lock_state.dart';

class LockBloc extends Bloc<LockEvent, AppLockState> {
  LockBloc({
    required this._getLockConfig,
    required this._setLockType,
    required this._setBiometricEnabled,
    required this._checkBiometricAvailability,
    required this._authenticateWithBiometrics,
    required this._verifyPin,
    required this._verifySecurityAnswer,
  }) : super(AppLockState.initial()) {
    on<LoadLockConfig>(_onLoadLockConfig);
    on<SetLockType>(_onSetLockType);
    on<ToggleBiometric>(_onToggleBiometric);
    on<LockApp>(_onLockApp);
    on<UnlockApp>(_onUnlockApp);
    on<VerifyPinAttempt>(_onVerifyPin);
    on<VerifySecurityAnswerAttempt>(_onVerifySecurityAnswer);
    on<VerifyBiometricAttempt>(_onVerifyBiometric);
    on<ResetVerification>(_onResetVerification);
  }

  final GetLockConfig _getLockConfig;
  final usecase.SetLockType _setLockType;
  final SetBiometricEnabled _setBiometricEnabled;
  final CheckBiometricAvailability _checkBiometricAvailability;
  final AuthenticateWithBiometrics _authenticateWithBiometrics;
  final VerifyPin _verifyPin;
  final VerifySecurityAnswer _verifySecurityAnswer;

  Future<void> _onLoadLockConfig(
    LoadLockConfig event,
    Emitter<AppLockState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, loadError: null));

    final result = await _getLockConfig().run();

    await result.match(
      (failure) async {
        emit(state.copyWith(isLoading: false, loadError: failure.message));
      },
      (config) async {
        // If the PRIMARY method is biometric but the OS no longer
        // reports it as available (e.g. the user removed all
        // fingerprints in system settings), fall back to no lock
        // rather than stranding the user behind a broken lock screen.
        // This always forces isLocked false regardless of
        // event.isColdStart — falling back to "no lock" should never
        // leave the user locked out.
        if (config.lockType == LockType.biometric) {
          final availability = await _checkBiometricAvailability().run();
          final stillAvailable = availability.getOrElse((_) => false);

          if (!stillAvailable) {
            await _setLockType(type: LockType.none).run();
            emit(
              state.copyWith(
                lockType: LockType.none,
                isLocked: false,
                isLoading: false,
                verificationStatus: VerificationStatus.idle,
              ),
            );
            return;
          }
        }

        emit(
          state.copyWith(
            lockType: config.lockType,
            securityQuestion: config.securityQuestion,
            biometricEnabled: config.biometricEnabled,
            isLoading: false,
            verificationStatus: VerificationStatus.idle,
            // ONLY derive isLocked from the configured lock type on a
            // genuine cold start (main.dart, before the first frame).
            // A mid-session reload — e.g. AppLockSettingsPage
            // dispatching this in initState every time the screen
            // opens — must leave isLocked exactly as it already was;
            // otherwise merely opening Settings while a lock is
            // configured would flip isLocked true and lock the user
            // out of their own already-unlocked session on the very
            // next navigation.
            isLocked: event.isColdStart
                ? config.lockType != LockType.none
                : state.isLocked,
          ),
        );
      },
    );
  }

  Future<void> _onSetLockType(
    SetLockType event,
    Emitter<AppLockState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, loadError: null));

    final result = await _setLockType(
      type: event.type,
      pin: event.pin,
      question: event.question,
      answer: event.answer,
    ).run();

    result.match(
      (failure) {
        emit(state.copyWith(isLoading: false, loadError: failure.message));
      },
      (_) {
        emit(
          state.copyWith(
            lockType: event.type,
            securityQuestion: event.question ?? state.securityQuestion,
            isLoading: false,
            // Turning the lock OFF always unlocks immediately — that's
            // an intentional, expected effect of choosing "No Lock".
            // Turning a lock ON (or switching between pin/biometric/
            // securityQuestion) must NOT flip isLocked to true: the
            // user is already inside an unlocked session when they
            // reach this settings screen, and setting a new lock type
            // should take effect for the NEXT time the app is opened
            // or resumed — not re lock them out of the flow they're
            // actively completing right now.
            isLocked: event.type == LockType.none ? false : state.isLocked,
          ),
        );
      },
    );
  }

  Future<void> _onToggleBiometric(
    ToggleBiometric event,
    Emitter<AppLockState> emit,
  ) async {
    // Optimistic-ish: flip the UI immediately isn't done here — wait
    // for the write to succeed before reflecting it, same pattern as
    // _onSetLockType, so a failed write doesn't show a toggle state
    // that isn't actually persisted.
    final result = await _setBiometricEnabled(event.enabled).run();

    result.match(
      (failure) => emit(state.copyWith(loadError: failure.message)),
      (_) => emit(state.copyWith(biometricEnabled: event.enabled)),
    );
  }

  void _onLockApp(LockApp event, Emitter<AppLockState> emit) {
    if (state.lockType != LockType.none) {
      emit(
        state.copyWith(
          isLocked: true,
          verificationStatus: VerificationStatus.idle,
        ),
      );
    }
  }

  void _onUnlockApp(UnlockApp event, Emitter<AppLockState> emit) {
    emit(
      state.copyWith(
        isLocked: false,
        verificationStatus: VerificationStatus.idle,
      ),
    );
  }

  Future<void> _onVerifyPin(
    VerifyPinAttempt event,
    Emitter<AppLockState> emit,
  ) async {
    final result = await _verifyPin(event.pin).run();

    result.match(
      (failure) => emit(
        state.copyWith(
          verificationStatus: VerificationStatus.failure,
          verificationError: failure.message,
        ),
      ),
      (_) => emit(
        state.copyWith(
          verificationStatus: VerificationStatus.success,
          isLocked: false,
        ),
      ),
    );
  }

  Future<void> _onVerifySecurityAnswer(
    VerifySecurityAnswerAttempt event,
    Emitter<AppLockState> emit,
  ) async {
    final result = await _verifySecurityAnswer(event.answer).run();

    result.match(
      (failure) => emit(
        state.copyWith(
          verificationStatus: VerificationStatus.failure,
          verificationError: failure.message,
        ),
      ),
      (_) => emit(
        state.copyWith(
          verificationStatus: VerificationStatus.success,
          isLocked: false,
        ),
      ),
    );
  }

  Future<void> _onVerifyBiometric(
    VerifyBiometricAttempt event,
    Emitter<AppLockState> emit,
  ) async {
    if (state.verificationInProgress) return;

    emit(
      state.copyWith(
        verificationStatus: VerificationStatus.inProgress,
        verificationError: null,
      ),
    );

    final result = await _authenticateWithBiometrics(
      reason: event.reason,
    ).run();

    result.match(
      (failure) => emit(
        state.copyWith(
          verificationStatus: VerificationStatus.failure,
          verificationError: failure.message,
        ),
      ),
      (success) {
        if (success) {
          emit(
            state.copyWith(
              verificationStatus: VerificationStatus.success,
              isLocked: false,
            ),
          );
        } else {
          emit(
            state.copyWith(
              verificationStatus: VerificationStatus.failure,
              verificationError: 'Authentication cancelled or failed.',
            ),
          );
        }
      },
    );
  }

  void _onResetVerification(
    ResetVerification event,
    Emitter<AppLockState> emit,
  ) {
    emit(
      state.copyWith(
        verificationStatus: VerificationStatus.idle,
        verificationError: null,
        loadError: null,
      ),
    );
  }
}
