// lib/features/reminders/presentation/bloc/reminder_settings/reminder_settings_event.dart

import 'package:equatable/equatable.dart';

import '../../../domain/usecases/get_reminder_settings.dart';

sealed class ReminderSettingsEvent extends Equatable {
  const ReminderSettingsEvent();

  @override
  List<Object?> get props => [];
}

/// Loads the currently saved reminder time/enabled state. Fired once on
/// screen init. Now also triggers an initial (passive) permission
/// check, since the banner needs to be accurate from first paint.
final class LoadReminderSettings extends ReminderSettingsEvent {
  const LoadReminderSettings();
}

/// Fired when the user picks a time and the reminder is (or becomes)
/// enabled — persists the time and schedules the notification.
///
/// The bloc checks permissions before acting on this: if either
/// permission is missing, scheduling is skipped and
/// [ReminderPermissionsRequested] is dispatched instead of silently
/// scheduling a notification that will never fire.
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

/// Passive re-check of notification/exact-alarm permission status —
/// does NOT prompt the OS dialog. Fired on screen init (as part of
/// [LoadReminderSettings]) and again whenever the app resumes from
/// the background (see `_ReminderSettingsView`'s
/// `WidgetsBindingObserver`), so the banner catches permissions
/// granted or revoked from system Settings while the app was away.
final class ReminderPermissionsChecked extends ReminderSettingsEvent {
  const ReminderPermissionsChecked();
}

/// Fired when the user taps "Allow" on the permission banner or retries
/// enabling the reminder after a missing permission was reported.
/// Triggers the actual OS request dialog(s). If the result is still
/// not fully granted AND the notification permission specifically is
/// permanently denied, the UI is expected to offer the Settings
/// deep-link (see `hasPermissionIssue` + `permissionStatus.mustOpenSettings`
/// on the state) rather than the bloc tracking a denial count itself.
final class ReminderPermissionsRequested extends ReminderSettingsEvent {
  const ReminderPermissionsRequested();
}