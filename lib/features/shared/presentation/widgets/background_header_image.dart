// lib/features/shared/presentation/widgets/background_header_image.dart

import 'package:flutter/material.dart';

import '../../../../core/utils/background_image_utils.dart';

/// Renders a theme/entry header image, resolving asset-vs-file per the
/// app's convention (see [BackgroundImageUtils.imageFromPath]).
///
/// Previously duplicated as `HomePage._headerImage` and
/// `TimelinePage._headerImage`.
class BackgroundHeaderImage extends StatelessWidget {
  final String path;
  final BoxFit fit;

  const BackgroundHeaderImage({
    super.key,
    required this.path,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    return BackgroundImageUtils.imageFromPath(path, fit: fit);
  }
}