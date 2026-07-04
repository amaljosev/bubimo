// lib/features/reminders/presentation/bloc/reminder_settings/reminder_settings_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/usecases/cancel_reminder.dart';
import '../../../domain/usecases/get_reminder_settings.dart';
import '../../../domain/usecases/set_reminder.dart';
import 'reminder_settings_event.dart';
import 'reminder_settings_state.dart';

class ReminderSettingsBloc
    extends Bloc<ReminderSettingsEvent, ReminderSettingsState> {
  final GetReminderSettings getReminderSettings;
  final SetReminder setReminder;
  final CancelReminder cancelReminder;

  ReminderSettingsBloc({
    required this.getReminderSettings,
    required this.setReminder,
    required this.cancelReminder,
  }) : super(const ReminderSettingsState()) {
    on<LoadReminderSettings>(_onLoad);
    on<ReminderTimeSet>(_onTimeSet);
    on<ReminderCancelled>(_onCancelled);
  }

  Future<void> _onLoad(
    LoadReminderSettings event,
    Emitter<ReminderSettingsState> emit,
  ) async {
    emit(state.copyWith(status: ReminderSettingsStatus.loading));

    final result = await getReminderSettings();

    result.match(
      (failure) => emit(
        state.copyWith(
          status: ReminderSettingsStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (settings) => emit(
        state.copyWith(
          status: ReminderSettingsStatus.loaded,
          time: settings.time,
          enabled: settings.enabled,
        ),
      ),
    );
  }

  Future<void> _onTimeSet(
    ReminderTimeSet event,
    Emitter<ReminderSettingsState> emit,
  ) async {
    // Guard against overlapping updates from rapid repeated taps.
    if (state.isUpdating) return;

    emit(state.copyWith(status: ReminderSettingsStatus.updating));

    final result = await setReminder(event.time);

    result.match(
      (failure) => emit(
        state.copyWith(
          status: ReminderSettingsStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (_) => emit(
        state.copyWith(
          status: ReminderSettingsStatus.loaded,
          time: event.time,
          enabled: true,
        ),
      ),
    );
  }

  Future<void> _onCancelled(
    ReminderCancelled event,
    Emitter<ReminderSettingsState> emit,
  ) async {
    if (state.isUpdating) return;

    emit(state.copyWith(status: ReminderSettingsStatus.updating));

    final result = await cancelReminder();

    result.match(
      (failure) => emit(
        state.copyWith(
          status: ReminderSettingsStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (_) => emit(
        state.copyWith(
          status: ReminderSettingsStatus.loaded,
          enabled: false,
        ),
      ),
    );
  }
}