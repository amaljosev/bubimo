// lib/features/diary_entry/presentation/widgets/resizable_image_embed_builder.dart

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;

/// Custom image `EmbedBuilder` with a real drag-to-resize handle.
///
/// `flutter_quill_extensions`' built-in [quill.EmbedBuilder] for images
/// only exposes resizing through a desktop-only context menu (right
/// click / long press → menu → pick a size) and reads/writes the
/// `width`/`height`/`margin` CSS-style attributes on the embed node —
/// there is no drag handle, so on mobile it's effectively impossible
/// for a user to resize an inline image at all. This builder replaces
/// it with a widget that renders the image at its stored width/height
/// (falling back to a sensible default) and exposes a bottom-right
/// resize handle, matching the same physical drag-to-resize feel as
/// the overlay images ([TransformableItem]) elsewhere in this feature.
///
/// Register this in place of the extension's image builder:
/// ```dart
/// embedBuilders: [
///   ResizableImageEmbedBuilder(),
///   ...FlutterQuillEmbeds.editorBuilders(), // video, formula, etc.
/// ],
/// ```
/// List order matters — Quill uses the first builder whose `key`
/// matches, so this must come before the extension's own image builder
/// if both are present.
class ResizableImageEmbedBuilder extends quill.EmbedBuilder {
  static const double _defaultWidth = 220;
  static const double _defaultHeight = 220;
  static const double _minSize = 80;
  static const double _maxSize = 600;

  @override
  String get key => quill.BlockEmbed.imageType;

  @override
  Widget build(BuildContext context, quill.EmbedContext embedContext) {
    final imageSource = embedContext.node.value.data as String;
    final style = embedContext.node.style;

    final storedWidth = double.tryParse(
      style.attributes['width']?.value?.toString() ?? '',
    );
    final storedHeight = double.tryParse(
      style.attributes['height']?.value?.toString() ?? '',
    );

    return _ResizableImage(
      key: ValueKey(imageSource),
      imageSource: imageSource,
      initialWidth: storedWidth ?? _defaultWidth,
      initialHeight: storedHeight ?? _defaultHeight,
      minSize: _minSize,
      maxSize: _maxSize,
      readOnly: embedContext.readOnly,
      onResizeEnd: (width, height) {
        if (embedContext.readOnly) return;
        final controller = embedContext.controller;
        final offset = quill.getEmbedNode(
          controller,
          controller.selection.start,
        ).offset;
        controller.formatText(
          offset,
          1,
          quill.Attribute.fromKeyValue(
            'style',
            'width: ${width.round()}; height: ${height.round()};',
          ),
        );
      },
    );
  }
}

/// Renders [imageSource] (local file path or network URL) at
/// [initialWidth]x[initialHeight], with an optional bottom-right drag
/// handle to resize it in place. Reports the final size via
/// [onResizeEnd] once the user lifts their finger, rather than on every
/// frame, to avoid spamming `formatText` calls into the Quill document
/// history.
class _ResizableImage extends StatefulWidget {
  final String imageSource;
  final double initialWidth;
  final double initialHeight;
  final double minSize;
  final double maxSize;
  final bool readOnly;
  final void Function(double width, double height) onResizeEnd;

  const _ResizableImage({
    super.key,
    required this.imageSource,
    required this.initialWidth,
    required this.initialHeight,
    required this.minSize,
    required this.maxSize,
    required this.readOnly,
    required this.onResizeEnd,
  });

  @override
  State<_ResizableImage> createState() => _ResizableImageState();
}

class _ResizableImageState extends State<_ResizableImage> {
  late double _width;
  late double _height;
  late double _aspectRatio;

  bool _isResizing = false;
  Offset? _dragStartLocal;
  double _widthAtDragStart = 0;

  @override
  void initState() {
    super.initState();
    _width = widget.initialWidth;
    _height = widget.initialHeight;
    _aspectRatio = _height == 0 ? 1 : _width / _height;
  }

  ImageProvider _resolveProvider(String source) {
    if (source.startsWith('http://') || source.startsWith('https://')) {
      return NetworkImage(source);
    }
    if (source.startsWith('assets/')) {
      return AssetImage(source);
    }
    return FileImage(File(source));
  }

  void _onDragStart(DragStartDetails details) {
    setState(() {
      _isResizing = true;
      _dragStartLocal = details.localPosition;
      _widthAtDragStart = _width;
    });
  }

  void _onDragUpdate(DragUpdateDetails details) {
    if (_dragStartLocal == null) return;
    final delta = details.localPosition - _dragStartLocal!;

    // Drive resize off horizontal drag distance, keep aspect ratio
    // locked — predictable single-axis resizing rather than free-form
    // stretch, which reads as more intentional for photo embeds.
    final newWidth =
        (_widthAtDragStart + delta.dx).clamp(widget.minSize, widget.maxSize);
    final newHeight = newWidth / _aspectRatio;

    setState(() {
      _width = newWidth;
      _height = newHeight;
    });
  }

  void _onDragEnd(DragEndDetails details) {
    setState(() => _isResizing = false);
    widget.onResizeEnd(_width, _height);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final image = ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image(
        image: _resolveProvider(widget.imageSource),
        width: _width,
        height: _height,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => Container(
          width: _width,
          height: _height,
          color: Colors.grey.shade300,
          child: const Icon(Icons.broken_image, color: Colors.white54),
        ),
      ),
    );

    if (widget.readOnly) {
      // No resize handle in read-only (view) mode — the saved size is
      // final once the entry is no longer being edited.
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: image,
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: SizedBox(
        width: _width,
        height: _height,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            image,
            if (_isResizing)
              Positioned.fill(
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: theme.colorScheme.primary,
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ),
            Positioned(
              right: -6,
              bottom: -6,
              child: GestureDetector(
                onPanStart: _onDragStart,
                onPanUpdate: _onDragUpdate,
                onPanEnd: _onDragEnd,
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    shape: BoxShape.circle,
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.open_in_full_rounded,
                    size: 14,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}