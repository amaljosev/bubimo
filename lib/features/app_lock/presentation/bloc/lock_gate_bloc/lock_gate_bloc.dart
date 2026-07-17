// lib/features/app_lock/presentation/bloc/lock_gate_bloc/lock_gate_bloc.dart

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../../core/error/failures.dart';
import '../../../domain/entities/lock_method.dart';
import '../../../domain/usecases/authenticate_biometric.dart';
import '../../../domain/usecases/get_lock_settings.dart';
import '../../../domain/usecases/verify_pattern.dart';
import '../../../domain/usecases/verify_pin.dart';
import '../../../domain/usecases/verify_security_answer.dart';

part 'lock_gate_event.dart';
part 'lock_gate_state.dart';

/// Drives the runtime lock gate screen shown on app launch (and resume,
/// if enabled). Handles:
/// - Looking up the active lock method
/// - For biometric: triggering the system prompt, with a background/
///   loading state shown underneath it (LockGateAwaitingBiometric)
/// - For PIN/pattern: capturing and verifying entry
/// - Error states for wrong PIN/pattern, biometric failure/cancel/
///   unavailable, with retry and security-question-fallback actions
class LockGateBloc extends Bloc<LockGateEvent, LockGateState> {
  final GetLockSettings getLockSettings;
  final VerifyPin verifyPin;
  final VerifyPattern verifyPattern;
  final AuthenticateBiometric authenticateBiometric;
  final VerifySecurityAnswer verifySecurityAnswer;

  LockGateBloc({
    required this.getLockSettings,
    required this.verifyPin,
    required this.verifyPattern,
    required this.authenticateBiometric,
    required this.verifySecurityAnswer,
  }) : super(const LockGateInitial()) {
    on<LockGateStarted>(_onStarted);
    on<PinSubmitted>(_onPinSubmitted);
    on<PatternSubmitted>(_onPatternSubmitted);
    on<BiometricRetryRequested>(_onBiometricRetryRequested);
    on<SecurityQuestionFallbackRequested>(
      _onSecurityQuestionFallbackRequested,
    );
    on<SecurityAnswerSubmitted>(_onSecurityAnswerSubmitted);
  }

  Future<void> _onStarted(
    LockGateStarted event,
    Emitter<LockGateState> emit,
  ) async {
    final result = await getLockSettings();

    await result.fold(
      (failure) async => emit(
        LockGateError(
          reason: LockGateErrorReason.biometricUnavailable,
          message: failure.message,
          method: LockMethod.none,
        ),
      ),
      (method) async {
        switch (method) {
          case LockMethod.biometric:
          case LockMethod.deviceCredential:
            emit(const LockGateAwaitingBiometric());
            await _runBiometric(emit, method);
            break;
          case LockMethod.pin:
          case LockMethod.pattern:
            emit(LockGateAwaitingInput(method));
            break;
          case LockMethod.none:
            emit(const LockGateUnlocked());
            break;
        }
      },
    );
  }

  Future<void> _runBiometric(
    Emitter<LockGateState> emit,
    LockMethod method,
  ) async {
    final result = await authenticateBiometric();

    result.fold(
      (failure) {
        final reason = failure is BiometricFailure
            ? LockGateErrorReason.biometricUnavailable
            : LockGateErrorReason.biometricFailed;
        emit(
          LockGateError(
            reason: reason,
            message: failure.message,
            method: method,
          ),
        );
      },
      (success) {
        if (success) {
          emit(const LockGateUnlocked());
        } else {
          emit(
            LockGateError(
              reason: LockGateErrorReason.biometricCancelled,
              message: 'Authentication was cancelled',
              method: method,
            ),
          );
        }
      },
    );
  }

  Future<void> _onPinSubmitted(
    PinSubmitted event,
    Emitter<LockGateState> emit,
  ) async {
    final result = await verifyPin(event.pin);

    result.fold(
      (failure) => emit(
        LockGateError(
          reason: LockGateErrorReason.wrongPin,
          message: failure.message,
          method: LockMethod.pin,
        ),
      ),
      (isCorrect) {
        if (isCorrect) {
          emit(const LockGateUnlocked());
        } else {
          emit(
            const LockGateError(
              reason: LockGateErrorReason.wrongPin,
              message: 'Incorrect PIN',
              method: LockMethod.pin,
            ),
          );
        }
      },
    );
  }

  Future<void> _onPatternSubmitted(
    PatternSubmitted event,
    Emitter<LockGateState> emit,
  ) async {
    final result = await verifyPattern(event.pattern);

    result.fold(
      (failure) => emit(
        LockGateError(
          reason: LockGateErrorReason.wrongPattern,
          message: failure.message,
          method: LockMethod.pattern,
        ),
      ),
      (isCorrect) {
        if (isCorrect) {
          emit(const LockGateUnlocked());
        } else {
          emit(
            const LockGateError(
              reason: LockGateErrorReason.wrongPattern,
              message: 'Incorrect pattern',
              method: LockMethod.pattern,
            ),
          );
        }
      },
    );
  }

  Future<void> _onBiometricRetryRequested(
    BiometricRetryRequested event,
    Emitter<LockGateState> emit,
  ) async {
    emit(const LockGateAwaitingBiometric());
    await _runBiometric(emit, LockMethod.biometric);
  }

  void _onSecurityQuestionFallbackRequested(
    SecurityQuestionFallbackRequested event,
    Emitter<LockGateState> emit,
  ) {
    emit(const LockGateAwaitingSecurityAnswer());
  }

  Future<void> _onSecurityAnswerSubmitted(
    SecurityAnswerSubmitted event,
    Emitter<LockGateState> emit,
  ) async {
    final result = await verifySecurityAnswer(event.answer);

    result.fold(
      (failure) => emit(
        LockGateError(
          reason: LockGateErrorReason.wrongSecurityAnswer,
          message: failure.message,
          method: LockMethod.none,
        ),
      ),
      (isCorrect) {
        if (isCorrect) {
          emit(const LockGateUnlocked());
        } else {
          emit(
            const LockGateError(
              reason: LockGateErrorReason.wrongSecurityAnswer,
              message: 'Incorrect answer',
              method: LockMethod.none,
            ),
          );
        }
      },
    );
  }
}