// lib/features/diary_entry/domain/entities/overlay_image.dart

import 'package:equatable/equatable.dart';

/// A single free-floating, draggable/rotatable/resizable photo layered
/// on top of the diary entry's Quill editor.
///
/// This is deliberately separate from [DiaryEntry.images], which tracks
/// photos inserted *inline* as Quill embeds (part of the text flow).
/// An [OverlayImage] instead carries its own absolute position/transform
/// data, since it floats independently of the document content.
///
/// Coordinates ([x], [y]) are stored relative to the top-left of the
/// overlay layer (the area behind the Quill editor), in logical pixels,
/// at [baseWidth]/[baseHeight] unscaled size — matching the convention
/// used by `TransformableItem`.
class OverlayImage extends Equatable {
  /// Stable identifier, generated once when the image is added — used
  /// to target updates/removal and as the Hero tag suffix for the
  /// full-screen viewer.
  final String id;

  /// Local file path to the picked image.
  final String path;

  final double x;
  final double y;
  final double scale;
  final double rotation;

  const OverlayImage({
    required this.id,
    required this.path,
    required this.x,
    required this.y,
    this.scale = 1.0,
    this.rotation = 0.0,
  });

  static const double baseWidth = 140.0;
  static const double baseHeight = 140.0;

  OverlayImage copyWith({
    String? id,
    String? path,
    double? x,
    double? y,
    double? scale,
    double? rotation,
  }) {
    return OverlayImage(
      id: id ?? this.id,
      path: path ?? this.path,
      x: x ?? this.x,
      y: y ?? this.y,
      scale: scale ?? this.scale,
      rotation: rotation ?? this.rotation,
    );
  }

  factory OverlayImage.fromJson(Map<String, dynamic> json) {
    return OverlayImage(
      id: json['id'] as String,
      path: json['path'] as String,
      x: (json['x'] as num).toDouble(),
      y: (json['y'] as num).toDouble(),
      scale: (json['scale'] as num?)?.toDouble() ?? 1.0,
      rotation: (json['rotation'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'path': path,
      'x': x,
      'y': y,
      'scale': scale,
      'rotation': rotation,
    };
  }

  @override
  List<Object?> get props => [id, path, x, y, scale, rotation];
}