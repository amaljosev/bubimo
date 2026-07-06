// lib/features/profile/presentation/cubit/profile_cubit.dart

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/user_profile.dart';
import '../../domain/usecases/get_user_profile.dart';
import '../../domain/usecases/update_user_profile.dart';
import 'profile_state.dart';

/// A Cubit (not a Bloc) since profile management is simple load/update
/// with no branching event types — unlike AnalyticsBloc, which fans out
/// into five concurrent metric loads.
class ProfileCubit extends Cubit<ProfileState> {
  final GetUserProfile getUserProfile;
  final UpdateUserProfile updateUserProfile;

  ProfileCubit({
    required this.getUserProfile,
    required this.updateUserProfile,
  }) : super(const ProfileState());

  Future<void> loadProfile() async {
    emit(state.copyWith(status: ProfileStatus.loading));

    final result = await getUserProfile();

    result.match(
      (failure) => emit(
        state.copyWith(
          status: ProfileStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (profile) => emit(
        state.copyWith(status: ProfileStatus.loaded, profile: profile),
      ),
    );
  }

  /// Saves an updated profile. Any field left null in [updated] is
  /// treated as "no change" by the caller (the edit sheet builds
  /// [updated] from the current profile plus edited fields), so this
  /// simply persists whatever entity it's given.
  Future<void> saveProfile(UserProfile updated) async {
    final previous = state.profile;
    emit(state.copyWith(status: ProfileStatus.saving, profile: updated));

    final result = await updateUserProfile(updated);

    result.match(
      (failure) => emit(
        state.copyWith(
          status: ProfileStatus.failure,
          profile: previous,
          errorMessage: failure.message,
        ),
      ),
      (saved) =>
          emit(state.copyWith(status: ProfileStatus.loaded, profile: saved)),
    );
  }
}