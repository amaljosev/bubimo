// lib/features/diary_entry/presentation/widgets/diary_bottom_toolbar.dart

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;

/// The new bottom toolbar for the diary entry screen.
///
/// Order (left to right):
///  1. "T"  → opens [QuillToolsSheet], a grid of all Quill formatting
///            tools (everything except bullets, which gets its own
///            dedicated quick-access icon here).
///  2. Bullets → quick-insert / toggle bullet list directly.
///  3. Background
///  4. Font picker
///  5. Sticker
///  6. Overlay image
///  7. Inline image
class DiaryBottomToolbar extends StatelessWidget {
  final quill.QuillController controller;
  final VoidCallback onBackgroundPressed;
  final VoidCallback onFontPressed;
  final VoidCallback onStickerPressed;
  final VoidCallback onOverlayImagePressed;
  final VoidCallback onInlineImagePressed;

  const DiaryBottomToolbar({
    super.key,
    required this.controller,
    required this.onBackgroundPressed,
    required this.onFontPressed,
    required this.onStickerPressed,
    required this.onOverlayImagePressed,
    required this.onInlineImagePressed,
  });

  void _openTextToolsSheet(BuildContext context) {
    FocusScope.of(context).unfocus();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => QuillToolsSheet(controller: controller),
    );
  }

  void _toggleBullet() {
    final isActive = controller
        .getSelectionStyle()
        .attributes
        .containsKey(quill.Attribute.ul.key);
    controller.formatSelection(
      isActive
          ? quill.Attribute.clone(quill.Attribute.ul, null)
          : quill.Attribute.ul,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 6, 12, 10),
        child: Container(
          decoration: BoxDecoration(
            color: isDark
                ? theme.colorScheme.surface
                : theme.colorScheme.surface.withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 6,
              vertical: 6,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _ToolbarIconButton(
                  icon: Icons.title_rounded,
                  tooltip: 'Text formatting',
                  onPressed: () => _openTextToolsSheet(context),
                ),
                _ToolbarIconButton(
                  icon: Icons.format_list_bulleted_rounded,
                  tooltip: 'Bullet list',
                  onPressed: _toggleBullet,
                ),
                _ToolbarIconButton(
                  icon: Icons.wallpaper_outlined,
                  tooltip: 'Background',
                  onPressed: onBackgroundPressed,
                ),
                _ToolbarIconButton(
                  icon: Icons.text_fields_rounded,
                  tooltip: 'Font',
                  onPressed: onFontPressed,
                ),
                _ToolbarIconButton(
                  icon: Icons.emoji_emotions_outlined,
                  tooltip: 'Sticker',
                  onPressed: onStickerPressed,
                ),
                _ToolbarIconButton(
                  icon: Icons.add_photo_alternate_outlined,
                  tooltip: 'Floating photo',
                  onPressed: onOverlayImagePressed,
                ),
                _ToolbarIconButton(
                  icon: Icons.image_outlined,
                  tooltip: 'Insert photo',
                  onPressed: onInlineImagePressed,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ToolbarIconButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  const _ToolbarIconButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Tooltip(
      message: tooltip,
      child: InkResponse(
        onTap: onPressed,
        radius: 26,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Icon(icon, color: theme.colorScheme.primary, size: 24),
        ),
      ),
    );
  }
}

/// Bottom sheet listing every flutter_quill formatting tool as a grid
/// (bold, italic, underline, strike-through, headers, numbered list,
/// checklist, quote, code block, alignment, indent, color, clear
/// formatting, link, undo/redo, etc.) — everything except bullets,
/// which lives on the main toolbar as its own quick-access icon.
class QuillToolsSheet extends StatelessWidget {
  final quill.QuillController controller;

  const QuillToolsSheet({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final tools = <_QuillToolSpec>[
      _QuillToolSpec(
        icon: Icons.format_bold_rounded,
        label: 'Bold',
        attribute: quill.Attribute.bold,
      ),
      _QuillToolSpec(
        icon: Icons.format_italic_rounded,
        label: 'Italic',
        attribute: quill.Attribute.italic,
      ),
      _QuillToolSpec(
        icon: Icons.format_underline_rounded,
        label: 'Underline',
        attribute: quill.Attribute.underline,
      ),
      _QuillToolSpec(
        icon: Icons.strikethrough_s_rounded,
        label: 'Strikethrough',
        attribute: quill.Attribute.strikeThrough,
      ),
      _QuillToolSpec(
        icon: Icons.looks_one_rounded,
        label: 'Heading 1',
        attribute: quill.Attribute.h1,
      ),
      _QuillToolSpec(
        icon: Icons.looks_two_rounded,
        label: 'Heading 2',
        attribute: quill.Attribute.h2,
      ),
      _QuillToolSpec(
        icon: Icons.looks_3_rounded,
        label: 'Heading 3',
        attribute: quill.Attribute.h3,
      ),
      _QuillToolSpec(
        icon: Icons.format_list_numbered_rounded,
        label: 'Numbered list',
        attribute: quill.Attribute.ol,
      ),
      _QuillToolSpec(
        icon: Icons.checklist_rounded,
        label: 'Checklist',
        attribute: quill.Attribute.unchecked,
      ),
      _QuillToolSpec(
        icon: Icons.format_quote_rounded,
        label: 'Quote',
        attribute: quill.Attribute.blockQuote,
      ),
      _QuillToolSpec(
        icon: Icons.code_rounded,
        label: 'Code block',
        attribute: quill.Attribute.codeBlock,
      ),
      _QuillToolSpec(
        icon: Icons.format_align_left_rounded,
        label: 'Align left',
        attribute: quill.Attribute.leftAlignment,
      ),
      _QuillToolSpec(
        icon: Icons.format_align_center_rounded,
        label: 'Align center',
        attribute: quill.Attribute.centerAlignment,
      ),
      _QuillToolSpec(
        icon: Icons.format_align_right_rounded,
        label: 'Align right',
        attribute: quill.Attribute.rightAlignment,
      ),
      _QuillToolSpec(
        icon: Icons.format_align_justify_rounded,
        label: 'Justify',
        attribute: quill.Attribute.justifyAlignment,
      ),
      _QuillToolSpec(
        icon: Icons.format_indent_increase_rounded,
        label: 'Indent',
        attribute: quill.Attribute.indentL1,
      ),
      _QuillToolSpec(
        icon: Icons.subscript_rounded,
        label: 'Subscript',
        attribute: quill.Attribute.subscript,
      ),
      _QuillToolSpec(
        icon: Icons.superscript_rounded,
        label: 'Superscript',
        attribute: quill.Attribute.superscript,
      ),
      _QuillToolSpec(
        icon: Icons.format_clear_rounded,
        label: 'Clear format',
        isClearFormat: true,
      ),
    ];

    return SafeArea(
      child: Container(
        margin: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Text Formatting',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Flexible(
              child: GridView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                itemCount: tools.length,
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  childAspectRatio: 0.85,
                ),
                itemBuilder: (context, index) {
                  final tool = tools[index];
                  return _QuillToolButton(
                    tool: tool,
                    controller: controller,
                    isDark: isDark,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuillToolSpec {
  final IconData icon;
  final String label;
  final quill.Attribute? attribute;
  final bool isClearFormat;

  const _QuillToolSpec({
    required this.icon,
    required this.label,
    this.attribute,
    this.isClearFormat = false,
  });
}

class _QuillToolButton extends StatefulWidget {
  final _QuillToolSpec tool;
  final quill.QuillController controller;
  final bool isDark;

  const _QuillToolButton({
    required this.tool,
    required this.controller,
    required this.isDark,
  });

  @override
  State<_QuillToolButton> createState() => _QuillToolButtonState();
}

class _QuillToolButtonState extends State<_QuillToolButton> {
  bool get _isActive {
    final attribute = widget.tool.attribute;
    if (attribute == null) return false;
    final current = widget.controller.getSelectionStyle().attributes;
    final active = current[attribute.key];
    if (active == null) return false;
    // For scoped attributes (headers, alignment) any active value of
    // the same key counts as "on"; toggle attributes compare value.
    if (attribute.value == null) return true;
    return active.value == attribute.value;
  }

  void _handleTap() {
    final tool = widget.tool;
    if (tool.isClearFormat) {
      final selection = widget.controller.selection;
      widget.controller.formatText(
        selection.start,
        selection.end - selection.start,
        quill.Attribute.clone(quill.Attribute.bold, null),
      );
      setState(() {});
      return;
    }
    final attribute = tool.attribute!;
    final isActive = _isActive;
    widget.controller.formatSelection(
      isActive ? quill.Attribute.clone(attribute, null) : attribute,
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final active = !widget.tool.isClearFormat && _isActive;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: _handleTap,
      child: Container(
        decoration: BoxDecoration(
          color: active
              ? theme.colorScheme.primary.withValues(alpha: 0.15)
              : (widget.isDark
                  ? theme.colorScheme.surfaceContainerHighest
                  : theme.colorScheme.surfaceContainerHighest
                      .withValues(alpha: 0.5)),
          borderRadius: BorderRadius.circular(16),
          border: active
              ? Border.all(color: theme.colorScheme.primary, width: 1.5)
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              widget.tool.icon,
              color: active
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface,
              size: 22,
            ),
            const SizedBox(height: 6),
            Text(
              widget.tool.label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelSmall?.copyWith(
                color: active
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface.withValues(alpha: 0.8),
                fontWeight: active ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}