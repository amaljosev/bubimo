// lib/core/navigation/notched_nav_bar.dart
//
// A fully custom, reusable bottom navigation bar with:
//  - A floating bar with large rounded bottom corners
//  - A soft, perfectly smooth Bezier notch in the top-center
//  - A rotated "diamond" floating action button that sits partly
//    above the bar, nested into the notch
//  - Subtle press/scale animation on the FAB
//
// No built-in BottomNavigationBar / NavigationBar widgets are used.
// Layout is built with Stack + Positioned + SafeArea, and the bar
// shape is drawn with a CustomPainter using cubic Bezier + arc
// segments for a seamless, kink-free notch.
//
// Theming
// -------
// This widget takes no hardcoded colors. Every color is resolved from
// `Theme.of(context).colorScheme` at build time, the same way the rest
// of the app derives its look from `AppThemeData` via `theme_mapper.dart`
// (`ColorScheme.fromSeed(primaryColor, secondary: accentColor, ...)`).
// That means switching between Dusk / Meadow / Ocean / Sunset / Bloom
// (or any custom theme) re-colors this bar automatically — no changes
// needed here or in `built_in_themes.dart`.
//
// Colors used:
//   - Bar surface   -> colorScheme.surface        (matches Scaffold/
//                                                    AppBar surface)
//   - Bar shadow     -> colorScheme.shadow
//   - FAB fill       -> colorScheme.primary        (matches
//                                                    FloatingActionButtonTheme)
//   - FAB icon       -> colorScheme.onPrimary
//   - Selected item  -> colorScheme.primary
//   - Unselected item-> colorScheme.onSurfaceVariant
//
// Shape/spacing constants (sizes, radii, durations) are intentionally
// NOT theme-dependent — none of the app's built-in themes vary bar
// shape, only color — but they're pulled from the shared `ThemeRadii`/
// `ThemeSpacing`/`ThemeDurations` token classes wherever an equivalent
// token exists, so this widget can't silently drift from the rest of
// the app's spacing/radius scale.

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/theme_tokens.dart';

// ---------------------------------------------------------------------
// Design constants — tune the whole bar from here. Colors are NOT
// declared here; they're resolved from ColorScheme at build time.
// ---------------------------------------------------------------------

/// Height of the flat navigation bar surface (excludes the FAB
/// protrusion and safe-area padding).
const double kNavBarHeight = 90.0;

/// Radius of the two large rounded corners at the bottom of the bar.
/// Larger than any existing [ThemeRadii] token (the biggest, `sheet`,
/// is for bottom-sheet tops) so it's kept as its own constant rather
/// than forced onto an ill-fitting shared token.
const double kBottomCornerRadius = 0.0;

/// Diameter of the floating diamond button (edge-to-edge of the
/// rotated square, i.e. the visual "width" of the diamond).
const double kFabSize = 72.0;

/// Corner radius applied to the square before it's rotated 45°.
const double kFabCornerRadius = ThemeRadii.xxl;

/// Fraction of the FAB's total (diamond) height that should sit
/// above the top edge of the bar. ~0.4 matches the reference design.
const double kFabProtrusion = 0.42;

/// Total width of the notch opening at the very top of the bar.
const double kNotchWidth = 108.0;

/// How deep the notch dips down into the bar.
const double kNotchDepth = 30.0;

/// Radius of the small smoothing arc where the flat top edge rolls
/// into the notch curve. Larger = softer shoulder.
const double kNotchShoulderRadius = ThemeRadii.xl;

/// Blur radius for the bar's ambient drop shadow.
const double kBarShadowBlur = 24.0;

/// Vertical offset for the bar's drop shadow.
const double kBarShadowOffsetY = 10.0;

/// Blur radius for the FAB's own drop shadow.
const double kFabShadowBlur = 8.0;

/// Vertical offset for the FAB's own drop shadow.
const double kFabShadowOffsetY = 4.0;

/// Horizontal padding applied to the row of left / right nav items.
const double kNavItemsHorizontalPadding = ThemeSpacing.sm;

/// Press-animation timing, sourced from the shared token set so the
/// FAB's tap feedback feels consistent with the rest of the app's
/// interactive animations (see `ThemeDurations`).
const Duration kFabPressDuration = ThemeDurations.fast;
const Duration kFabReleaseDuration = ThemeDurations.standard;

// ---------------------------------------------------------------------
// Public data model for a single destination.
// ---------------------------------------------------------------------

class NavBarItem {
  const NavBarItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
}

// ---------------------------------------------------------------------
// Main widget
// ---------------------------------------------------------------------

class NotchedNavBar extends StatefulWidget {
  const NotchedNavBar({
    super.key,
    required this.leftItems,
    required this.rightItems,
    required this.currentIndex,
    required this.onTap,
    required this.onFabTap,
    this.fabIcon = Icons.add,
  });

  final List<NavBarItem> leftItems;
  final List<NavBarItem> rightItems;
  final int currentIndex;
  final ValueChanged<int> onTap;
  final VoidCallback onFabTap;
  final IconData fabIcon;

  @override
  State<NotchedNavBar> createState() => _NotchedNavBarState();
}

class _NotchedNavBarState extends State<NotchedNavBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _fabController;
  late final Animation<double> _fabScale;

  @override
  void initState() {
    super.initState();
    _fabController = AnimationController(
      vsync: this,
      duration: kFabPressDuration,
      reverseDuration: kFabReleaseDuration,
    );
    _fabScale = Tween<double>(
      begin: 1.0,
      end: 0.88,
    ).animate(CurvedAnimation(parent: _fabController, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _fabController.dispose();
    super.dispose();
  }

  void _handleFabTapDown(TapDownDetails _) => _fabController.forward();
  void _handleFabTapUp(TapUpDetails _) => _fabController.reverse();
  void _handleFabTapCancel() => _fabController.reverse();

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    // The diamond's bounding box (rotated square) is size * sqrt2 tall.
    final double diamondBBoxHeight = kFabSize * math.sqrt2;
    final double fabProtrusionHeight = kFabProtrusion * diamondBBoxHeight;

    // Total stack height = flat bar + whatever pokes out above it,
    // plus a hair of breathing room so shadows aren't clipped.
    final double totalHeight = kNavBarHeight + fabProtrusionHeight + 4.0;

    return SizedBox(
      height: totalHeight,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: [
          // ---------------- Bar surface + nav items ----------------
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: kNavBarHeight,
            child: CustomPaint(
              painter: _NotchedBarPainter(
                color: colorScheme.surface,
                notchWidth: kNotchWidth,
                notchDepth: kNotchDepth,
                notchShoulderRadius: kNotchShoulderRadius,
                bottomCornerRadius: kBottomCornerRadius,
                shadowColor: colorScheme.shadow.withValues(alpha: 0.10),
                shadowBlur: kBarShadowBlur,
                shadowOffsetY: kBarShadowOffsetY,
              ),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: kNavItemsHorizontalPadding,
                  ),
                  child: Row(
                    children: [
                      for (int i = 0; i < widget.leftItems.length; i++)
                        Expanded(
                          child: _NavItem(
                            item: widget.leftItems[i],
                            selected: widget.currentIndex == i,
                            onTap: () => widget.onTap(i),
                          ),
                        ),
                      SizedBox(width: kNotchWidth * 0.78),
                      for (int i = 0; i < widget.rightItems.length; i++)
                        Expanded(
                          child: _NavItem(
                            item: widget.rightItems[i],
                            selected:
                                widget.currentIndex ==
                                widget.leftItems.length + i,
                            onTap: () =>
                                widget.onTap(widget.leftItems.length + i),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ---------------- Floating diamond FAB ----------------
          //
          // The outer GestureDetector ONLY drives the press/scale
          // animation (tap-down / tap-up / tap-cancel) — it does NOT
          // set `onTap`. The actual tap is handled by the inner
          // InkWell inside `_FloatingDiamondButton`, which forwards to
          // `widget.onFabTap`. Previously both the outer
          // GestureDetector AND the inner InkWell tried to claim the
          // tap (the inner one with an empty `onTap: () {}`), and
          // since the InkWell sits deeper in the hit-test tree it won
          // the gesture arena and silently swallowed every tap before
          // `onFabTap` could ever fire — the FAB looked interactive
          // (it even showed a ripple) but never actually navigated
          // anywhere. There must be exactly one widget with a real
          // `onTap` in this stack; that's now the InkWell.
          Positioned(
            bottom: kNavBarHeight - (fabProtrusionHeight),
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTapDown: _handleFabTapDown,
                onTapUp: _handleFabTapUp,
                onTapCancel: _handleFabTapCancel,
                child: AnimatedBuilder(
                  animation: _fabScale,
                  builder: (context, child) =>
                      Transform.scale(scale: _fabScale.value, child: child),
                  child: _FloatingDiamondButton(
                    size: kFabSize,
                    cornerRadius: kFabCornerRadius,
                    color: colorScheme.primary,
                    shadowColor: colorScheme.shadow,
                    icon: widget.fabIcon,
                    iconColor: colorScheme.onPrimary,
                    onTap: widget.onFabTap,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------
// Individual tab item
// ---------------------------------------------------------------------

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final NavBarItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final Color color = selected
        ? colorScheme.primary
        : colorScheme.onSurfaceVariant;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(ThemeRadii.xxl),
      customBorder: const StadiumBorder(),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: ThemeSpacing.sm),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              selected ? item.activeIcon : item.icon,
              color: color,
              size: 24,
            ),
            const SizedBox(height: ThemeSpacing.xs + 2),
            Text(
              item.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: color,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------
// Floating diamond button (rounded square rotated 45°, icon upright)
// ---------------------------------------------------------------------

class _FloatingDiamondButton extends StatelessWidget {
  const _FloatingDiamondButton({
    required this.size,
    required this.cornerRadius,
    required this.color,
    required this.shadowColor,
    required this.icon,
    required this.iconColor,
    required this.onTap,
  });

  final double size;
  final double cornerRadius;
  final Color color;
  final Color shadowColor;
  final IconData icon;
  final Color iconColor;

  /// Real tap handler — this InkWell is the single source of truth for
  /// the FAB's tap. The parent GestureDetector (in _NotchedNavBarState)
  /// only drives the press/scale animation and must NOT also set
  /// `onTap`, or the two gesture recognizers will race and the deeper
  /// one (this InkWell) will win, regardless of what it does.
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // Bounding box of the rotated square.
    final double bbox = size * math.sqrt2;

    return SizedBox(
      width: bbox,
      height: bbox,
      child: Center(
        child: Transform.rotate(
          angle: math.pi / 4,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(cornerRadius),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.45),
                  blurRadius: kFabShadowBlur,
                  offset: Offset(0, kFabShadowOffsetY),
                ),
                BoxShadow(
                  color: shadowColor.withValues(alpha: 0.15),
                  blurRadius: kFabShadowBlur * 1.5,
                  offset: Offset(0, kFabShadowOffsetY),
                ),
              ],
            ),
            child: Material(
              type: MaterialType.transparency,
              child: InkWell(
                borderRadius: BorderRadius.circular(cornerRadius),
                onTap: onTap,
                child: SizedBox(
                  width: size,
                  height: size,
                  child: Transform.rotate(
                    // Counter-rotate so the icon stays upright.
                    angle: -math.pi / 4,
                    child: Icon(icon, color: iconColor, size: size * 0.4),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------
// CustomPainter — flat top edges + a single continuous, kink-free
// Bezier/arc notch, and large rounded bottom corners.
// ---------------------------------------------------------------------
//
// Geometry strategy for a perfectly smooth notch:
//   1. Flat top edge, running in from the corner.
//   2. A short circular arc ("shoulder") that peels the path away
//      from horizontal and aims it into the dip. Because it's a true
//      arc tangent to the horizontal line at its start, this join is
//      G1-continuous (no kink).
//   3. A cubic Bezier "bowl" from the end of the left shoulder arc,
//      down through the bottom of the notch, back up to the start of
//      the right shoulder arc. Its entry/exit control points are
//      chosen to continue the arc's tangent direction, so the arc →
//      curve → arc chain reads as one smooth stroke.
//   4. Mirrored shoulder arc back out to flat top.
//
class _NotchedBarPainter extends CustomPainter {
  _NotchedBarPainter({
    required this.color,
    required this.notchWidth,
    required this.notchDepth,
    required this.notchShoulderRadius,
    required this.bottomCornerRadius,
    required this.shadowColor,
    required this.shadowBlur,
    required this.shadowOffsetY,
  });

  final Color color;
  final double notchWidth;
  final double notchDepth;
  final double notchShoulderRadius;
  final double bottomCornerRadius;
  final Color shadowColor;
  final double shadowBlur;
  final double shadowOffsetY;

  @override
  void paint(Canvas canvas, Size size) {
    final Path path = _buildPath(size);

    // Ambient shadow (kept subtle; offset is approximated by nudging
    // the shadow path down, since drawShadow itself has no offset
    // parameter).
    canvas.save();
    canvas.translate(0, shadowOffsetY * 0.35);
    canvas.drawShadow(path, shadowColor, shadowBlur, false);
    canvas.restore();

    canvas.drawPath(path, Paint()..color = color);
  }

  Path _buildPath(Size size) {
    final double width = size.width;
    final double height = size.height;
    final double centerX = width / 2;
    final double halfNotch = notchWidth / 2;
    final double r = bottomCornerRadius;
    final double sr = notchShoulderRadius;

    // Shoulder arc: a quarter-ish circle of radius `sr` that starts
    // tangent to the flat top (horizontal) and curves down/inward.
    // Its end point and end tangent feed directly into the bowl curve.
    //
    // Left shoulder circle center sits at (leftArcStartX, sr) so the
    // arc starts at (leftArcStartX, 0) moving horizontally, and bends
    // downward. We sweep it by `shoulderSweep` radians.
    const double shoulderSweep = math.pi / 2.4; // tuned for a soft roll

    final double leftArcCenterX = centerX - halfNotch + sr;
    final double leftArcCenterY = sr;

    // Angle measured from the top of the circle (pointing up, i.e.
    // -pi/2 in standard math convention) sweeping clockwise into the
    // notch.
    final double leftArcEndAngle = -math.pi / 2 + shoulderSweep;
    final Offset leftArcEnd = Offset(
      leftArcCenterX + sr * math.cos(leftArcEndAngle),
      leftArcCenterY + sr * math.sin(leftArcEndAngle),
    );
    // Tangent direction at end of arc (perpendicular to radius,
    // pointing in the direction of travel — clockwise).
    final Offset leftTangent = Offset(
      math.cos(leftArcEndAngle + math.pi / 2),
      math.sin(leftArcEndAngle + math.pi / 2),
    );

    // Mirror for the right shoulder.
    //
    // The right shoulder circle is the left one reflected across the
    // vertical center line. Reflecting a point at angle `theta` (from
    // its own circle's center) across a vertical axis corresponds to
    // the angle `pi - theta` on the mirrored circle. We use this to
    // derive the right arc's start/end angles directly, so the arc's
    // own start point (which is what Path.arcTo actually draws to)
    // lands EXACTLY on the cubicTo's endpoint — no seam.
    final double rightArcCenterX = centerX + halfNotch - sr;
    final double rightArcCenterY = sr;
    const double leftArcStartAngle = -math.pi / 2;
    final double rightArcStartAngle = math.pi - leftArcEndAngle;
    final double rightArcEndAngle = math.pi - leftArcStartAngle;

    final Offset rightArcStart = Offset(
      rightArcCenterX + sr * math.cos(rightArcStartAngle),
      rightArcCenterY + sr * math.sin(rightArcStartAngle),
    );
    final Offset rightTangent = Offset(-leftTangent.dx, leftTangent.dy);
    // Sweep from rightArcStartAngle to rightArcEndAngle (both derived
    // from the mirror, so this is guaranteed to equal shoulderSweep
    // in magnitude and land exactly back on the flat top edge).
    final double rightShoulderSweep = rightArcEndAngle - rightArcStartAngle;

    // Bowl: cubic Bezier from leftArcEnd to rightArcStart, passing
    // near the bottom of the notch. Control points are placed along
    // each end's tangent direction so the curve leaves the arcs
    // smoothly (G1 continuity). The handle length is derived from
    // how much extra depth the bowl needs to cover beyond what the
    // shoulder arcs already reached, so it hits notchDepth cleanly
    // without ever needing a post-hoc clamp (a clamp would break
    // tangent continuity and reintroduce a visible kink).
    final double remainingDepth = math.max(
      notchDepth - leftArcEnd.dy,
      notchDepth * 0.25,
    );
    final double handleLength = remainingDepth / math.max(leftTangent.dy, 0.2);

    final Offset bowlC1Adjusted = leftArcEnd + leftTangent * handleLength;
    final Offset bowlC2Adjusted = rightArcStart + rightTangent * handleLength;

    final Path path = Path();

    // Bottom-left corner → up the left edge.
    path.moveTo(0, height - r);
    path.arcTo(
      Rect.fromLTWH(0, height - 2 * r, 2 * r, 2 * r),
      math.pi,
      math.pi / 2,
      false,
    );
    path.lineTo(0, 0);

    // Flat top edge up to the start of the left shoulder.
    path.lineTo(leftArcCenterX, 0);

    // Left shoulder arc (tangent-continuous with the flat edge).
    path.arcTo(
      Rect.fromCircle(
        center: Offset(leftArcCenterX, leftArcCenterY),
        radius: sr,
      ),
      -math.pi / 2,
      shoulderSweep,
      false,
    );

    // Smooth bowl through the bottom of the notch.
    path.cubicTo(
      bowlC1Adjusted.dx,
      bowlC1Adjusted.dy,
      bowlC2Adjusted.dx,
      bowlC2Adjusted.dy,
      rightArcStart.dx,
      rightArcStart.dy,
    );

    // Right shoulder arc, mirrored, back up to flat top. Starts
    // exactly where the cubicTo above ends, so there's no seam.
    path.arcTo(
      Rect.fromCircle(
        center: Offset(rightArcCenterX, rightArcCenterY),
        radius: sr,
      ),
      rightArcStartAngle,
      rightShoulderSweep,
      false,
    );

    // Flat top edge to the top-right corner.
    path.lineTo(width, 0);

    // Bottom-right corner → bottom edge → close.
    path.lineTo(width, height - r);
    path.arcTo(
      Rect.fromLTWH(width - 2 * r, height - 2 * r, 2 * r, 2 * r),
      0,
      math.pi / 2,
      false,
    );
    path.lineTo(0, height);
    path.close();

    return path;
  }

  @override
  bool shouldRepaint(covariant _NotchedBarPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.notchWidth != notchWidth ||
        oldDelegate.notchDepth != notchDepth ||
        oldDelegate.notchShoulderRadius != notchShoulderRadius ||
        oldDelegate.bottomCornerRadius != bottomCornerRadius ||
        oldDelegate.shadowColor != shadowColor ||
        oldDelegate.shadowBlur != shadowBlur ||
        oldDelegate.shadowOffsetY != shadowOffsetY;
  }
}