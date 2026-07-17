// lib/features/app_lock/presentation/bloc/setup_bloc/lock_setup_bloc.dart

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../../core/utils/hashing_utils.dart';
import '../../../domain/entities/lock_method.dart';
import '../../../domain/entities/security_question.dart';
import '../../../domain/usecases/set_pattern.dart';
import '../../../domain/usecases/set_pin.dart';
import '../../../domain/usecases/set_security_question.dart';

part 'lock_setup_event.dart';
part 'lock_setup_state.dart';

/// Shared setup flow for PIN and Pattern (create → confirm → save) and
/// Security Question (question + answer → save).
///
/// One bloc instance is created per setup page (registered in GetIt
/// via registerFactoryParam, keyed by [LockMethod]), so the same class
/// drives PinSetupScreen, PatternSetupScreen, and
/// SecurityQuestionSetupScreen without duplicating the create/confirm
/// state machine three times.
class LockSetupBloc extends Bloc<LockSetupEvent, LockSetupState> {
  final LockMethod method;
  final SetPin setPin;
  final SetPattern setPattern;
  final SetSecurityQuestion setSecurityQuestion;

  String? _firstEntry;

  LockSetupBloc({
    required this.method,
    required this.setPin,
    required this.setPattern,
    required this.setSecurityQuestion,
  }) : super(const LockSetupAwaitingFirstEntry()) {
    on<SetupFirstEntrySubmitted>(_onFirstEntrySubmitted);
    on<SetupConfirmationSubmitted>(_onConfirmationSubmitted);
    on<SetupRestarted>(_onRestarted);
    on<SecurityQuestionSubmitted>(_onSecurityQuestionSubmitted);
  }

  void _onFirstEntrySubmitted(
    SetupFirstEntrySubmitted event,
    Emitter<LockSetupState> emit,
  ) {
    _firstEntry = event.value;
    emit(const LockSetupAwaitingConfirmation());
  }

  Future<void> _onConfirmationSubmitted(
    SetupConfirmationSubmitted event,
    Emitter<LockSetupState> emit,
  ) async {
    if (_firstEntry == null) {
      emit(const LockSetupAwaitingFirstEntry());
      return;
    }

    if (event.value != _firstEntry) {
      emit(const LockSetupMismatch());
      return;
    }

    switch (method) {
      case LockMethod.pin:
        final result = await setPin(_firstEntry!);
        result.fold(
          (failure) => emit(LockSetupError(failure.message)),
          (_) => emit(const LockSetupSuccess()),
        );
        break;
      case LockMethod.pattern:
        final result = await setPattern(_firstEntry!);
        result.fold(
          (failure) => emit(LockSetupError(failure.message)),
          (_) => emit(const LockSetupSuccess()),
        );
        break;
      default:
        emit(
          LockSetupError(
            'LockSetupBloc.confirmation is not applicable for $method',
          ),
        );
    }
  }

  void _onRestarted(SetupRestarted event, Emitter<LockSetupState> emit) {
    _firstEntry = null;
    emit(const LockSetupAwaitingFirstEntry());
  }

  Future<void> _onSecurityQuestionSubmitted(
    SecurityQuestionSubmitted event,
    Emitter<LockSetupState> emit,
  ) async {
    final question = SecurityQuestion(
      question: event.question,
      answerHash: HashingUtils.hash(event.answer),
    );

    final result = await setSecurityQuestion(question);

    result.fold(
      (failure) => emit(LockSetupError(failure.message)),
      (_) => emit(const LockSetupSuccess()),
    );
  }
}