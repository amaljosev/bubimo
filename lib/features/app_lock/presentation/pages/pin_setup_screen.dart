// lib/features/app_lock/presentation/pages/pin_setup_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../domain/entities/lock_method.dart';
import '../bloc/setup_bloc/lock_setup_bloc.dart';
import '../widgets/pin_input_field.dart';

const int _kPinLength = 4;

/// PIN creation flow: enter 4 digits, confirm the same 4 digits, save.
/// On success, navigates to security question setup — adjust if a
/// security question already exists and you want to skip that step.
class PinSetupScreen extends StatelessWidget {
  const PinSetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GetIt.instance<LockSetupBloc>(
        param1: LockMethod.pin,
      ),
      child: const _PinSetupView(),
    );
  }
}

class _PinSetupView extends StatefulWidget {
  const _PinSetupView();

  @override
  State<_PinSetupView> createState() => _PinSetupViewState();
}

class _PinSetupViewState extends State<_PinSetupView> {
  String _digits = '';

  void _onDigitPressed(String digit, LockSetupState state) {
    if (_digits.length >= _kPinLength) return;

    setState(() => _digits += digit);

    if (_digits.length == _kPinLength) {
      final bloc = context.read<LockSetupBloc>();
      if (state is LockSetupAwaitingFirstEntry) {
        bloc.add(SetupFirstEntrySubmitted(_digits));
      } else if (state is LockSetupAwaitingConfirmation) {
        bloc.add(SetupConfirmationSubmitted(_digits));
      }
      // Clear the visual entry after a short delay so the last dot's
      // fill is visible before resetting for the next step.
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
    return Scaffold(
      appBar: AppBar(title: const Text('Set PIN')),
      body: BlocConsumer<LockSetupBloc, LockSetupState>(
        listener: (context, state) {
          if (state is LockSetupSuccess) {
            context.pushReplacement(AppRoutes.setupSecurityQuestion);
          } else if (state is LockSetupMismatch) {
            setState(() => _digits = '');
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("PINs didn't match — try again")),
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
                  isConfirmStep ? 'Confirm your PIN' : 'Enter a 4-digit PIN',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 32),
                PinInputField(
                  length: _kPinLength,
                  enteredCount: _digits.length,
                ),
                const SizedBox(height: 48),
                PinKeypad(
                  onDigitPressed: (digit) => _onDigitPressed(digit, state),
                  onBackspacePressed: _onBackspacePressed,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}