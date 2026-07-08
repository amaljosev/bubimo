// lib/features/theme/presentation/widgets/shared/theme_color_swatch.dart

import 'package:flutter/material.dart';

import '../../../../../core/theme/theme_tokens.dart';

/// A single small circular color dot with a subtle border — used for
/// compact "here are this theme's colors" indicators (e.g. the
/// currently-applied theme header, or a compact tile trailing icon).
class ThemeColorDot extends StatelessWidget {
  final Color color;
  final double size;

  const ThemeColorDot({super.key, required this.color, this.size = 22});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.black12),
      ),
    );
  }
}

/// A horizontal row of [ThemeColorDot]s with fixed spacing — used
/// wherever a theme's primary/accent colors are shown side by side
/// (e.g. [CurrentThemeHeader], a compact theme tile trailing icon).
class ThemeColorDotRow extends StatelessWidget {
  final List<Color> colors;
  final double dotSize;

  const ThemeColorDotRow({
    super.key,
    required this.colors,
    this.dotSize = 14,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < colors.length; i++) ...[
          if (i > 0) const SizedBox(width: 3),
          ThemeColorDot(color: colors[i], size: dotSize),
        ],
      ],
    );
  }
}

/// A rounded square gradient block blending [colors] diagonally — used
/// as the leading swatch for a theme tile that has no header image.
class ThemeColorGradientBlock extends StatelessWidget {
  final List<Color> colors;
  final double size;

  const ThemeColorGradientBlock({
    super.key,
    required this.colors,
    this.size = 56,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(ThemeRadii.sm),
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    );
  }
}
