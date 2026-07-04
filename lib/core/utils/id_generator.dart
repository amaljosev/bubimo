// lib/core/utils/id_generator.dart

import 'dart:math';

/// Generates unique string IDs for new database rows (diary entries,
/// custom themes) without requiring an external `uuid` package dependency.
///
/// Format: `<millisecondsSinceEpoch>-<6 random alphanumeric chars>`.
/// This is sufficient for a single-user, single-device offline app —
/// collisions are effectively impossible for this use case.
class IdGenerator {
  IdGenerator._();

  static final Random _random = Random();
  static const String _chars =
      'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';

  /// Generates a new unique ID, e.g. "1751520000000-aZ3kQ9".
  static String generate() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final suffix = List.generate(
      6,
      (_) => _chars[_random.nextInt(_chars.length)],
    ).join();
    return '$timestamp-$suffix';
  }
}