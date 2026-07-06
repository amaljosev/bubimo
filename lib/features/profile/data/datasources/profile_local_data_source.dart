// lib/features/profile/data/datasources/profile_local_data_source.dart

import 'package:bubimo/core/database/tables/user_profile_table.dart';
import 'package:sqflite/sqflite.dart';

import '../../../../core/database/app_database.dart';
import '../../domain/entities/user_profile.dart';

/// Reads/writes the single `user_profile` row.
abstract class ProfileLocalDataSource {
  Future<UserProfile> getUserProfile();
  Future<UserProfile> updateUserProfile(UserProfile profile);
}

class ProfileLocalDataSourceImpl implements ProfileLocalDataSource {
  final AppDatabase appDatabase;

  ProfileLocalDataSourceImpl(this.appDatabase);

  @override
  Future<UserProfile> getUserProfile() async {
    final db = await appDatabase.database;
    final rows = await db.query(
      UserProfileTable.tableName,
      where: '${UserProfileTable.columnId} = ?',
      whereArgs: [UserProfileTable.singletonId],
      limit: 1,
    );

    if (rows.isEmpty) {
      // No row written yet (e.g. before onboarding ever ran) — return a
      // blank profile rather than inserting one speculatively; the row
      // gets created on first `updateUserProfile` call instead.
      return UserProfile.empty(UserProfileTable.singletonId);
    }

    return _fromRow(rows.first);
  }

  @override
  Future<UserProfile> updateUserProfile(UserProfile profile) async {
    final db = await appDatabase.database;
    final row = _toRow(profile);

    // Upsert: insert if the singleton row doesn't exist yet, otherwise
    // overwrite it in place.
    await db.insert(
      UserProfileTable.tableName,
      row,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    return profile;
  }

  UserProfile _fromRow(Map<String, Object?> row) {
    return UserProfile(
      id: row[UserProfileTable.columnId] as String,
      username: row[UserProfileTable.columnName] as String?,
      diaryName: row[UserProfileTable.columnDiaryName] as String?,
      avatarPath: row[UserProfileTable.columnAvatarPath] as String?,
      headerImagePath:
          row[UserProfileTable.columnHeaderImagePath] as String?,
      onboardingCompleted:
          (row[UserProfileTable.columnOnboardingCompleted] as int? ?? 0) == 1,
    );
  }

  Map<String, Object?> _toRow(UserProfile profile) {
    return {
      UserProfileTable.columnId: profile.id,
      UserProfileTable.columnName: profile.username,
      UserProfileTable.columnDiaryName: profile.diaryName,
      UserProfileTable.columnAvatarPath: profile.avatarPath,
      UserProfileTable.columnHeaderImagePath: profile.headerImagePath,
      UserProfileTable.columnOnboardingCompleted:
          profile.onboardingCompleted ? 1 : 0,
    };
  }
}