// lib/features/app_lock/data/models/lock_settings_model.dart

import '../../domain/entities/lock_type.dart';

/// The app-lock-relevant subset of a row from the shared `app_settings`
/// table (see AppSettingsTable) — this feature reads/writes only its
/// own columns on that single singleton row, never the whole row
/// wholesale, so reminder/theme/font columns on the same row are left
/// untouched by any write this model produces.
///
/// [pinHash] and [securityAnswerHash] are SHA-256 hex digests (see
/// LockLocalDataSourceImpl._hash) — the plaintext PIN/answer are never
/// stored anywhere, not even transiently in this model.
class LockSettingsModel {
  const LockSettingsModel({
    required this.lockType,
    this.pinHash,
    this.securityQuestion,
    this.securityAnswerHash,
    this.biometricEnabled = false,
  });

  final LockType lockType;
  final String? pinHash;
  final String? securityQuestion;
  final String? securityAnswerHash;
  final bool biometricEnabled;

  factory LockSettingsModel.fromMap(Map<String, Object?> map) {
    return LockSettingsModel(
      lockType: LockTypeCodec.fromStorageKey(map['lock_type'] as String?),
      pinHash: map['lock_pin_hash'] as String?,
      securityQuestion: map['lock_security_question'] as String?,
      securityAnswerHash: map['lock_security_answer_hash'] as String?,
      biometricEnabled: (map['biometric_enabled'] as int? ?? 0) != 0,
    );
  }

  /// Only the app-lock columns — deliberately NOT a full-row map, since
  /// this feature must never overwrite the reminder/theme/font columns
  /// that also live on the app_settings singleton row. Callers use
  /// this with `db.update(..., where: 'id = ?')`, not `db.insert` with
  /// `ConflictAlgorithm.replace` (which would null out every other
  /// column on the row).
  Map<String, Object?> toColumnMap() {
    return {
      'lock_type': lockType.storageKey,
      'lock_pin_hash': pinHash,
      'lock_security_question': securityQuestion,
      'lock_security_answer_hash': securityAnswerHash,
      'biometric_enabled': biometricEnabled ? 1 : 0,
    };
  }

  LockSettingsModel copyWith({
    LockType? lockType,
    String? pinHash,
    String? securityQuestion,
    String? securityAnswerHash,
    bool? biometricEnabled,
  }) {
    return LockSettingsModel(
      lockType: lockType ?? this.lockType,
      pinHash: pinHash ?? this.pinHash,
      securityQuestion: securityQuestion ?? this.securityQuestion,
      securityAnswerHash: securityAnswerHash ?? this.securityAnswerHash,
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
    );
  }
}