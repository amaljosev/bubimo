// lib/features/profile/data/repositories/profile_repository_impl.dart

import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_local_data_source.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileLocalDataSource localDataSource;

  ProfileRepositoryImpl(this.localDataSource);

  @override
  Future<Either<Failure, UserProfile>> getUserProfile() async {
    try {
      final profile = await localDataSource.getUserProfile();
      return Right(profile);
    } catch (e) {
      return Left(CacheFailure( 'Failed to load profile: $e'));
    }
  }

  @override
  Future<Either<Failure, UserProfile>> updateUserProfile(
    UserProfile profile,
  ) async {
    try {
      final updated = await localDataSource.updateUserProfile(profile);
      return Right(updated);
    } catch (e) {
      return Left(CacheFailure( 'Failed to save profile: $e'));
    }
  }
}