// lib/features/app_lock/domain/entities/security_question.dart
import 'package:equatable/equatable.dart';

/// The two preset questions shown in the UI, plus the option for the user
/// to type their own. Only one question + hashed answer is ever stored.
enum PresetSecurityQuestion {
  petName('What was the name of your first pet?'),
  birthCity('In which city were you born?'),
  custom('Write your own question');

  final String text;
  const PresetSecurityQuestion(this.text);
}

/// Domain entity for the single stored security question + hashed answer.
///
/// [answerHash] is always a SHA-256 hash (see HashingUtils) — the plaintext
/// answer is never persisted.
class SecurityQuestion extends Equatable {
  final String question;
  final String answerHash;

  const SecurityQuestion({
    required this.question,
    required this.answerHash,
  });

  @override
  List<Object?> get props => [question, answerHash];
}