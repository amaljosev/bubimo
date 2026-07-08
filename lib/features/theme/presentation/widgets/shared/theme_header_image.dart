// lib/features/theme/presentation/widgets/shared/theme_header_image.dart

import 'dart:io';

import 'package:flutter/material.dart';

import '../../../domain/entities/app_theme_data.dart';

/// Renders a theme's header image, correctly choosing `Image.asset` vs
/// `Image.file` based on [isAsset] — [AppThemeData.isHeaderImageAsset]
/// is the single source of truth for this distinction.
///
/// Previously this branch was reimplemented ad-hoc in three places with
/// three different (and inconsistent) strategies: [BuiltInThemeTile]
/// assumed asset-always, [CustomThemeTile] assumed file-always, and
/// [HomePreviewCard] guessed via `path.startsWith('assets/')`. Built-in
/// tiles/custom tiles happen to be safe today because their inputs
/// never come from the other source, but that safety was implicit and
/// easy to break — this widget makes it explicit everywhere except the
/// live form preview (see [ThemeHeaderImage.fromPath], which still
/// needs the heuristic since the form has no [AppThemeData] yet).
class ThemeHeaderImage extends StatelessWidget {
  final String path;
  final bool isAsset;
  final BoxFit fit;
  final Widget Function(BuildContext context)? errorBuilder;

  const ThemeHeaderImage({
    super.key,
    required this.path,
    required this.isAsset,
    this.fit = BoxFit.cover,
    this.errorBuilder,
  });

  /// For [AppThemeData] with a known [AppThemeData.headerImagePath] and
  /// [AppThemeData.isHeaderImageAsset] flag.
  factory ThemeHeaderImage.fromTheme(
    AppThemeData theme, {
    BoxFit fit = BoxFit.cover,
    Widget Function(BuildContext context)? errorBuilder,
  }) {
    return ThemeHeaderImage(
      path: theme.headerImagePath!,
      isAsset: theme.isHeaderImageAsset,
      fit: fit,
      errorBuilder: errorBuilder,
    );
  }

  /// For contexts with only a raw path and no [AppThemeData] yet (e.g.
  /// the Create Custom Theme live preview, where the header image is a
  /// freshly-cropped file that was never wrapped in an entity). Custom
  /// theme header images are always on-disk files, never bundled
  /// assets, so this always renders as a file.
  factory ThemeHeaderImage.fromPath(String path, {BoxFit fit = BoxFit.cover}) {
    return ThemeHeaderImage(path: path, isAsset: false, fit: fit);
  }

  @override
  Widget build(BuildContext context) {
    if (isAsset) {
      return Image.asset(
        path,
        fit: fit,
        errorBuilder: errorBuilder != null
            ? (_, _, _) => errorBuilder!(context)
            : null,
      );
    }
    return Image.file(File(path), fit: fit);
  }
}
