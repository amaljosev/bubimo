// lib/features/reminders/presentation/bloc/reminder_settings/reminder_settings_event.dart

import 'package:equatable/equatable.dart';

import '../../../domain/usecases/get_reminder_settings.dart';

sealed class ReminderSettingsEvent extends Equatable {
  const ReminderSettingsEvent();

  @override
  List<Object?> get props => [];
}

/// Loads the currently saved reminder time/enabled state. Fired once on
/// screen init.
final class LoadReminderSettings extends ReminderSettingsEvent {
  const LoadReminderSettings();
}

/// Fired when the user picks a time and the reminder is (or becomes)
/// enabled — persists the time and schedules the notification.
final class ReminderTimeSet extends ReminderSettingsEvent {
  final ReminderTime time;

  const ReminderTimeSet(this.time);

  @override
  List<Object?> get props => [time];
}

/// Fired when the user toggles the enable/disable switch off.
final class ReminderCancelled extends ReminderSettingsEvent {
  const ReminderCancelled();
}