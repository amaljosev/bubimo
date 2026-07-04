// lib/features/rich_editor/presentation/widgets/quill_toolbar.dart

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;

/// Wraps [quill.QuillSimpleToolbar] with app-consistent styling and a
/// fixed set of formatting tools appropriate for a diary entry (text
/// style, bullet lists — no headers/embeds toolbar buttons, since
/// stickers/images/font are handled by dedicated pickers alongside this
/// toolbar rather than through Quill's built-in embed buttons).
///
/// This does not replace the raw `QuillSimpleToolbar` currently used in
/// `diary_form_page.dart` automatically — swap it in there to pick up
/// this consistent styling.
class RichEditorToolbar extends StatelessWidget {
  final quill.QuillController controller;

  const RichEditorToolbar({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        border: Border(
          top: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
        ),
      ),
      child: quill.QuillSimpleToolbar(
        controller: controller,
        config: const quill.QuillSimpleToolbarConfig(
          showFontFamily: false,
          showFontSize: false,
          showSearchButton: false,
          showSubscript: false,
          showSuperscript: false,
          showCodeBlock: false,
          showQuote: false,
          showIndent: false,
          showLink: false,
          showClearFormat: false,
          multiRowsDisplay: false,
        ),
      ),
    );
  }
}