// lib/features/profile/domain/repositories/profile_repository.dart

import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/user_profile.dart';

/// Contract for reading/writing the single [UserProfile] row.
abstract class ProfileRepository {
  /// Returns the current profile, or [UserProfile.empty] if no row has
  /// been written yet.
  Future<Either<Failure, UserProfile>> getUserProfile();

  /// Upserts the given [profile] as the singleton row.
  Future<Either<Failure, UserProfile>> updateUserProfile(UserProfile profile);
}