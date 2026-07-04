// lib/features/reminders/domain/usecases/set_reminder.dart

import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../data/datasources/local_notification_service.dart';
import 'get_reminder_settings.dart';

/// Persists the reminder time as enabled, and schedules the daily
/// repeating local notification to fire at that time.
///
/// Usage: `await setReminder(ReminderTime(hour: 20, minute: 0))`.
class SetReminder {
  final LocalNotificationService notificationService;

  const SetReminder(this.notificationService);

  Future<Either<Failure, void>> call(ReminderTime time) async {
    try {
      await notificationService.saveSettings(time: time, enabled: true);
      await notificationService.scheduleDailyReminder(time);
      return const Right(null);
    } catch (e) {
      return Left(UnexpectedFailure('Failed to set reminder: $e'));
    }
  }
}