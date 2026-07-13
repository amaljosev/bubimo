// lib/core/navigation/debounced_tap.dart

import 'package:flutter/material.dart';

/// Wraps [child] so its tap callback can only fire once per debounce
/// window, then re-arms automatically.
///
/// PROBLEM THIS FIXES: `InkWell`/`GestureDetector.onTap` fires on
/// pointer-up. A fast double-tap — or a tap landing right as the
/// surrounding widget rebuilds (e.g. inside a `BlocBuilder`, which
/// every list/grid in this app is wrapped in) — can register the
/// gesture twice before the first `go_router` push has finished
/// transitioning. Each fire independently calls `context.push(...)`,
/// so the same destination page gets pushed twice onto the stack,
/// showing as "the page opening twice" / back button needing two taps.
///
/// This was previously unguarded on every tappable list item across the
/// app (diary list, theme list, etc.) — each would have needed its own
/// hand-rolled `_isNavigating` bool (the pattern already used in
/// `DiaryFormPage`'s save flow) copy-pasted into every widget. Centralizing
/// it here means the guard exists in exactly one place, and every
/// tappable item gets it by construction rather than by remembering to
/// add it.
///
/// SCOPE: deliberately per-widget-instance, NOT a single global/static
/// flag. A global "is navigating" flag would also block legitimate,
/// unrelated rapid taps (e.g. tapping entry A, immediately backing out,
/// then tapping entry B) and would misbehave once dialogs/bottom sheets
/// (nested navigators) are involved. Debouncing each tile independently
/// is the correct scope: it only suppresses a *repeat* tap on the *same*
/// tile within the debounce window.
///
/// USAGE — wrap the tappable content instead of using `InkWell` /
/// `GestureDetector` directly:
/// ```dart
/// DebouncedTap(
///   onTap: () => context.push(AppRoutes.diaryView, extra: entry.id),
///   borderRadius: BorderRadius.circular(16),
///   child: someCardWidget,
/// )
/// ```
class DebouncedTap extends StatefulWidget {
  final VoidCallback onTap;
  final Widget child;
  final BorderRadius? borderRadius;

  /// How long to ignore repeat taps after the first one fires. 600ms
  /// comfortably covers a typical page-transition animation without
  /// being long enough to feel unresponsive if the user genuinely
  /// meant two separate taps.
  final Duration debounceDuration;

  const DebouncedTap({
    super.key,
    required this.onTap,
    required this.child,
    this.borderRadius,
    this.debounceDuration = const Duration(milliseconds: 600),
  });

  @override
  State<DebouncedTap> createState() => _DebouncedTapState();
}

class _DebouncedTapState extends State<DebouncedTap> {
  bool _isLocked = false;

  void _handleTap() {
    if (_isLocked) return;

    setState(() => _isLocked = true);
    widget.onTap();

    Future.delayed(widget.debounceDuration, () {
      // Guard against calling setState after this tile has been
      // disposed — e.g. the tap navigated away and this list item's
      // page was popped off the widget tree before the timer fired.
      if (mounted) {
        setState(() => _isLocked = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _handleTap,
      borderRadius: widget.borderRadius,
      child: widget.child,
    );
  }
}