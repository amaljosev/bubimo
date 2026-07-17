// lib/features/app_lock/data/datasources/app_lock_local_datasource.dart

import 'package:local_auth/local_auth.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/database/tables/app_settings_table.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/utils/hashing_utils.dart';
import '../models/lock_settings_model.dart';

/// Raw sqflite access to the app-lock columns on the single
/// `app_settings` row, plus local_auth calls for biometric/device
/// credential.
///
/// Uses AppSettingsTable.tableName ('app_settings') and
/// AppSettingsTable.singletonId ('singleton') — the same singleton row
/// every other settings feature (reminders, theme, font) already
/// reads/writes, not a separate table.
///
/// local_auth API note: `authenticate()` takes flat named parameters
/// directly (no `AuthenticationOptions` wrapper — that class was
/// removed from current local_auth; it accepts `biometricOnly` and
/// `stickyAuth` directly on the call).
class AppLockLocalDataSource {
  final AppDatabase appDatabase;
  final LocalAuthentication localAuth;

  AppLockLocalDataSource({
    required this.appDatabase,
    LocalAuthentication? localAuth,
  }) : localAuth = localAuth ?? LocalAuthentication();

  Future<LockSettingsModel> getLockSettings() async {
    final db = await appDatabase.database;
    final rows = await db.query(
      AppSettingsTable.tableName,
      where: '${AppSettingsTable.columnId} = ?',
      whereArgs: [AppSettingsTable.singletonId],
      limit: 1,
    );

    if (rows.isEmpty) {
      throw const AppDatabaseException(
        message:
            'No app_settings row found to read app lock settings from. '
            'Ensure the singleton row is seeded on first app launch.',
      );
    }

    return LockSettingsModel.fromMap(rows.first);
  }

  Future<void> _updateSettingsColumns(Map<String, dynamic> values) async {
    final db = await appDatabase.database;
    final rowsAffected = await db.update(
      AppSettingsTable.tableName,
      values,
      where: '${AppSettingsTable.columnId} = ?',
      whereArgs: [AppSettingsTable.singletonId],
    );

    if (rowsAffected == 0) {
      throw const AppDatabaseException(
        message:
            'No app_settings row found to update app lock settings on. '
            'Ensure the singleton row is seeded on first app launch.',
      );
    }
  }

  Future<void> setActiveLockMethod(String lockTypeDbValue) {
    return _updateSettingsColumns({
      AppSettingsTable.columnLockType: lockTypeDbValue,
    });
  }

  Future<void> disableLock() {
    return _updateSettingsColumns({
      AppSettingsTable.columnLockType: AppSettingsTable.defaultLockType,
    });
  }

  Future<void> setPin(String pin) {
    return _updateSettingsColumns({
      AppSettingsTable.columnLockPinHash: HashingUtils.hash(pin),
    });
  }

  Future<void> setPattern(String pattern) {
    return _updateSettingsColumns({
      AppSettingsTable.columnLockPatternHash: HashingUtils.hash(pattern),
    });
  }

  Future<void> setSecurityQuestion({
    required String question,
    required String answerHash,
  }) {
    return _updateSettingsColumns({
      AppSettingsTable.columnLockSecurityQuestion: question,
      AppSettingsTable.columnLockSecurityAnswerHash: answerHash,
    });
  }

  /// Passive capability check — does NOT call localAuth.authenticate().
  /// True only if the device has biometric hardware AND at least one
  /// biometric is enrolled.
  Future<bool> isBiometricAvailable() async {
    final canCheck = await localAuth.canCheckBiometrics;
    final isSupported = await localAuth.isDeviceSupported();
    if (!canCheck || !isSupported) return false;

    final availableBiometrics = await localAuth.getAvailableBiometrics();
    return availableBiometrics.isNotEmpty;
  }

  /// Runs the biometric prompt. Throws [BiometricException] if
  /// biometrics aren't enrolled/available on the device — the
  /// repository maps this to a [BiometricFailure]. Returns false (not
  /// an exception) for user cancellation or a failed match.
  Future<bool> authenticateBiometric() async {
    final canCheck = await localAuth.canCheckBiometrics;
    final isSupported = await localAuth.isDeviceSupported();

    if (!canCheck || !isSupported) {
      throw const BiometricException(
        message: 'Biometric authentication is not available on this device',
      );
    }

    final availableBiometrics = await localAuth.getAvailableBiometrics();
    if (availableBiometrics.isEmpty) {
      throw const BiometricException(
        message: 'No biometrics are enrolled on this device',
      );
    }

    return localAuth.authenticate(
      localizedReason: 'Unlock to continue',
      biometricOnly: true,
      
    );
  }

  /// Runs device credential auth (system PIN/pattern/password), allowing
  /// local_auth's non-biometric fallback.
  Future<bool> authenticateDeviceCredential() async {
    final isSupported = await localAuth.isDeviceSupported();
    if (!isSupported) {
      throw const BiometricException(
        message:
            'Device credential authentication is not supported on this device',
      );
    }

    return localAuth.authenticate(
      localizedReason: 'Unlock to continue',
      biometricOnly: false,
      
    );
  }
}