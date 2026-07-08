// lib/core/utils/background_image_utils.dart

import 'dart:io';

import 'package:flutter/material.dart';

/// Resolves which background image source to render for a diary entry
/// (or the active theme's header image), following the app's single
/// precedence rule: **gallery > preset-local (asset) > preset-remote
/// (cached file)**.
///
/// Previously this exact precedence chain and asset-vs-file branching
/// was duplicated in:
///   - `DiaryFormPage._resolveBackgroundImage` (reads `DiaryFormState`)
///   - `DiaryEntryViewPage._resolveBackgroundImage` (reads `DiaryEntry`)
///   - `HomePage._headerImage` / `TimelinePage._headerImage` (the
///     asset-vs-file `Image` widget half of the same convention)
abstract final class BackgroundImageUtils {
  /// Resolves an [ImageProvider] from the three possible background
  /// fields, or `null` if none are set. `bgColor` (a plain solid color,
  /// no image) is intentionally not handled here since it isn't an
  /// [ImageProvider] — callers should check for a solid color
  /// separately before falling back to this.
  static ImageProvider? resolveProvider({
    String? bgGalleryImagePath,
    String? bgImagePath,
    String? bgLocalPath,
  }) {
    if (bgGalleryImagePath != null) {
      return FileImage(File(bgGalleryImagePath));
    }
    if (bgImagePath != null) {
      return AssetImage(bgImagePath);
    }
    if (bgLocalPath != null) {
      return FileImage(File(bgLocalPath));
    }
    return null;
  }

  /// Builds an [Image] widget for a single known path, following the
  /// app's asset-vs-file convention: default-preset images are bundled
  /// assets (`assets/theme/theme_N.jpg`), custom/gallery images are
  /// `image_picker` file paths on disk. Distinguished by the `assets/`
  /// prefix.
  static Widget imageFromPath(String path, {BoxFit fit = BoxFit.cover}) {
    if (path.startsWith('assets/')) {
      return Image.asset(path, fit: fit);
    }
    return Image.file(File(path), fit: fit);
  }
}