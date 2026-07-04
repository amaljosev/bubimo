// lib/core/utils/date_utils.dart

/// Date helpers used across the app for consistent storage format and
/// day-level comparisons (streaks, heatmap, "on this day" style features).
///
/// All dates are stored in the database as ISO 8601 strings via
/// [toStorageString]. Always go through these helpers instead of calling
/// `DateTime.toIso8601String()`/`DateTime.parse()` directly, so the format
/// stays consistent if it ever needs to change in one place.
class AppDateUtils {
  AppDateUtils._();

  /// Converts a [DateTime] to the string format stored in SQLite columns.
  static String toStorageString(DateTime date) => date.toIso8601String();

  /// Parses a stored date string back into a [DateTime].
  static DateTime fromStorageString(String value) => DateTime.parse(value);

  /// Returns [date] with time components stripped, for day-level equality
  /// checks (streaks, heatmap cells).
  static DateTime dateOnly(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  /// Whether [a] and [b] fall on the same calendar day.
  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  /// Whether [date] is "today" relative to the device clock.
  static bool isToday(DateTime date) => isSameDay(date, DateTime.now());

  /// Whether [date] is exactly one calendar day before [reference].
  static bool isDayBefore(DateTime date, DateTime reference) {
    final refDateOnly = dateOnly(reference);
    final expectedPrevious = refDateOnly.subtract(const Duration(days: 1));
    return isSameDay(date, expectedPrevious);
  }

  /// Generates the list of the last [days] calendar days (oldest first,
  /// today last) — used to build the 365-day heatmap grid.
  static List<DateTime> lastNDays(int days, {DateTime? endingOn}) {
    final end = dateOnly(endingOn ?? DateTime.now());
    return List.generate(
      days,
      (index) => end.subtract(Duration(days: days - 1 - index)),
    );
  }

  /// Human-readable format for display, e.g. "3 July 2026".
  static String toDisplayString(DateTime date) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}