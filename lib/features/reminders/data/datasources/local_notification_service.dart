// lib/features/reminders/data/datasources/local_notification_service.dart

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../../../../core/database/app_database.dart';
import '../../../../core/database/tables/app_settings_table.dart';
import '../../domain/usecases/get_reminder_settings.dart';

/// Handles both the OS-level local notification scheduling AND the
/// persistence of reminder settings in `app_settings` — combined into
/// one class since the original feature plan lists a single data file
/// for reminders.
///
/// Requires `flutter_local_notifications` and `timezone` packages
/// (not in the original locked dependency list), plus Android's
/// `POST_NOTIFICATIONS` permission (Android 13+) declared in the
/// manifest.
class LocalNotificationService {
  final AppDatabase appDatabase;
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  /// Fixed notification id — there is only ever one diary reminder, so
  /// scheduling a new one always replaces the previous one at this id.
  static const int _reminderNotificationId = 1001;

  LocalNotificationService(this.appDatabase);

  /// Initializes the plugin and timezone data. Call once during app
  /// startup, before scheduling anything.
  Future<void> initialize() async {
    tz_data.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const initSettings = InitializationSettings(android: androidSettings);

    await _plugin.initialize(initSettings);

    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
  }

  /// Schedules (or replaces) the daily repeating reminder notification
  /// at [time].
  Future<void> scheduleDailyReminder(ReminderTime time) async {
    final scheduledDate = _nextInstanceOfTime(time);

    await _plugin.zonedSchedule(
      _reminderNotificationId,
      'Time to write',
      'How was your day? Capture it in your diary.',
      scheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'diary_reminder_channel',
          'Diary Reminders',
          channelDescription: 'Daily reminder to write a diary entry',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  /// Cancels the scheduled daily reminder notification, if any.
  Future<void> cancelReminder() async {
    await _plugin.cancel(_reminderNotificationId);
  }

  /// Persists reminder settings to the singleton `app_settings` row.
  /// If [time] is null, the stored `reminder_time` column is left
  /// unchanged — only [enabled] is updated. This lets
  /// `CancelReminder` disable the reminder without losing the
  /// previously chosen time.
  Future<void> saveSettings({
    required ReminderTime? time,
    required bool enabled,
  }) async {
    final db = await appDatabase.database;

    final values = <String, Object?>{
      AppSettingsTable.columnReminderEnabled: enabled ? 1 : 0,
    };
    if (time != null) {
      values[AppSettingsTable.columnReminderTime] = time.toStorageString();
    }

    final rowsAffected = await db.update(
      AppSettingsTable.tableName,
      values,
      where: '${AppSettingsTable.columnId} = ?',
      whereArgs: [AppSettingsTable.singletonId],
    );

    if (rowsAffected == 0) {
      // Singleton settings row doesn't exist yet (fresh install).
      await db.insert(AppSettingsTable.tableName, {
        AppSettingsTable.columnId: AppSettingsTable.singletonId,
        AppSettingsTable.columnLockType: AppSettingsTable.defaultLockType,
        AppSettingsTable.columnLockTimeoutMinutes:
            AppSettingsTable.defaultLockTimeoutMinutes,
        ...values,
      });
    }
  }

  /// Reads the currently saved reminder settings.
  Future<ReminderSettings> getSettings() async {
    final db = await appDatabase.database;
    final rows = await db.query(
      AppSettingsTable.tableName,
      columns: [
        AppSettingsTable.columnReminderTime,
        AppSettingsTable.columnReminderEnabled,
      ],
      where: '${AppSettingsTable.columnId} = ?',
      whereArgs: [AppSettingsTable.singletonId],
      limit: 1,
    );

    if (rows.isEmpty) {
      return const ReminderSettings(time: null, enabled: false);
    }

    final row = rows.first;
    return ReminderSettings(
      time: ReminderTime.fromStorageString(
        row[AppSettingsTable.columnReminderTime] as String?,
      ),
      enabled: (row[AppSettingsTable.columnReminderEnabled] as int? ?? 0) == 1,
    );
  }

  /// Computes the next occurrence of [time] in the device's local
  /// timezone — today if that time hasn't passed yet, otherwise
  /// tomorrow. `matchDateTimeComponents: DateTimeComponents.time` in
  /// [scheduleDailyReminder] then makes it repeat daily from there.
  tz.TZDateTime _nextInstanceOfTime(ReminderTime time) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    return scheduled;
  }
}
