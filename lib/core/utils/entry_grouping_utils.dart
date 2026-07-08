// lib/core/utils/entry_grouping_utils.dart

import 'date_utils.dart';

/// Groups a list of same-day-adjacent items into ordered day buckets.
///
/// Generic over [T] so it works for [DiaryEntry] without this file
/// depending on the diary_entry feature. Callers supply [dateOf] to
/// extract the date to group by.
class DayGroup<T> {
  const DayGroup({required this.date, required this.entries});

  final DateTime date;
  final List<T> entries;
}

/// Shared helpers for grouping/querying diary entries by date.
///
/// Consolidates logic that was previously duplicated (with slightly
/// different shapes) in:
///   - `HomePage._groupByDay` / `_isSameDay`
///   - `FavoritesPage._groupByMonthAndDay`
///   - `TimelinePage._entriesForDay` / `_markedDates` /
///     `_dayHasFavorite` / `_moodForDay`
abstract final class EntryGroupingUtils {
  /// Groups [items] into consecutive same-day buckets, preserving the
  /// original ordering. Assumes [items] arrive already sorted by date —
  /// this only collapses *adjacent* same-day items into one group, so
  /// a non-chronological list would produce duplicate date buckets if
  /// the same day appears in two non-adjacent runs.
  static List<DayGroup<T>> groupByDay<T>(
    List<T> items,
    DateTime Function(T item) dateOf,
  ) {
    final groups = <DayGroup<T>>[];

    for (final item in items) {
      final dayOnly = AppDateUtils.dateOnly(dateOf(item));

      if (groups.isNotEmpty && AppDateUtils.isSameDay(groups.last.date, dayOnly)) {
        groups.last.entries.add(item);
      } else {
        groups.add(DayGroup<T>(date: dayOnly, entries: [item]));
      }
    }

    return groups;
  }

  /// Groups [items] by month (`"yyyy-MM"` key, see [AppDateUtils.monthKey])
  /// and then by day within each month, with days sorted newest-first.
  /// Unlike [groupByDay], items do not need to already be sorted or
  /// adjacent — every item is bucketed by its own date regardless of
  /// position in the input list.
  static Map<String, Map<DateTime, List<T>>> groupByMonthAndDay<T>(
    List<T> items,
    DateTime Function(T item) dateOf,
  ) {
    final result = <String, Map<DateTime, List<T>>>{};

    for (final item in items) {
      final date = dateOf(item);
      final monthKey = AppDateUtils.monthKey(date);
      final dayOnly = AppDateUtils.dateOnly(date);

      final monthMap = result.putIfAbsent(monthKey, () => <DateTime, List<T>>{});
      monthMap.putIfAbsent(dayOnly, () => []).add(item);
    }

    for (final monthKey in result.keys) {
      final sortedDays = result[monthKey]!.keys.toList()
        ..sort((a, b) => b.compareTo(a));
      final sortedMap = <DateTime, List<T>>{};
      for (final day in sortedDays) {
        sortedMap[day] = result[monthKey]![day]!;
      }
      result[monthKey] = sortedMap;
    }

    return result;
  }

  /// All items in [items] whose date falls on [day] (calendar-day
  /// comparison, using [AppDateUtils.dateOnlyUtc] since callers of
  /// this method are typically driven by `table_calendar`, which
  /// operates on UTC dates).
  static List<T> itemsForDay<T>(
    DateTime day,
    List<T> items,
    DateTime Function(T item) dateOf,
  ) {
    final norm = AppDateUtils.dateOnlyUtc(day);
    return items.where((e) => AppDateUtils.dateOnlyUtc(dateOf(e)) == norm).toList();
  }

  /// The set of calendar days (UTC-normalized) that have at least one
  /// item, for driving calendar "has entry" markers.
  static Set<DateTime> markedDays<T>(
    List<T> items,
    DateTime Function(T item) dateOf,
  ) {
    return items.map((e) => AppDateUtils.dateOnlyUtc(dateOf(e))).toSet();
  }

  /// Whether any item on [day] satisfies [predicate] — e.g. "has a
  /// favorite entry on this day".
  static bool anyOnDay<T>(
    DateTime day,
    List<T> items,
    DateTime Function(T item) dateOf,
    bool Function(T item) predicate,
  ) {
    final norm = AppDateUtils.dateOnlyUtc(day);
    return items.any(
      (e) => AppDateUtils.dateOnlyUtc(dateOf(e)) == norm && predicate(e),
    );
  }

  /// The first non-null/non-empty value returned by [selector] among
  /// items on [day], or `null` if none. Used for "first mood emoji for
  /// this day" on the calendar cells.
  static R? firstOnDay<T, R>(
    DateTime day,
    List<T> items,
    DateTime Function(T item) dateOf,
    R? Function(T item) selector,
  ) {
    final norm = AppDateUtils.dateOnlyUtc(day);
    for (final item in items) {
      if (AppDateUtils.dateOnlyUtc(dateOf(item)) == norm) {
        final value = selector(item);
        if (value != null) return value;
      }
    }
    return null;
  }
}