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


  static const List<String> _monthNamesLong = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];

  static const List<String> _monthNamesShort = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  static const List<String> _weekdayNamesShort = [
    'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun',
  ];

  /// Full month name, e.g. `monthNameLong(7)` -> `'July'`.
  static String monthNameLong(int month) => _monthNamesLong[month - 1];

  /// Three-letter month abbreviation, e.g. `monthNameShort(7)` -> `'Jul'`.
  static String monthNameShort(int month) => _monthNamesShort[month - 1];

  /// Three-letter uppercase month abbreviation for compact date tiles,
  /// e.g. `monthAbbrUpper(7)` -> `'JUL'`.
  static String monthAbbrUpper(int month) => _monthNamesShort[month - 1].toUpperCase();

  /// Three-letter weekday abbreviation. `weekday` is 1 (Monday) - 7
  /// (Sunday), matching [DateTime.weekday].
  static String weekdayNameShort(int weekday) => _weekdayNamesShort[weekday - 1];

  /// Strips the time-of-day component, leaving just year/month/day.
  /// Use this before comparing or grouping by calendar day.
  static DateTime dateOnly(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  /// UTC-normalized calendar day — used specifically where a calendar
  /// widget (e.g. `table_calendar`) requires UTC dates for comparison,
  /// as opposed to [dateOnly] which keeps local time semantics.
  static DateTime dateOnlyUtc(DateTime date) =>
      DateTime.utc(date.year, date.month, date.day);

  /// Whether [a] and [b] fall on the same calendar day (ignoring time
  /// of day and independent of UTC/local).
  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  /// Whether [date] is today's calendar day.
  static bool isToday(DateTime date) => isSameDay(date, DateTime.now());

  /// Zero-padded two-digit day number, e.g. `'07'`.
  static String dayOfMonthPadded(DateTime date) =>
      date.day.toString().padLeft(2, '0');

  /// `"07"` — alias kept for call sites that previously used
  /// `intl.DateFormat('dd')`.
  static String formatDD(DateTime date) => dayOfMonthPadded(date);

  /// `"Wed"` — alias kept for call sites that previously used
  /// `intl.DateFormat('EE')`.
  static String formatEE(DateTime date) => weekdayNameShort(date.weekday);

  /// `"Jul, 2026"` — alias kept for call sites that previously used
  /// `intl.DateFormat('MMM, yyyy')`.
  static String formatMMMYyyy(DateTime date) =>
      '${monthNameShort(date.month)}, ${date.year}';

  /// `"yyyy-MM"` grouping key, e.g. `'2026-07'` — used to bucket
  /// entries by month (Favorites screen's collapsible sections).
  static String monthKey(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}';

  /// Reconstructs a human label from a [monthKey], e.g.
  /// `monthKeyLabel('2026-07')` -> `'July 2026'`.
  static String monthKeyLabel(String key) {
    final parts = key.split('-');
    final year = parts[0];
    final month = int.parse(parts[1]);
    return '${monthNameLong(month)} $year';
  }

  /// The friendly display string used on the full entry-view page,
  /// e.g. `'Wed, Jul 08, 2026'`.
  static String toDisplayString(DateTime date) =>
      '${weekdayNameShort(date.weekday)}, ${monthNameShort(date.month)} '
      '${dayOfMonthPadded(date)}, ${date.year}';
}