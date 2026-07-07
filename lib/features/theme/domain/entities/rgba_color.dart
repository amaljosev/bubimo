// lib/features/theme/domain/entities/rgba_color.dart

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart' show Color;

/// Domain-level color representation using explicit RGBO channels
/// (red, green, blue 0-255, opacity 0.0-1.0) rather than Flutter's
/// [Color] or a raw hex string.
///
/// Keeping this in the domain layer (instead of importing
/// `dart:ui`/`material.dart` `Color` directly into entities) means the
/// domain stays framework-agnostic, and the custom RGBO color picker
/// (no external package) can bind directly to these four numeric
/// channels without any hex parsing round-trip.
///
/// Persisted as a single `'r,g,b,o'` string (see [toStorageString] /
/// [fromStorageString]) so the local data source can store it as one
/// TEXT column per color field, matching the existing
/// `custom_themes` table's one-column-per-color layout.
class RgbaColor extends Equatable {
  final int red;
  final int green;
  final int blue;

  /// Opacity, 0.0 (fully transparent) to 1.0 (fully opaque).
  final double opacity;

  const RgbaColor({
    required this.red,
    required this.green,
    required this.blue,
    this.opacity = 1.0,
  });

  /// Builds from a Flutter [Color] — used at the boundary when reading
  /// a built-in theme's `Color` constant into domain data.
  factory RgbaColor.fromColor(Color color) {
    return RgbaColor(
      red: color.r.round(),
      green: color.g.round(),
      blue: color.b.round(),
      opacity: color.a,
    );
  }

  /// Parses the `'r,g,b,o'` storage format written by [toStorageString].
  /// Falls back to opaque black on malformed input rather than
  /// throwing, so a corrupt row can't crash theme loading.
  factory RgbaColor.fromStorageString(String value) {
    final parts = value.split(',');
    if (parts.length != 4) return const RgbaColor(red: 0, green: 0, blue: 0);

    return RgbaColor(
      red: int.tryParse(parts[0]) ?? 0,
      green: int.tryParse(parts[1]) ?? 0,
      blue: int.tryParse(parts[2]) ?? 0,
      opacity: double.tryParse(parts[3]) ?? 1.0,
    );
  }

  String toStorageString() => '$red,$green,$blue,$opacity';

  /// Converts to a Flutter [Color] at the presentation/theme-mapping
  /// boundary.
  Color toColor() => Color.fromRGBO(red, green, blue, opacity);

  RgbaColor copyWith({int? red, int? green, int? blue, double? opacity}) {
    return RgbaColor(
      red: red ?? this.red,
      green: green ?? this.green,
      blue: blue ?? this.blue,
      opacity: opacity ?? this.opacity,
    );
  }

  @override
  List<Object?> get props => [red, green, blue, opacity];
}
