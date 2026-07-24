// lib/features/app_lock/domain/usecases/set_lock_type.dart

import 'package:fpdart/fpdart.dart';
import '../entities/lock_failure.dart';
import '../entities/lock_type.dart';
import '../repositories/app_lock_repository.dart';

/// Sets a new lock type, persisting whatever secret it requires.
class SetLockType {
  const SetLockType(this._repository);

  final AppLockRepository _repository;

  TaskEither<LockFailure, Unit> call({
    required LockType type,
    String? pin,
    String? question,
    String? answer,
  }) {
    return _repository.setLockType(
      type: type,
      pin: pin,
      question: question,
      answer: answer,
    );
  }
}
