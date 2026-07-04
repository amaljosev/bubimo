// lib/features/reminders/presentation/bloc/reminder_settings/reminder_settings_state.dart

import 'package:equatable/equatable.dart';

import '../../../domain/usecases/get_reminder_settings.dart';

enum ReminderSettingsStatus { initial, loading, loaded, updating, failure }

class ReminderSettingsState extends Equatable {
  final ReminderSettingsStatus status;
  final ReminderTime? time;
  final bool enabled;
  final String? errorMessage;

  const ReminderSettingsState({
    this.status = ReminderSettingsStatus.initial,
    this.time,
    this.enabled = false,
    this.errorMessage,
  });

  bool get isUpdating => status == ReminderSettingsStatus.updating;

  ReminderSettingsState copyWith({
    ReminderSettingsStatus? status,
    ReminderTime? time,
    bool? enabled,
    String? errorMessage,
  }) {
    return ReminderSettingsState(
      status: status ?? this.status,
      time: time ?? this.time,
      enabled: enabled ?? this.enabled,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, time, enabled, errorMessage];
}