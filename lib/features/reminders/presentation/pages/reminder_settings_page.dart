// lib/features/reminders/presentation/pages/reminder_settings_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/widgets/error_screen.dart';
import '../../../../core/widgets/loading_screen.dart';
import '../../domain/usecases/get_reminder_settings.dart';
import '../bloc/reminder_settings/reminder_settings_bloc.dart';
import '../bloc/reminder_settings/reminder_settings_event.dart';
import '../bloc/reminder_settings/reminder_settings_state.dart';

/// The Reminders tab's content. Its [ReminderSettingsBloc] is provided by
/// [MainShell] (created once, kept alive across tab switches) — this
/// widget only consumes it, it does not create it.
class ReminderSettingsPage extends StatelessWidget {
  const ReminderSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _ReminderSettingsView();
  }
}

class _ReminderSettingsView extends StatelessWidget {
  const _ReminderSettingsView();

  String _formatTime(ReminderTime? time) {
    if (time == null) return 'Not set';
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Future<void> _pickTime(BuildContext context, ReminderTime? current) async {
    final initial = current != null
        ? TimeOfDay(hour: current.hour, minute: current.minute)
        : TimeOfDay.now();

    final picked =
        await showTimePicker(context: context, initialTime: initial);

    if (picked != null && context.mounted) {
      context.read<ReminderSettingsBloc>().add(
            ReminderTimeSet(
              ReminderTime(hour: picked.hour, minute: picked.minute),
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    // No Scaffold/AppBar here — MainShell provides both.
    return BlocBuilder<ReminderSettingsBloc, ReminderSettingsState>(
      builder: (context, state) {
        if (state.status == ReminderSettingsStatus.initial ||
            state.status == ReminderSettingsStatus.loading) {
          return const LoadingScreen();
        }

        if (state.status == ReminderSettingsStatus.failure &&
            state.time == null) {
          return ErrorScreen(
            message: state.errorMessage ?? 'Something went wrong.',
            onRetry: () => context
                .read<ReminderSettingsBloc>()
                .add(const LoadReminderSettings()),
          );
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: SwitchListTile(
                title: const Text('Daily reminder'),
                subtitle: Text(
                  state.enabled
                      ? 'Reminding you at ${_formatTime(state.time)}'
                      : 'Off',
                ),
                value: state.enabled,
                onChanged: state.isUpdating
                    ? null
                    : (value) {
                        if (value) {
                          _pickTime(context, state.time);
                        } else {
                          context
                              .read<ReminderSettingsBloc>()
                              .add(const ReminderCancelled());
                        }
                      },
              ),
            ),
            if (state.enabled) ...[
              const SizedBox(height: 8),
              ListTile(
                leading: const Icon(Icons.access_time),
                title: const Text('Reminder time'),
                trailing: Text(_formatTime(state.time)),
                onTap: state.isUpdating
                    ? null
                    : () => _pickTime(context, state.time),
              ),
            ],
            if (state.status == ReminderSettingsStatus.failure &&
                state.errorMessage != null) ...[
              const SizedBox(height: 12),
              Text(
                state.errorMessage!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
          ],
        );
      },
    );
  }
}