// lib/features/reminders/domain/usecases/get_reminder_settings.dart

import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../data/datasources/local_notification_service.dart';

/// A time-of-day value, kept Flutter-framework-agnostic (no
/// `TimeOfDay`) so it stays usable from the domain layer.
class ReminderTime extends Equatable {
  final int hour;
  final int minute;

  const ReminderTime({required this.hour, required this.minute});

  /// Formats as `HH:mm` for storage in `app_settings.reminder_time`.
  String toStorageString() =>
      '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';

  static ReminderTime? fromStorageString(String? value) {
    if (value == null || value.isEmpty) return null;
    final parts = value.split(':');
    if (parts.length != 2) return null;
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return null;
    return ReminderTime(hour: hour, minute: minute);
  }

  @override
  List<Object?> get props => [hour, minute];
}

class ReminderSettings extends Equatable {
  final ReminderTime? time;
  final bool enabled;

  const ReminderSettings({required this.time, required this.enabled});

  @override
  List<Object?> get props => [time, enabled];
}

/// Loads the currently saved reminder time and enabled state, for the
/// Reminder Settings screen to display on open.
///
/// Not present in the original feature plan — added because the
/// settings screen needs a way to show the current state, which
/// `SetReminder`/`CancelReminder` alone don't provide.
///
/// Usage: `await getReminderSettings()`.
class GetReminderSettings {
  final LocalNotificationService notificationService;

  const GetReminderSettings(this.notificationService);

  Future<Either<Failure, ReminderSettings>> call() async {
    try {
      final settings = await notificationService.getSettings();
      return Right(settings);
    } catch (e) {
      return Left(DatabaseFailure('Failed to load reminder settings: $e'));
    }
  }
}