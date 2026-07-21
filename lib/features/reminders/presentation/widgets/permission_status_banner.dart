// lib/features/reminders/presentation/widgets/permission_status_banner.dart

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../domain/usecases/check_reminder_permissions.dart';

/// Persistent status section shown on the Reminder Settings screen
/// whenever the daily reminder is on but a required Android
/// permission is missing.
///
/// Deliberately renders nothing (`SizedBox.shrink()`) rather than a
/// "all good" success banner when everything is granted — a banner
/// that's only ever present to report a problem is a clearer signal
/// than one that's always there and just changes color.
class PermissionStatusBanner extends StatelessWidget {
  final ReminderPermissionStatus status;

  /// Called when the user taps "Allow" — the caller dispatches
  /// `ReminderPermissionsRequested` and does not otherwise know or
  /// care how the banner is drawn.
  final VoidCallback onRequestPermissions;

  const PermissionStatusBanner({
    super.key,
    required this.status,
    required this.onRequestPermissions,
  });

  @override
  Widget build(BuildContext context) {
    if (status.allGranted) return const SizedBox.shrink();

    final colorScheme = Theme.of(context).colorScheme;
    final notificationsMissing =
        status.notifications != PermissionState.granted;
    final exactAlarmsMissing = !status.exactAlarmsGranted;

    final missing = <String>[
      if (notificationsMissing) 'Notifications',
      if (exactAlarmsMissing) 'Exact alarms',
    ];

    // Exact-alarm-only is a milder situation than notifications being
    // missing entirely (the reminder will still fire, just with
    // possible drift), so it gets a less alarming tone/icon than a
    // full notifications-blocked banner.
    final isDegradedOnly = !notificationsMissing && exactAlarmsMissing;

    final description = notificationsMissing
        ? 'Without this, the reminder can\'t show at all.'
        : 'The reminder will still fire, but its timing may drift by a '
              'few minutes since exact scheduling isn\'t allowed.';

    return Card(
      color: isDegradedOnly
          ? colorScheme.surfaceContainerHighest
          : colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isDegradedOnly
                      ? Icons.info_outline
                      : Icons.notifications_off_outlined,
                  color: isDegradedOnly
                      ? colorScheme.onSurfaceVariant
                      : colorScheme.onErrorContainer,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${missing.join(' and ')} permission'
                    '${missing.length > 1 ? 's' : ''} needed',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: isDegradedOnly
                          ? colorScheme.onSurfaceVariant
                          : colorScheme.onErrorContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: isDegradedOnly
                    ? colorScheme.onSurfaceVariant
                    : colorScheme.onErrorContainer,
              ),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              // mustOpenSettings reflects the notification permission
              // only — exact-alarm access has no "permanently denied"
              // state (it's a toggleable special-access setting, not a
              // runtime dialog) and can always be re-requested in-app,
              // so it never alone forces the Settings deep-link. See
              // ReminderPermissionStatus.mustOpenSettings's doc comment.
              child: status.mustOpenSettings
                  ? FilledButton.tonal(
                      onPressed: openAppSettings,
                      child: const Text('Open app settings'),
                    )
                  : FilledButton.tonal(
                      onPressed: onRequestPermissions,
                      child: const Text('Allow'),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}