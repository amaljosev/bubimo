// lib/features/app_lock/data/datasources/biometric_data_source.dart

import 'package:local_auth/local_auth.dart';

abstract class BiometricDataSource {
  Future<bool> isAvailable();

  Future<bool> authenticate({required String reason});
}

class BiometricDataSourceImpl implements BiometricDataSource {
  BiometricDataSourceImpl({LocalAuthentication? localAuth})
    : _localAuth = localAuth ?? LocalAuthentication();

  final LocalAuthentication _localAuth;

  @override
  Future<bool> isAvailable() async {
    final canCheckBiometrics = await _localAuth.canCheckBiometrics;
    final isDeviceSupported = await _localAuth.isDeviceSupported();
    return canCheckBiometrics || isDeviceSupported;
  }

  @override
  Future<bool> authenticate({required String reason}) {
    // Current local_auth API: authenticate() takes `biometricOnly`
    // directly (no separate AuthenticationOptions class — that was
    // removed; `authenticateWithBiometrics` was removed even earlier
    // in favor of this single method). biometricOnly: false lets the
    // OS fall back to device PIN/pattern/passcode if biometrics aren't
    // enrolled, matching the original behavior this datasource wants.
    return _localAuth.authenticate(
      localizedReason: reason,
      biometricOnly: false,
    );
  }
}