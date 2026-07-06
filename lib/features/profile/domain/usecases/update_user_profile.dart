// lib/features/profile/domain/usecases/update_user_profile.dart

import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/user_profile.dart';
import '../repositories/profile_repository.dart';

/// Persists changes to the user's profile.
///
/// Usage: `await updateUserProfile(updatedProfile)`.
class UpdateUserProfile {
  final ProfileRepository repository;

  const UpdateUserProfile(this.repository);

  Future<Either<Failure, UserProfile>> call(UserProfile profile) {
    return repository.updateUserProfile(profile);
  }
}