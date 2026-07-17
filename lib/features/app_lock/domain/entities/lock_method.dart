// lib/features/app_lock/domain/entities/lock_method.dart

/// The set of lock methods a user can enable for app lock.
///
/// Only one [LockMethod] can be active at a time — selecting a new one
/// replaces whatever was previously active.
enum LockMethod {
  none,
  biometric,
  pin,
  pattern,
  deviceCredential;

  bool get isEnabled => this != LockMethod.none;

  String get label {
    switch (this) {
      case LockMethod.none:
        return 'No Lock';
      case LockMethod.biometric:
        return 'Biometric';
      case LockMethod.pin:
        return 'PIN';
      case LockMethod.pattern:
        return 'Pattern';
      case LockMethod.deviceCredential:
        return 'Device Credential';
    }
  }

  /// Persisted as TEXT in app_settings_table's `lock_type` column —
  /// matches AppSettingsTable.defaultLockType ('none') and the other
  /// string values documented on that column.
  String get dbValue {
    switch (this) {
      case LockMethod.none:
        return 'none';
      case LockMethod.biometric:
        return 'biometric';
      case LockMethod.pin:
        return 'pin';
      case LockMethod.pattern:
        return 'pattern';
      case LockMethod.deviceCredential:
        return 'device_credential';
    }
  }

  static LockMethod fromDbValue(String? value) {
    switch (value) {
      case 'biometric':
        return LockMethod.biometric;
      case 'pin':
        return LockMethod.pin;
      case 'pattern':
        return LockMethod.pattern;
      case 'device_credential':
        return LockMethod.deviceCredential;
      case 'none':
      default:
        return LockMethod.none;
    }
  }
}