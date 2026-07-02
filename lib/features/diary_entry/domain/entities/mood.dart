// lib/features/diary_entry/domain/entities/mood.dart

/// Represents the user's mood for a diary entry.
///
/// Nullable everywhere it's used (`Mood?`) — mood is optional, matching
/// Milestone 1's plain-text-only entries that predate this field. Existing
/// rows with no `mood` column value simply parse to `null` via
/// [Mood.fromStorageString].
enum Mood {
  happy,
  sad,
  excited,
  calm,
  angry,
  neutral;

  /// Emoji representation shown in the mood picker, list items, and the
  /// entry view screen.
  String get emoji {
    switch (this) {
      case Mood.happy:
        return '😊';
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

  /// Human-readable label, e.g. for accessibility (`Semantics`/tooltips)
  /// or future filter/analytics UI.
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

  /// Stable string stored in the `mood` TEXT column. Deliberately NOT
  /// `.name` used directly at call sites (though it happens to equal
  /// `.name` today) — routing storage through this getter means a future
  /// rename of an enum value won't silently change what's already stored
  /// in the database, since this can be overridden independently of the
  /// Dart identifier.
  String toStorageString() => name;

  /// Parses a stored `mood` column value back into a [Mood].
  ///
  /// Returns `null` for `null` input (no mood recorded) and for any
  /// unrecognized string (e.g. data from a future app version with mood
  /// values this version doesn't know about) — fails soft rather than
  /// throwing, since a corrupt/unknown mood shouldn't block loading the
  /// rest of the entry.
  static Mood? fromStorageString(String? value) {
    if (value == null) return null;
    for (final mood in Mood.values) {
      if (mood.toStorageString() == value) return mood;
    }
    return null;
  }
}