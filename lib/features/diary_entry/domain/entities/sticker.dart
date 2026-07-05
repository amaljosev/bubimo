// lib/features/diary_entry/domain/entities/sticker.dart

import 'package:equatable/equatable.dart';

/// A single sticker placed as a free-floating, draggable/rotatable/
/// resizable overlay on top of the Quill editor — visually and
/// behaviorally identical to [OverlayImage], but sourced from the
/// app's shared Supabase sticker library rather than the user's own
/// gallery.
///
/// Both [url] and [localPath] are kept (rather than just a resolved
/// file path) so a downloaded sticker can be re-fetched if its local
/// cache file goes missing — e.g. after a fresh install or a backup
/// restore that didn't carry the cached file across. [url] is the
/// permanent Supabase public URL (recovery source of truth); [localPath]
/// is the on-device cached copy actually used for rendering, and may be
/// null immediately after this entity is constructed but before the
/// download completes.
class Sticker extends Equatable {
  final String id;
  final String url;
  final String? localPath;
  final double x;
  final double y;
  final double scale;
  final double rotation;

  /// Base render size (before [scale] is applied) for every sticker —
  /// matches the old project's `TransformableItem.stickerBaseSize` so
  /// the drag/pinch/rotate handle math stays consistent between
  /// stickers and overlay images.
  static const double baseWidth = 100.0;
  static const double baseHeight = 100.0;

  const Sticker({
    required this.id,
    required this.url,
    this.localPath,
    required this.x,
    required this.y,
    this.scale = 1.0,
    this.rotation = 0.0,
  });

  Sticker copyWith({
    String? id,
    String? url,
    String? localPath,
    double? x,
    double? y,
    double? scale,
    double? rotation,
  }) {
    return Sticker(
      id: id ?? this.id,
      url: url ?? this.url,
      localPath: localPath ?? this.localPath,
      x: x ?? this.x,
      y: y ?? this.y,
      scale: scale ?? this.scale,
      rotation: rotation ?? this.rotation,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'url': url,
      'localPath': localPath,
      'x': x,
      'y': y,
      'scale': scale,
      'rotation': rotation,
    };
  }

  factory Sticker.fromJson(Map<String, dynamic> json) {
    return Sticker(
      id: json['id'] as String,
      url: json['url'] as String,
      localPath: json['localPath'] as String?,
      x: (json['x'] as num).toDouble(),
      y: (json['y'] as num).toDouble(),
      scale: (json['scale'] as num?)?.toDouble() ?? 1.0,
      rotation: (json['rotation'] as num?)?.toDouble() ?? 0.0,
    );
  }

  @override
  List<Object?> get props => [id, url, localPath, x, y, scale, rotation];
}