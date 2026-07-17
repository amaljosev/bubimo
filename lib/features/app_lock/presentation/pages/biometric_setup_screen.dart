// lib/features/app_lock/presentation/pages/biometric_setup_screen.dart
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../domain/entities/lock_method.dart';
import '../../domain/repositories/app_lock_repository.dart';
import '../../domain/usecases/set_lock_method.dart';

/// Biometric setup screen. There's no create/confirm step like PIN or
/// pattern — biometric "setup" is just verifying the device supports
/// it and running one authentication as confirmation before activating
/// it as the lock method. No bloc: this is a single async round trip,
/// handled with local State rather than bloc ceremony.
class BiometricSetupScreen extends StatefulWidget {
  const BiometricSetupScreen({super.key});

  @override
  State<BiometricSetupScreen> createState() => _BiometricSetupScreenState();
}

class _BiometricSetupScreenState extends State<BiometricSetupScreen> {
  bool _isVerifying = false;
  String? _errorMessage;

  Future<void> _verifyAndActivate() async {
    setState(() {
      _isVerifying = true;
      _errorMessage = null;
    });

    final repository = GetIt.instance<AppLockRepository>();
    final setLockMethod = GetIt.instance<SetLockMethod>();

    final authResult = await repository.authenticateBiometric();

    await authResult.fold(
      (failure) async {
        setState(() {
          _isVerifying = false;
          _errorMessage = failure.message;
        });
      },
      (success) async {
        if (!success) {
          setState(() {
            _isVerifying = false;
            _errorMessage = 'Authentication was cancelled';
          });
          return;
        }

        final setResult = await setLockMethod(LockMethod.biometric);
        if (!mounted) return;

        setResult.fold(
          (failure) => setState(() {
            _isVerifying = false;
            _errorMessage = failure.message;
          }),
          (_) => context.pushReplacement(AppRoutes.setupSecurityQuestion),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Biometric Lock')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.fingerprint, size: 72),
            const SizedBox(height: 24),
            const Text(
              'Verify your fingerprint or face to enable biometric lock',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  _errorMessage!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                  textAlign: TextAlign.center,
                ),
              ),
            FilledButton(
              onPressed: _isVerifying ? null : _verifyAndActivate,
              child: _isVerifying
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Verify'),
            ),
          ],
        ),
      ),
    );
  }
}