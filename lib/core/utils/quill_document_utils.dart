// lib/core/utils/quill_document_utils.dart

import 'dart:convert';

import 'package:flutter_quill/flutter_quill.dart' as quill;

/// Parses/serializes the Quill Delta JSON stored on a diary entry's
/// `content` field.
///
/// Previously duplicated identically (down to the doc comment) in
/// `DiaryFormPage._documentFromContent` and
/// `DiaryEntryViewPage._documentFromContent`.
abstract final class QuillDocumentUtils {
  /// Parses stored Quill Delta JSON into a [quill.Document]. Falls
  /// back to a blank document for empty content, or a single-line
  /// document wrapping the raw text if it isn't valid Delta JSON —
  /// covers legacy plain-text entries saved before the rich editor
  /// existed.
  static quill.Document documentFromContent(String rawContent) {
    final trimmed = rawContent.trim();
    if (trimmed.isEmpty) return quill.Document();

    try {
      final decoded = jsonDecode(trimmed);
      return quill.Document.fromJson(decoded as List);
    } catch (_) {
      return quill.Document()..insert(0, trimmed);
    }
  }

  /// Serializes a controller's current document back to the Delta
  /// JSON string format used for storage.
  static String contentFromController(quill.QuillController controller) {
    return jsonEncode(controller.document.toDelta().toJson());
  }
}