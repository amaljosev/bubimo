// lib/features/app_lock/presentation/pages/lock_gate_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../../domain/entities/lock_method.dart';
import '../../domain/repositories/app_lock_repository.dart';
import '../bloc/lock_gate_bloc/lock_gate_bloc.dart';
import '../widgets/lock_gate_background.dart';
import '../widgets/pattern_verify_widget.dart';
import '../widgets/pin_input_field.dart';
import 'security_question_recovery_screen.dart';

/// The runtime app-lock screen shown on launch (and resume, if
/// lock-on-resume is enabled). A single screen whose body switches on
/// LockGateState:
/// - LockGateAwaitingBiometric: dimmed background + loader while the
///   OS biometric sheet is up
/// - LockGateAwaitingInput: PIN keypad or pattern grid
/// - LockGateError: reason-specific message + retry / fallback actions
/// - LockGateAwaitingSecurityAnswer: recovery form
/// - LockGateUnlocked: caller (app shell / router) should pop this
///   screen — see onUnlocked callback
class LockGateScreen extends StatelessWidget {
  final VoidCallback onUnlocked;

  const LockGateScreen({super.key, required this.onUnlocked});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          GetIt.instance<LockGateBloc>()..add(const LockGateStarted()),
      child: _LockGateView(onUnlocked: onUnlocked),
    );
  }
}

class _LockGateView extends StatelessWidget {
  final VoidCallback onUnlocked;

  const _LockGateView({required this.onUnlocked});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<LockGateBloc, LockGateState>(
        listener: (context, state) {
          if (state is LockGateUnlocked) {
            onUnlocked();
          }
        },
        builder: (context, state) {
          return switch (state) {
            LockGateInitial() ||
            LockGateAwaitingBiometric() =>
              const LockGateBackground(),
            LockGateAwaitingInput(method: final method) =>
              _InputView(method: method),
            LockGateAwaitingSecurityAnswer() => _SecurityAnswerView(),
            LockGateError(:final reason, :final message, :final method) =>
              _ErrorView(reason: reason, message: message, method: method),
            LockGateUnlocked() => const SizedBox.shrink(),
          };
        },
      ),
    );
  }
}

class _InputView extends StatelessWidget {
  final LockMethod method;

  const _InputView({required this.method});

  @override
  Widget build(BuildContext context) {
    if (method == LockMethod.pattern) {
      return Center(
        child: PatternVerifyWidget(
          onPatternSubmitted: (pattern) =>
              context.read<LockGateBloc>().add(PatternSubmitted(pattern)),
          onForgotPattern: () => context
              .read<LockGateBloc>()
              .add(const SecurityQuestionFallbackRequested()),
        ),
      );
    }

    // PIN entry.
    return _PinEntryView();
  }
}

class _PinEntryView extends StatefulWidget {
  @override
  State<_PinEntryView> createState() => _PinEntryViewState();
}

class _PinEntryViewState extends State<_PinEntryView> {
  String _digits = '';

  void _onDigitPressed(String digit) {
    if (_digits.length >= 4) return;
    setState(() => _digits += digit);

    if (_digits.length == 4) {
      context.read<LockGateBloc>().add(PinSubmitted(_digits));
      Future.delayed(const Duration(milliseconds: 150), () {
        if (mounted) setState(() => _digits = '');
      });
    }
  }

  void _onBackspacePressed() {
    if (_digits.isEmpty) return;
    setState(() => _digits = _digits.substring(0, _digits.length - 1));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Enter your PIN'),
          const SizedBox(height: 32),
          PinInputField(enteredCount: _digits.length),
          const SizedBox(height: 48),
          PinKeypad(
            onDigitPressed: _onDigitPressed,
            onBackspacePressed: _onBackspacePressed,
          ),
          TextButton(
            onPressed: () => context
                .read<LockGateBloc>()
                .add(const SecurityQuestionFallbackRequested()),
            child: const Text('Forgot PIN?'),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final LockGateErrorReason reason;
  final String message;
  final LockMethod method;

  const _ErrorView({
    required this.reason,
    required this.message,
    required this.method,
  });

  bool get _canRetryBiometric =>
      reason == LockGateErrorReason.biometricFailed ||
      reason == LockGateErrorReason.biometricCancelled;

  bool get _canOfferSecurityFallback =>
      reason != LockGateErrorReason.wrongSecurityAnswer;

  bool get _shouldReturnToInput =>
      reason == LockGateErrorReason.wrongPin ||
      reason == LockGateErrorReason.wrongPattern;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 56,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 24),
          if (_shouldReturnToInput)
            FilledButton(
              onPressed: () => context
                  .read<LockGateBloc>()
                  .add(const LockGateStarted()),
              child: const Text('Try again'),
            ),
          if (_canRetryBiometric)
            FilledButton(
              onPressed: () => context
                  .read<LockGateBloc>()
                  .add(const BiometricRetryRequested()),
              child: const Text('Try again'),
            ),
          if (_canOfferSecurityFallback)
            TextButton(
              onPressed: () => context
                  .read<LockGateBloc>()
                  .add(const SecurityQuestionFallbackRequested()),
              child: const Text('Use security question instead'),
            ),
        ],
      ),
    );
  }
}

class _SecurityAnswerView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: GetIt.instance<AppLockRepository>().getSecurityQuestion(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final result = snapshot.data!;
        return result.fold(
          (failure) => Center(child: Text(failure.message)),
          (question) {
            if (question == null) {
              return const Center(
                child: Text('No security question configured'),
              );
            }
            return Center(
              child: SecurityQuestionRecoveryScreen(
                question: question.question,
              ),
            );
          },
        );
      },
    );
  }
}