// lib/features/app_lock/data/datasources/lock_secrets_data_source.dart

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Holds the actual secrets (PIN, security answer) in the platform
/// keystore/keychain via flutter_secure_storage — never in the sqflite
/// database alongside the rest of the app's data. Matches how lock
/// secrets are already stored elsewhere in this app.
abstract class LockSecretsDataSource {
  Future<String?> getPin();
  Future<void> setPin(String pin);

  Future<String?> getSecurityAnswer();
  Future<void> setSecurityAnswer(String answer);
}

class LockSecretsDataSourceImpl implements LockSecretsDataSource {
  const LockSecretsDataSourceImpl(this._storage);

  final FlutterSecureStorage _storage;

  static const _pinKey = 'app_lock_pin';
  static const _securityAnswerKey = 'app_lock_security_answer';

  @override
  Future<String?> getPin() => _storage.read(key: _pinKey);

  @override
  Future<void> setPin(String pin) => _storage.write(key: _pinKey, value: pin);

  @override
  Future<String?> getSecurityAnswer() => _storage.read(key: _securityAnswerKey);

  @override
  Future<void> setSecurityAnswer(String answer) =>
      _storage.write(key: _securityAnswerKey, value: answer);
}
