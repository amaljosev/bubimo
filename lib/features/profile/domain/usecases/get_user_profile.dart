// lib/features/profile/domain/usecases/get_user_profile.dart

import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/user_profile.dart';
import '../repositories/profile_repository.dart';

/// Loads the user's profile (photo, username, diary name, header image).
///
/// Usage: `await getUserProfile()`.
class GetUserProfile {
  final ProfileRepository repository;

  const GetUserProfile(this.repository);

  Future<Either<Failure, UserProfile>> call() {
    return repository.getUserProfile();
  }
}