// lib/features/app_lock/data/models/lock_settings_model.dart

import '../../domain/entities/lock_method.dart';
import '../../domain/entities/security_question.dart';

/// Data-layer model mapping the app-lock columns of the single
/// `app_settings` row to/from the domain entities. Column names match
/// AppSettingsTable exactly (lock_type, lock_pin_hash,
/// lock_pattern_hash, lock_security_question,
/// lock_security_answer_hash) — this is NOT a separate table.
class LockSettingsModel {
  final LockMethod lockMethod;
  final String? pinHash;
  final String? patternHash;
  final String? securityQuestion;
  final String? securityAnswerHash;

  const LockSettingsModel({
    required this.lockMethod,
    this.pinHash,
    this.patternHash,
    this.securityQuestion,
    this.securityAnswerHash,
  });

  factory LockSettingsModel.fromMap(Map<String, dynamic> map) {
    return LockSettingsModel(
      lockMethod: LockMethod.fromDbValue(map['lock_type'] as String?),
      pinHash: map['lock_pin_hash'] as String?,
      patternHash: map['lock_pattern_hash'] as String?,
      securityQuestion: map['lock_security_question'] as String?,
      securityAnswerHash: map['lock_security_answer_hash'] as String?,
    );
  }

  /// Returns only the app-lock columns for a partial UPDATE — callers
  /// should merge this into their existing settings-row update rather
  /// than overwrite unrelated settings columns (reminder, theme, font
  /// preferences live in the same row).
  Map<String, dynamic> toMap() {
    return {
      'lock_type': lockMethod.dbValue,
      'lock_pin_hash': pinHash,
      'lock_pattern_hash': patternHash,
      'lock_security_question': securityQuestion,
      'lock_security_answer_hash': securityAnswerHash,
    };
  }

  SecurityQuestion? toSecurityQuestionEntity() {
    if (securityQuestion == null || securityAnswerHash == null) return null;
    return SecurityQuestion(
      question: securityQuestion!,
      answerHash: securityAnswerHash!,
    );
  }

  LockSettingsModel copyWith({
    LockMethod? lockMethod,
    String? pinHash,
    String? patternHash,
    String? securityQuestion,
    String? securityAnswerHash,
  }) {
    return LockSettingsModel(
      lockMethod: lockMethod ?? this.lockMethod,
      pinHash: pinHash ?? this.pinHash,
      patternHash: patternHash ?? this.patternHash,
      securityQuestion: securityQuestion ?? this.securityQuestion,
      securityAnswerHash: securityAnswerHash ?? this.securityAnswerHash,
    );
  }
}