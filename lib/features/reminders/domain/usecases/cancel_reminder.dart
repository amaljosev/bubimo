// lib/features/reminders/domain/usecases/cancel_reminder.dart

import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../data/datasources/local_notification_service.dart';

/// Disables the reminder (persists `reminder_enabled = false` while
/// leaving the previously saved `reminder_time` untouched, so
/// re-enabling later doesn't lose it) and cancels the scheduled daily
/// notification.
///
/// Usage: `await cancelReminder()`.
class CancelReminder {
  final LocalNotificationService notificationService;

  const CancelReminder(this.notificationService);

  Future<Either<Failure, void>> call() async {
    try {
      // Passing time: null tells saveSettings to leave the stored time
      // column unchanged — only `enabled` is updated here.
      await notificationService.saveSettings(time: null, enabled: false);
      await notificationService.cancelReminder();
      return const Right(null);
    } catch (e) {
      return Left(UnexpectedFailure('Failed to cancel reminder: $e'));
    }
  }
}
