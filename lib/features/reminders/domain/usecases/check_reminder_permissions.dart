// lib/features/reminders/domain/usecases/check_reminder_permissions.dart

import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../core/error/failures.dart';
import '../../data/datasources/local_notification_service.dart';

/// Simplified tri-state for the notification permission specifically,
/// collapsing `permission_handler`'s richer [PermissionStatus] down to
/// the three states the Reminder Settings UI actually needs to branch
/// on.
///
/// This is used for [ReminderPermissionStatus.notifications] only.
/// Exact-alarm status is NOT modeled with this type — see
/// [ReminderPermissionStatus.exactAlarmsGranted] for why.
///
/// [permanentlyDenied] means the OS will no longer show its own
/// request dialog for this permission — the only way forward is
/// [openAppSettings]. `permission_handler` decides this for us (it
/// already tracks "has this been denied before with 'don't ask
/// again'"), so we never count denials ourselves.
enum PermissionState { granted, denied, permanentlyDenied }

extension on PermissionStatus {
  PermissionState toPermissionState() {
    if (isGranted || isLimited) return PermissionState.granted;
    if (isPermanentlyDenied) return PermissionState.permanentlyDenied;
    return PermissionState.denied;
  }
}

/// Live status of both permissions the daily reminder depends on.
///
/// The two permissions are modeled DIFFERENTLY on purpose, not with
/// one uniform [PermissionState] each:
///
/// - [notifications] is a genuine Android runtime permission
///   (`POST_NOTIFICATIONS`) with a real "permanently denied" state
///   (the user checked "don't ask again", or denied it enough times
///   that Android stops showing the dialog) — [PermissionState] fits
///   it correctly.
/// - [exactAlarmsGranted] is Android's "Alarms & reminders" special
///   app access — a toggle in system Settings, not a runtime
///   permission dialog. It has no OS-level "don't ask again" concept:
///   it's simply on or off, and can be flipped either way from
///   Settings at any time. Forcing it into a three-state shape would
///   invent a "permanently denied" state Android doesn't actually
///   have for it, so it's a plain bool instead.
///
/// Both matter independently: [notifications] denied means nothing
/// will show at all; [exactAlarmsGranted] false means notifications
/// may still fire but can drift by several minutes (inexact alarms)
/// since [LocalNotificationService.scheduleDailyReminder] uses
/// `AndroidScheduleMode.exactAllowWhileIdle`.
class ReminderPermissionStatus extends Equatable {
  final PermissionState notifications;
  final bool exactAlarmsGranted;

  const ReminderPermissionStatus({
    required this.notifications,
    required this.exactAlarmsGranted,
  });

  bool get allGranted =>
      notifications == PermissionState.granted && exactAlarmsGranted;

  /// True if the notification permission specifically can no longer
  /// be requested in-app and the user must be sent to system Settings.
  ///
  /// Deliberately does NOT factor in a missing exact-alarm grant: since
  /// that permission has no "permanently denied" state (see class doc),
  /// a user can always be re-prompted via
  /// [LocalNotificationService.requestExactAlarmsPermission] — there is
  /// no scenario where exact alarms alone force a Settings deep-link.
  bool get mustOpenSettings =>
      notifications == PermissionState.permanentlyDenied;

  @override
  List<Object?> get props => [notifications, exactAlarmsGranted];
}

/// Reads current OS-level permission status for notifications and
/// exact alarms, without prompting the user. Used to render the
/// status banner on screen open, before every schedule attempt, and
/// after the app resumes from Settings.
///
/// Requesting (which _does_ prompt) is a separate use case —
/// [RequestReminderPermissions] — since "check" and "request" have
/// different call sites: check runs passively and often, request runs
/// once in response to a tap.
///
/// Requires [LocalNotificationService] (not just `permission_handler`)
/// because the exact-alarm check specifically goes through
/// [LocalNotificationService.canScheduleExactAlarms] — see that
/// method's doc comment for why `permission_handler`'s equivalent
/// isn't used here.
///
/// Usage: `await checkReminderPermissions()`.
class CheckReminderPermissions {
  final LocalNotificationService notificationService;

  const CheckReminderPermissions(this.notificationService);

  Future<Either<Failure, ReminderPermissionStatus>> call() async {
    try {
      final notificationStatus = await Permission.notification.status;
      final canScheduleExact = await notificationService
          .canScheduleExactAlarms();

      return Right(
        ReminderPermissionStatus(
          notifications: notificationStatus.toPermissionState(),
          exactAlarmsGranted: canScheduleExact,
        ),
      );
    } catch (e) {
      return Left(UnexpectedFailure('Failed to check permissions: $e'));
    }
  }
}

/// Requests both permissions in sequence (notifications first, since
/// accepting it is the common case and Android shows at most one
/// system dialog at a time) and returns the resulting status.
///
/// The two permissions are requested AND checked through two
/// different APIs, not one uniform loop over `permission_handler`:
/// - Notifications: `permission_handler`'s `Permission.notification`
///   for both request and status — the standard, reliable path.
/// - Exact alarms: [LocalNotificationService.requestExactAlarmsPermission]
///   and [LocalNotificationService.canScheduleExactAlarms], both of
///   which go through `AndroidFlutterLocalNotificationsPlugin`
///   directly rather than `permission_handler`. Two independent
///   problems with `permission_handler` here, not just one:
///   `Permission.scheduleExactAlarm.request()` is widely reported as
///   unreliable at surfacing the system dialog, AND separately,
///   `Permission.scheduleExactAlarm.status` has a filed upstream bug
///   (Backflow/flutter-permission-handler#987) where it can report
///   `granted` when the OS actually has it denied — which previously
///   let this app's own scheduling call through and crash with
///   `PlatformException(exact_alarms_not_permitted)`. Routing both
///   the request and the check through the same plugin that performs
///   the actual scheduling avoids both problems by construction.
///
/// Deliberately does NOT call [SetReminder]/schedule anything itself
/// — the bloc decides what to do once it has the resulting
/// [ReminderPermissionStatus] (e.g. only proceed to schedule if
/// `allGranted`, or leave the reminder off with a banner explaining
/// why).
///
/// Usage: `await requestReminderPermissions()`.
class RequestReminderPermissions {
  final LocalNotificationService notificationService;

  const RequestReminderPermissions(this.notificationService);

  Future<Either<Failure, ReminderPermissionStatus>> call() async {
    try {
      // Only request what isn't already granted — re-requesting a
      // granted permission is a harmless no-op, but skipping it
      // avoids an unnecessary plugin call.
      if (!await Permission.notification.isGranted) {
        await Permission.notification.request();
      }
      if (!await notificationService.canScheduleExactAlarms()) {
        await notificationService.requestExactAlarmsPermission();
      }

      final notificationStatus = await Permission.notification.status;
      final canScheduleExact = await notificationService
          .canScheduleExactAlarms();

      return Right(
        ReminderPermissionStatus(
          notifications: notificationStatus.toPermissionState(),
          exactAlarmsGranted: canScheduleExact,
        ),
      );
    } catch (e) {
      return Left(UnexpectedFailure('Failed to request permissions: $e'));
    }
  }
}