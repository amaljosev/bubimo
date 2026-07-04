// lib/features/diary_entry/domain/entities/mood.dart

/// Mood options a user can attach to a diary entry.
///
/// Stored in the database as the enum's `name` string (via
/// [storageValue]/[fromStorageValue]) rather than an index, so reordering
/// this enum later never corrupts existing stored data.
enum Mood {
  happy,
  sad,
  excited,
  calm,
  angry,
  neutral;

  /// Emoji shown in pickers, list items, and the entry view screen.
  String get emoji {
    switch (this) {
      case Mood.happy:
        return '😄';
      case Mood.sad:
        return '😢';
      case Mood.excited:
        return '🤩';
      case Mood.calm:
        return '😌';
      case Mood.angry:
        return '😠';
      case Mood.neutral:
        return '😐';
    }
  }

  /// Display label shown alongside the emoji in pickers.
  String get label {
    switch (this) {
      case Mood.happy:
        return 'Happy';
      case Mood.sad:
        return 'Sad';
      case Mood.excited:
        return 'Excited';
      case Mood.calm:
        return 'Calm';
      case Mood.angry:
        return 'Angry';
      case Mood.neutral:
        return 'Neutral';
    }
  }

  /// Value written to the `mood` column.
  String get storageValue => name;

  /// Parses a stored `mood` column value back into a [Mood].
  ///
  /// Returns `null` for null/empty/unrecognized input rather than
  /// throwing, since mood is optional on an entry and old/corrupt data
  /// shouldn't crash the app.
  static Mood? fromStorageValue(String? value) {
    if (value == null || value.isEmpty) return null;
    for (final mood in Mood.values) {
      if (mood.storageValue == value) return mood;
    }
    return null;
  }
}