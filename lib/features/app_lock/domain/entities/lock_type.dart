// lib/features/app_lock/domain/entities/lock_type.dart

/// The kind of protection guarding entry into the app.
///
/// Persisted as its [name] string (in the app_lock_settings table's
/// `lock_type` column) — do not reorder or rename existing values
/// without a migration, since stored rows reference these names
/// directly.
enum LockType { none, biometric, pin, securityQuestion }

extension LockTypeCodec on LockType {
  String get storageKey => name;

  static LockType fromStorageKey(String? key) {
    return LockType.values.firstWhere(
      (e) => e.name == key,
      orElse: () => LockType.none,
    );
  }
}
