// lib/features/app_lock/presentation/pages/pattern_setup_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../domain/entities/lock_method.dart';
import '../bloc/setup_bloc/lock_setup_bloc.dart';
import '../widgets/pattern_grid_widget.dart';

const int _kMinPatternNodes = 4;

/// Pattern creation flow: draw a pattern (min 4 nodes), redraw the same
/// pattern to confirm, save. Mirrors PinSetupScreen's success
/// navigation to security question setup.
class PatternSetupScreen extends StatelessWidget {
  const PatternSetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GetIt.instance<LockSetupBloc>(
        param1: LockMethod.pattern,
      ),
      child: const _PatternSetupView(),
    );
  }
}

class _PatternSetupView extends StatefulWidget {
  const _PatternSetupView();

  @override
  State<_PatternSetupView> createState() => _PatternSetupViewState();
}

class _PatternSetupViewState extends State<_PatternSetupView> {
  void _onPatternComplete(String pattern, LockSetupState state) {
    final nodeCount = pattern.split('-').length;
    if (nodeCount < _kMinPatternNodes) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Connect at least $_kMinPatternNodes dots'),
        ),
      );
      return;
    }

    final bloc = context.read<LockSetupBloc>();
    if (state is LockSetupAwaitingFirstEntry) {
      bloc.add(SetupFirstEntrySubmitted(pattern));
    } else if (state is LockSetupAwaitingConfirmation) {
      bloc.add(SetupConfirmationSubmitted(pattern));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Set Pattern')),
      body: BlocConsumer<LockSetupBloc, LockSetupState>(
        listener: (context, state) {
          if (state is LockSetupSuccess) {
            context.pushReplacement(AppRoutes.setupSecurityQuestion);
          } else if (state is LockSetupMismatch) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Patterns didn't match — try again"),
              ),
            );
            context.read<LockSetupBloc>().add(const SetupRestarted());
          } else if (state is LockSetupError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          final isConfirmStep = state is LockSetupAwaitingConfirmation;

          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  isConfirmStep
                      ? 'Draw your pattern again to confirm'
                      : 'Draw a pattern (min $_kMinPatternNodes dots)',
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 300),
                  child: PatternGridWidget(
                    onPatternComplete: (pattern) =>
                        _onPatternComplete(pattern, state),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}