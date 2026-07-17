// lib/features/app_lock/presentation/pages/security_question_setup_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../domain/entities/lock_method.dart';
import '../../domain/entities/security_question.dart' show PresetSecurityQuestion;
import '../bloc/setup_bloc/lock_setup_bloc.dart';

/// Security question setup: user picks one of two preset questions, or
/// writes a custom one, then enters an answer. Only this single
/// question + hashed answer is stored — presets are a UX convenience,
/// not separate stored options.
///
/// Reuses LockSetupBloc (method is irrelevant here beyond satisfying
/// the constructor — only SecurityQuestionSubmitted is dispatched).
class SecurityQuestionSetupScreen extends StatelessWidget {
  const SecurityQuestionSetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GetIt.instance<LockSetupBloc>(
        param1: LockMethod.none,
      ),
      child: const _SecurityQuestionSetupView(),
    );
  }
}

class _SecurityQuestionSetupView extends StatefulWidget {
  const _SecurityQuestionSetupView();

  @override
  State<_SecurityQuestionSetupView> createState() =>
      _SecurityQuestionSetupViewState();
}

class _SecurityQuestionSetupViewState
    extends State<_SecurityQuestionSetupView> {
  PresetSecurityQuestion _selected = PresetSecurityQuestion.petName;
  final _customQuestionController = TextEditingController();
  final _answerController = TextEditingController();

  @override
  void dispose() {
    _customQuestionController.dispose();
    _answerController.dispose();
    super.dispose();
  }

  void _onSave() {
    final question = _selected == PresetSecurityQuestion.custom
        ? _customQuestionController.text.trim()
        : _selected.text;
    final answer = _answerController.text.trim();

    if (question.isEmpty || answer.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in a question and answer')),
      );
      return;
    }

    context.read<LockSetupBloc>().add(
          SecurityQuestionSubmitted(question: question, answer: answer),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Security Question')),
      body: BlocConsumer<LockSetupBloc, LockSetupState>(
        listener: (context, state) {
          if (state is LockSetupSuccess) {
            context.go(AppRoutes.lockListing);
          } else if (state is LockSetupError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              const Text(
                'This helps you recover access if you forget your PIN, '
                'pattern, or biometrics stop working.',
              ),
              const SizedBox(height: 24),
              for (final preset in PresetSecurityQuestion.values)
                RadioListTile<PresetSecurityQuestion>(
                  value: preset,
                  groupValue: _selected,
                  title: Text(preset.text),
                  onChanged: (value) => setState(() => _selected = value!),
                ),
              if (_selected == PresetSecurityQuestion.custom)
                Padding(
                  padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                  child: TextField(
                    controller: _customQuestionController,
                    decoration: const InputDecoration(
                      labelText: 'Your question',
                    ),
                  ),
                ),
              const SizedBox(height: 8),
              TextField(
                controller: _answerController,
                decoration: const InputDecoration(labelText: 'Answer'),
                obscureText: true,
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _onSave,
                child: const Text('Save'),
              ),
            ],
          );
        },
      ),
    );
  }
}