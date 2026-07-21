// lib/features/backup/data/models/backup_diary_entry_model.dart

import '../../../diary_entry/domain/entities/diary_entry.dart';
import '../../../diary_entry/domain/entities/mood.dart';
import '../../../diary_entry/domain/entities/overlay_image.dart';
import '../../../diary_entry/domain/entities/sticker.dart';

/// JSON codec for [DiaryEntry] used ONLY by the backup/export bundle.
///
/// Deliberately separate from [DiaryEntryModel]'s `toMap`/`fromMap` —
/// those target sqlite's column shape (`TEXT`/`INTEGER` types, JSON-
/// encoded-as-a-string sub-fields) and are allowed to change whenever
/// the `diary_entries` table's schema changes. A backup file, once
/// created, has to stay readable by future app versions indefinitely —
/// coupling its format directly to the DB's column names/types would
/// mean a schema migration could silently break every backup a user
/// made before that migration shipped. This model's JSON shape is its
/// own independent contract, versioned by
/// `BackupManifest.formatVersion`, not by the DB schema version.
///
/// Path fields (`imagePath`, `overlayImages[].path`, etc.) are written
/// here EXACTLY as they exist on the source [DiaryEntry] — i.e. as this
/// device's absolute path. `BackupLocalDataSource` is responsible for
/// rewriting them to relative bundle paths before writing this JSON
/// into the archive, and rewriting them back to a fresh absolute path
/// on import. This model itself does no path manipulation.
class BackupDiaryEntryModel {
  const BackupDiaryEntryModel._();

  static Map<String, dynamic> toJson(DiaryEntry entry) {
    return {
      'id': entry.id,
      'title': entry.title,
      'date': entry.date.toIso8601String(),
      'content': entry.content,
      'preview': entry.preview,
      'mood': entry.mood?.storageValue,
      'imagePath': entry.imagePath,
      'bgColor': entry.bgColor,
      'bgImagePath': entry.bgImagePath,
      'bgGalleryImagePath': entry.bgGalleryImagePath,
      'bgLocalPath': entry.bgLocalPath,
      'bgOverlayOpacity': entry.bgOverlayOpacity,
      'bgOverlayColor': entry.bgOverlayColor,
      'images': entry.images,
      'tags': entry.tags,
      'overlayImages': entry.overlayImages.map((o) => o.toJson()).toList(),
      'stickers': entry.stickers.map((s) => s.toJson()).toList(),
      'wordCount': entry.wordCount,
      'fontFamily': entry.fontFamily,
      'isFavorite': entry.isFavorite,
      'createdAt': entry.createdAt.toIso8601String(),
      'updatedAt': entry.updatedAt.toIso8601String(),
      // isDeleted / deletedAt are deliberately NOT included — only
      // non-deleted entries are ever passed to this codec (see
      // `BackupLocalDataSource.createBackup`, which sources entries
      // from `GetAllDiaryEntries`, already filtered to exclude
      // soft-deleted rows), and a freshly imported entry should always
      // start as a normal, non-deleted entry regardless of what state
      // it happened to be in on the exporting device.
    };
  }

  /// Parses one entry record from `data/diary_entries.json`.
  ///
  /// [newId] is the freshly generated id this imported entry will use —
  /// see `BackupLocalDataSource.importBackup`'s doc comment for why
  /// every imported entry always gets a new id rather than reusing the
  /// one stored in the bundle. [resolvedPaths] maps every relative
  /// bundle media path referenced by this record (as originally written
  /// by [toJson]) to the fresh absolute path it was copied to on THIS
  /// device — already computed by the caller before this record is
  /// parsed, since resolving a path requires an async file-copy this
  /// synchronous parse step shouldn't perform itself.
  ///
  /// Throws [FormatException] on missing/invalid required fields, or
  /// [ArgumentError] if a path field references a bundle media path not
  /// present in [resolvedPaths] — both are caught by the caller and
  /// treated as "skip this one malformed record", not "abort the whole
  /// import" (see [ImportResult.skippedCount]).
  static DiaryEntry fromJson(
    Map<String, dynamic> json, {
    required String newId,
    required Map<String, String> resolvedPaths,
  }) {
    final date = json['date'];
    final createdAt = json['createdAt'];
    final updatedAt = json['updatedAt'];

    if (date is! String || DateTime.tryParse(date) == null) {
      throw const FormatException('Entry is missing a valid "date".');
    }
    if (createdAt is! String || DateTime.tryParse(createdAt) == null) {
      throw const FormatException('Entry is missing a valid "createdAt".');
    }
    if (updatedAt is! String || DateTime.tryParse(updatedAt) == null) {
      throw const FormatException('Entry is missing a valid "updatedAt".');
    }

    String? resolvePath(String? bundlePath) {
      if (bundlePath == null || bundlePath.isEmpty) return null;
      final resolved = resolvedPaths[bundlePath];
      if (resolved == null) {
        throw ArgumentError(
          'Entry references media path "$bundlePath" which was not '
          'found in the bundle\'s media/ directory.',
        );
      }
      return resolved;
    }

    final overlayImagesRaw = json['overlayImages'];
    final overlayImages = <OverlayImage>[];
    if (overlayImagesRaw is List) {
      for (final item in overlayImagesRaw) {
        if (item is! Map<String, dynamic>) continue;
        try {
          final bundlePath = item['path'] as String?;
          final resolved = resolvePath(bundlePath);
          if (resolved == null) continue;
          overlayImages.add(
            OverlayImage.fromJson({...item, 'path': resolved}),
          );
        } catch (_) {
          // Skip this one malformed/unresolvable overlay image, same
          // per-record fault isolation as DiaryEntryModel's own
          // _decodeOverlayImages.
        }
      }
    }

    final stickersRaw = json['stickers'];
    final stickers = <Sticker>[];
    if (stickersRaw is List) {
      for (final item in stickersRaw) {
        if (item is! Map<String, dynamic>) continue;
        try {
          // Stickers' localPath is optional (see Sticker's own doc
          // comment) — if the cached file wasn't present in the bundle
          // for any reason, fall back to null rather than dropping the
          // whole sticker; DiaryFormBloc's existing recovery logic
          // (re-download from `url`) already handles a null/missing
          // localPath.
          final bundleLocalPath = item['localPath'] as String?;
          final resolvedLocalPath = bundleLocalPath == null
              ? null
              : resolvedPaths[bundleLocalPath];
          stickers.add(
            Sticker.fromJson({...item, 'localPath': resolvedLocalPath}),
          );
        } catch (_) {
          // Skip this one malformed sticker.
        }
      }
    }

    final imagesRaw = json['images'];
    final images = <String>[];
    if (imagesRaw is List) {
      for (final item in imagesRaw) {
        if (item is! String) continue;
        final resolved = resolvePath(item);
        if (resolved != null) images.add(resolved);
      }
    }

    final tagsRaw = json['tags'];
    final tags = tagsRaw is List
        ? tagsRaw.whereType<String>().toList()
        : const <String>[];

    return DiaryEntry(
      id: newId,
      title: json['title'] as String?,
      date: DateTime.parse(date),
      content: json['content'] as String?,
      preview: json['preview'] as String?,
      mood: Mood.fromStorageValue(json['mood'] as String?),
      imagePath: resolvePath(json['imagePath'] as String?),
      bgColor: json['bgColor'] as String?,
      // ASSUMPTION (unverified against BackgroundImageUtils, which
      // wasn't in the files shared so far): bgImagePath is a BUNDLED
      // APP ASSET path (e.g. "assets/backgrounds/local/..."), matching
      // the assets/backgrounds/local/ entry declared in pubspec.yaml —
      // distinct from bgGalleryImagePath (user's own gallery photo) and
      // bgLocalPath (cached remote preset), which is why it's the only
      // one of the three background fields NOT resolved through
      // resolvePath() here. A bundled asset ships with every install,
      // so the same string is valid on every device — nothing to copy
      // into the export bundle or rewrite on import. If this
      // assumption is wrong (i.e. it can also hold a real on-device
      // file path in some flow), this needs to route through
      // resolvePath() like the other two.
      bgImagePath: json['bgImagePath'] as String?,
      bgGalleryImagePath: resolvePath(json['bgGalleryImagePath'] as String?),
      bgLocalPath: resolvePath(json['bgLocalPath'] as String?),
      bgOverlayOpacity:
          (json['bgOverlayOpacity'] as num?)?.toDouble() ?? 0.85,
      bgOverlayColor: json['bgOverlayColor'] as String?,
      images: images,
      tags: tags,
      overlayImages: overlayImages,
      stickers: stickers,
      wordCount: (json['wordCount'] as num?)?.toInt() ?? 0,
      fontFamily: json['fontFamily'] as String?,
      isFavorite: json['isFavorite'] as bool? ?? false,
      createdAt: DateTime.parse(createdAt),
      updatedAt: DateTime.parse(updatedAt),
    );
  }
}