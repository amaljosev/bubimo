// lib/features/app_lock/presentation/widgets/pattern_grid_widget.dart
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

/// A 3x3 pattern-lock grid (9 nodes, indices 0-8). Tracks a drag
/// gesture across the nodes and reports the completed sequence as a
/// dash-separated string (e.g. "0-1-2-5-8") via [onPatternComplete]
/// when the user lifts their finger.
class PatternGridWidget extends StatefulWidget {
  final ValueChanged<String> onPatternComplete;

  const PatternGridWidget({super.key, required this.onPatternComplete});

  @override
  State<PatternGridWidget> createState() => _PatternGridWidgetState();
}

class _PatternGridWidgetState extends State<PatternGridWidget> {
  static const int _gridSize = 3;
  static const double _nodeRadius = 16;
  static const double _hitRadius = 32;

  final List<int> _selectedNodes = [];
  final GlobalKey _gridKey = GlobalKey();

  List<Offset> _nodePositions(Size gridSize) {
    final cellSize = gridSize.width / _gridSize;
    return List.generate(_gridSize * _gridSize, (index) {
      final row = index ~/ _gridSize;
      final col = index % _gridSize;
      return Offset(
        cellSize * col + cellSize / 2,
        cellSize * row + cellSize / 2,
      );
    });
  }

  void _handlePanUpdate(DragUpdateDetails details, Size gridSize) {
    final box = _gridKey.currentContext!.findRenderObject() as RenderBox;
    final localPosition = box.globalToLocal(details.globalPosition);
    final positions = _nodePositions(gridSize);

    for (var i = 0; i < positions.length; i++) {
      if (_selectedNodes.contains(i)) continue;
      final distance = (positions[i] - localPosition).distance;
      if (distance <= _hitRadius) {
        setState(() => _selectedNodes.add(i));
      }
    }
  }

  void _handlePanEnd(DragEndDetails details) {
    if (_selectedNodes.isNotEmpty) {
      widget.onPatternComplete(_selectedNodes.join('-'));
    }
    setState(() => _selectedNodes.clear());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxWidth);

        return GestureDetector(
          onPanUpdate: (details) => _handlePanUpdate(details, size),
          onPanEnd: _handlePanEnd,
          child: Container(
            key: _gridKey,
            width: size.width,
            height: size.height,
            color: Colors.transparent,
            child: CustomPaint(
              painter: _PatternPainter(
                nodePositions: _nodePositions(size),
                selectedNodes: _selectedNodes,
                nodeRadius: _nodeRadius,
                activeColor: theme.colorScheme.primary,
                inactiveColor: theme.colorScheme.outlineVariant,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _PatternPainter extends CustomPainter {
  final List<Offset> nodePositions;
  final List<int> selectedNodes;
  final double nodeRadius;
  final Color activeColor;
  final Color inactiveColor;

  _PatternPainter({
    required this.nodePositions,
    required this.selectedNodes,
    required this.nodeRadius,
    required this.activeColor,
    required this.inactiveColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = activeColor
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    for (var i = 0; i < selectedNodes.length - 1; i++) {
      canvas.drawLine(
        nodePositions[selectedNodes[i]],
        nodePositions[selectedNodes[i + 1]],
        linePaint,
      );
    }

    for (var i = 0; i < nodePositions.length; i++) {
      final isSelected = selectedNodes.contains(i);
      canvas.drawCircle(
        nodePositions[i],
        nodeRadius,
        Paint()..color = isSelected ? activeColor : inactiveColor,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _PatternPainter oldDelegate) {
    return oldDelegate.selectedNodes != selectedNodes;
  }
}