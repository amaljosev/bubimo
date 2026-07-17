// lib/features/app_lock/presentation/pages/security_question_recovery_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/lock_gate_bloc/lock_gate_bloc.dart';

/// Recovery form shown when the user taps "forgot PIN/pattern" or
/// "use security question instead" from a LockGateError state. Reads
/// the question from the already-loaded LockGateBloc (provided by the
/// parent LockGateScreen — this is not a standalone route with its
/// own BlocProvider).
class SecurityQuestionRecoveryScreen extends StatefulWidget {
  final String question;

  const SecurityQuestionRecoveryScreen({super.key, required this.question});

  @override
  State<SecurityQuestionRecoveryScreen> createState() =>
      _SecurityQuestionRecoveryScreenState();
}

class _SecurityQuestionRecoveryScreenState
    extends State<SecurityQuestionRecoveryScreen> {
  final _answerController = TextEditingController();

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  void _onSubmit() {
    final answer = _answerController.text.trim();
    if (answer.isEmpty) return;

    context.read<LockGateBloc>().add(SecurityAnswerSubmitted(answer));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LockGateBloc, LockGateState>(
      builder: (context, state) {
        final isWrongAnswer = state is LockGateError &&
            state.reason == LockGateErrorReason.wrongSecurityAnswer;

        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.question,
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _answerController,
                decoration: InputDecoration(
                  labelText: 'Answer',
                  errorText: isWrongAnswer ? 'Incorrect answer' : null,
                ),
                onSubmitted: (_) => _onSubmit(),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _onSubmit,
                child: const Text('Submit'),
              ),
            ],
          ),
        );
      },
    );
  }
}