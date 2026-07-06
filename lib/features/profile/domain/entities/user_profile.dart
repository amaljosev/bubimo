// lib/features/profile/domain/entities/user_profile.dart

import 'package:equatable/equatable.dart';

/// The user's personalization profile — a single row in `user_profile`.
///
/// Every field beyond [id] is intentionally optional: the Profile &
/// Analytics screen must render sensibly with none of them set (falling
/// back to a generic avatar icon, "My Diary" label, and themed gradient
/// header), since filling them out is entirely optional for the user.
class UserProfile extends Equatable {
  final String id;
  final String? username;
  final String? diaryName;
  final String? avatarPath;
  final String? headerImagePath;
  final bool onboardingCompleted;

  const UserProfile({
    required this.id,
    this.username,
    this.diaryName,
    this.avatarPath,
    this.headerImagePath,
    this.onboardingCompleted = false,
  });

  /// A profile with no personalization set yet — used when no row exists
  /// in the database (e.g. first-ever app launch before onboarding
  /// writes anything).
  factory UserProfile.empty(String id) => UserProfile(id: id);

  UserProfile copyWith({
    String? username,
    bool clearUsername = false,
    String? diaryName,
    bool clearDiaryName = false,
    String? avatarPath,
    bool clearAvatarPath = false,
    String? headerImagePath,
    bool clearHeaderImagePath = false,
    bool? onboardingCompleted,
  }) {
    return UserProfile(
      id: id,
      username: clearUsername ? null : (username ?? this.username),
      diaryName: clearDiaryName ? null : (diaryName ?? this.diaryName),
      avatarPath: clearAvatarPath ? null : (avatarPath ?? this.avatarPath),
      headerImagePath: clearHeaderImagePath
          ? null
          : (headerImagePath ?? this.headerImagePath),
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
    );
  }

  @override
  List<Object?> get props => [
        id,
        username,
        diaryName,
        avatarPath,
        headerImagePath,
        onboardingCompleted,
      ];
}