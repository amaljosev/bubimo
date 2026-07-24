// lib/features/app_lock/domain/entities/lock_config.dart

import 'package:equatable/equatable.dart';
import 'lock_type.dart';

/// The persisted app-lock configuration, as read out of the database.
///
/// Never carries the raw secrets (PIN, security answer) back up to the
/// bloc or UI — only their hashes are stored (see
/// AppSettingsTable.columnLockPinHash /
/// columnLockSecurityAnswerHash), compared internally by the
/// repository's verify methods; this entity never even sees the hash.
class LockConfig extends Equatable {
  const LockConfig({
    required this.lockType,
    this.securityQuestion,
    this.biometricEnabled = false,
  });

  final LockType lockType;

  /// Only populated when [lockType] is [LockType.securityQuestion] — the
  /// question text to display, never the answer.
  final String? securityQuestion;

  /// Independent of [lockType] — when [lockType] is
  /// [LockType.pin] or [LockType.securityQuestion], this being true
  /// means biometrics can ALSO be used as a faster shortcut to unlock,
  /// on top of the primary method. Meaningless/ignored when [lockType]
  /// is [LockType.biometric] (already biometric-only) or
  /// [LockType.none]. Backed by AppSettingsTable.columnBiometricEnabled.
  final bool biometricEnabled;

  static const none = LockConfig(lockType: LockType.none);

  LockConfig copyWith({
    LockType? lockType,
    String? securityQuestion,
    bool? biometricEnabled,
  }) {
    return LockConfig(
      lockType: lockType ?? this.lockType,
      securityQuestion: securityQuestion ?? this.securityQuestion,
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
    );
  }

  @override
  List<Object?> get props => [lockType, securityQuestion, biometricEnabled];
}