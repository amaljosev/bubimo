// lib/features/reminders/presentation/bloc/reminder_settings/reminder_settings_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/usecases/cancel_reminder.dart';
import '../../../domain/usecases/check_reminder_permissions.dart';
import '../../../domain/usecases/get_reminder_settings.dart';
import '../../../domain/usecases/set_reminder.dart';
import 'reminder_settings_event.dart';
import 'reminder_settings_state.dart';

class ReminderSettingsBloc
    extends Bloc<ReminderSettingsEvent, ReminderSettingsState> {
  final GetReminderSettings getReminderSettings;
  final SetReminder setReminder;
  final CancelReminder cancelReminder;
  final CheckReminderPermissions checkReminderPermissions;
  final RequestReminderPermissions requestReminderPermissions;

  ReminderSettingsBloc({
    required this.getReminderSettings,
    required this.setReminder,
    required this.cancelReminder,
    required this.checkReminderPermissions,
    required this.requestReminderPermissions,
  }) : super(const ReminderSettingsState()) {
    on<LoadReminderSettings>(_onLoad);
    on<ReminderTimeSet>(_onTimeSet);
    on<ReminderCancelled>(_onCancelled);
    on<ReminderPermissionsChecked>(_onPermissionsChecked);
    on<ReminderPermissionsRequested>(_onPermissionsRequested);
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

    // Passive check runs after load completes regardless of outcome —
    // the banner should still reflect real permission status even if
    // the settings load itself failed.
    await _onPermissionsChecked(
      const ReminderPermissionsChecked(),
      emit,
    );
  }

  Future<void> _onTimeSet(
    ReminderTimeSet event,
    Emitter<ReminderSettingsState> emit,
  ) async {
    // Guard against overlapping updates from rapid repeated taps.
    if (state.isUpdating) return;

    emit(state.copyWith(status: ReminderSettingsStatus.updating));

    // Re-check (not request) immediately before scheduling — cheap,
    // and covers the case where a permission was revoked from system
    // Settings since the last check ran. We do NOT prompt here: a
    // silent OS dialog appearing mid-toggle is surprising, and the
    // explicit "Allow" tap on the banner (ReminderPermissionsRequested)
    // is the one place we intentionally trigger a system prompt.
    final permissionResult = await checkReminderPermissions();

    final ReminderPermissionStatus? permissionStatus = permissionResult.fold(
      (failure) => null,
      (status) => status,
    );

    if (permissionStatus != null && !permissionStatus.allGranted) {
      // Don't schedule a notification that can't fire. Persist the
      // enabled+time choice so the toggle UI reflects what the user
      // asked for, but leave actually scheduling to happen once
      // permissions are granted — re-entering this same event after a
      // successful ReminderPermissionsRequested will retry scheduling.
      emit(
        state.copyWith(
          status: ReminderSettingsStatus.loaded,
          time: event.time,
          enabled: true,
          permissionStatus: () => permissionStatus,
        ),
      );
      return;
    }

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
          permissionStatus: () => permissionStatus,
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

  Future<void> _onPermissionsChecked(
    ReminderPermissionsChecked event,
    Emitter<ReminderSettingsState> emit,
  ) async {
    final result = await checkReminderPermissions();

    result.match(
      // A failed check is treated as "unknown" rather than surfacing
      // a separate error state — the banner simply stays hidden
      // (permissionStatus stays at its previous value) rather than
      // competing with the load/update failure messaging above.
      (_) {},
      (status) => emit(
        state.copyWith(permissionStatus: () => status),
      ),
    );
  }

  Future<void> _onPermissionsRequested(
    ReminderPermissionsRequested event,
    Emitter<ReminderSettingsState> emit,
  ) async {
    final result = await requestReminderPermissions();

    final ReminderPermissionStatus? status = result.fold(
      (failure) => state.permissionStatus,
      (newStatus) => newStatus,
    );

    emit(state.copyWith(permissionStatus: () => status));

    // If the user just granted what was missing AND a time is already
    // selected (they'd toggled the switch on before hitting the
    // permission wall), finish the job by scheduling now rather than
    // requiring a second tap of the switch.
    if (status != null && status.allGranted && state.enabled) {
      final time = state.time;
      if (time != null) {
        await _onTimeSet(ReminderTimeSet(time), emit);
      }
    }
  }
}