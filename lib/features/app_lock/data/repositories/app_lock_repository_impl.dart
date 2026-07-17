// lib/features/app_lock/data/repositories/app_lock_repository_impl.dart

import 'package:fpdart/fpdart.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/hashing_utils.dart';
import '../../domain/entities/lock_method.dart';
import '../../domain/entities/security_question.dart';
import '../../domain/repositories/app_lock_repository.dart';
import '../datasources/app_lock_local_datasource.dart';

class AppLockRepositoryImpl implements AppLockRepository {
  final AppLockLocalDataSource localDataSource;

  AppLockRepositoryImpl(this.localDataSource);

  @override
  Future<Either<Failure, LockMethod>> getActiveLockMethod() async {
    try {
      final settings = await localDataSource.getLockSettings();
      return Right(settings.lockMethod);
    } on AppDatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(DatabaseFailure('Failed to read lock settings: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> setActiveLockMethod(LockMethod method) async {
    try {
      await localDataSource.setActiveLockMethod(method.dbValue);
      return const Right(unit);
    } on AppDatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(DatabaseFailure('Failed to set lock method: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> disableLock() async {
    try {
      await localDataSource.disableLock();
      return const Right(unit);
    } on AppDatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(DatabaseFailure('Failed to disable lock: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> setPin(String pin) async {
    try {
      await localDataSource.setPin(pin);
      return const Right(unit);
    } on AppDatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(DatabaseFailure('Failed to set PIN: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> verifyPin(String pin) async {
    try {
      final settings = await localDataSource.getLockSettings();
      if (settings.pinHash == null) {
        return const Left(LockFailure('No PIN has been configured'));
      }
      return Right(HashingUtils.verify(pin, settings.pinHash!));
    } on AppDatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(DatabaseFailure('Failed to verify PIN: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> hasPinConfigured() async {
    try {
      final settings = await localDataSource.getLockSettings();
      return Right(settings.pinHash != null);
    } on AppDatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(DatabaseFailure('Failed to check PIN configuration: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> setPattern(String pattern) async {
    try {
      await localDataSource.setPattern(pattern);
      return const Right(unit);
    } on AppDatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(DatabaseFailure('Failed to set pattern: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> verifyPattern(String pattern) async {
    try {
      final settings = await localDataSource.getLockSettings();
      if (settings.patternHash == null) {
        return const Left(LockFailure('No pattern has been configured'));
      }
      return Right(HashingUtils.verify(pattern, settings.patternHash!));
    } on AppDatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(DatabaseFailure('Failed to verify pattern: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> hasPatternConfigured() async {
    try {
      final settings = await localDataSource.getLockSettings();
      return Right(settings.patternHash != null);
    } on AppDatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(
        DatabaseFailure('Failed to check pattern configuration: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, bool>> authenticateBiometric() async {
    try {
      final result = await localDataSource.authenticateBiometric();
      return Right(result);
    } on BiometricException catch (e) {
      return Left(BiometricFailure(e.message));
    } catch (e) {
      return Left(BiometricFailure('Biometric authentication error: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> isBiometricAvailable() async {
    try {
      final result = await localDataSource.isBiometricAvailable();
      return Right(result);
    } catch (e) {
      return Left(BiometricFailure('Failed to check biometric availability: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> authenticateDeviceCredential() async {
    try {
      final result = await localDataSource.authenticateDeviceCredential();
      return Right(result);
    } on BiometricException catch (e) {
      return Left(BiometricFailure(e.message));
    } catch (e) {
      return Left(
        BiometricFailure('Device credential authentication error: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, Unit>> setSecurityQuestion(
    SecurityQuestion question,
  ) async {
    try {
      await localDataSource.setSecurityQuestion(
        question: question.question,
        answerHash: question.answerHash,
      );
      return const Right(unit);
    } on AppDatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(DatabaseFailure('Failed to set security question: $e'));
    }
  }

  @override
  Future<Either<Failure, SecurityQuestion?>> getSecurityQuestion() async {
    try {
      final settings = await localDataSource.getLockSettings();
      return Right(settings.toSecurityQuestionEntity());
    } on AppDatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(DatabaseFailure('Failed to read security question: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> verifySecurityAnswer(String answer) async {
    try {
      final settings = await localDataSource.getLockSettings();
      if (settings.securityAnswerHash == null) {
        return const Left(
          LockFailure('No security question has been configured'),
        );
      }
      return Right(
        HashingUtils.verify(answer, settings.securityAnswerHash!),
      );
    } on AppDatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(DatabaseFailure('Failed to verify security answer: $e'));
    }
  }
}