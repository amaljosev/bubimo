// lib/features/diary_entry/presentation/pages/diary_form_page.dart

import 'dart:convert';
import 'dart:io';

import 'package:bubimo/features/diary_entry/presentation/widgets/font_picker.dart';
import 'package:bubimo/features/diary_entry/presentation/widgets/image_picker_button.dart';
import 'package:bubimo/features/diary_entry/presentation/widgets/quill_toolbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/widgets/error_screen.dart';
import '../../../../core/widgets/loading_screen.dart';
import '../../../backgrounds/presentation/widgets/background_picker_widget.dart';
import '../bloc/diary_form/diary_form_bloc.dart';
import '../bloc/diary_form/diary_form_event.dart';
import '../bloc/diary_form/diary_form_state.dart';
import '../widgets/mood_picker.dart';

/// Create or edit a diary entry. Pass [entryId] to edit an existing
/// entry, or omit it to create a new one.
///
/// On successful save, pops with `true` so the calling screen (Home, or
/// Entry View when editing) knows to refresh its data.
class DiaryFormPage extends StatelessWidget {
  final String? entryId;

  const DiaryFormPage({super.key, this.entryId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<DiaryFormBloc>()
        ..add(DiaryFormInitialized(entryId: entryId)),
      child: const _DiaryFormView(),
    );
  }
}

class _DiaryFormView extends StatefulWidget {
  const _DiaryFormView();

  @override
  State<_DiaryFormView> createState() => _DiaryFormViewState();
}

class _DiaryFormViewState extends State<_DiaryFormView> {
  final TextEditingController _titleController = TextEditingController();

  // Created once the entry (or blank create form) has finished loading,
  // since Quill's controller needs its initial document up front rather
  // than being reassigned later.
  quill.QuillController? _quillController;
  bool _controllersSynced = false;

  // Captured once so listeners registered outside `build` (Quill
  // content changes) can dispatch bloc events without needing a
  // BuildContext at call time.
  late final DiaryFormBloc _bloc;
  bool _blocCaptured = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_blocCaptured) {
      _bloc = context.read<DiaryFormBloc>();
      _blocCaptured = true;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _quillController?.removeListener(_onQuillContentChanged);
    _quillController?.dispose();
    super.dispose();
  }

  void _initQuillController(String rawContent) {
    final document = _documentFromContent(rawContent);
    _quillController = quill.QuillController(
      document: document,
      selection: const TextSelection.collapsed(offset: 0),
    );
    _quillController!.addListener(_onQuillContentChanged);
  }

  /// Parses stored Quill Delta JSON into a [quill.Document]. Falls back
  /// to a blank document for empty content, or a single-line document
  /// wrapping the raw text if it isn't valid Delta JSON (covers legacy
  /// plain-text entries saved before the rich editor existed).
  quill.Document _documentFromContent(String rawContent) {
    final trimmed = rawContent.trim();
    if (trimmed.isEmpty) return quill.Document();

    try {
      final decoded = jsonDecode(trimmed);
      return quill.Document.fromJson(decoded as List);
    } catch (_) {
      return quill.Document()..insert(0, trimmed);
    }
  }

  void _onQuillContentChanged() {
    final deltaJson =
        jsonEncode(_quillController!.document.toDelta().toJson());
    _bloc.add(DiaryFormContentChanged(deltaJson));
  }

  /// Inserts an image embed (used for both gallery photos and stickers
  /// — visually identical, distinguished only by which list the caller
  /// tracks the path in) at the current cursor position.
  void _insertImageEmbed(String path) {
    final controller = _quillController!;
    final index = controller.selection.baseOffset.clamp(
      0,
      controller.document.length,
    );
    controller.replaceText(
      index,
      0,
      quill.BlockEmbed.image(path),
      TextSelection.collapsed(offset: index + 1),
    );
  }

  Future<void> _pickDate(BuildContext context, DateTime current) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && context.mounted) {
      context.read<DiaryFormBloc>().add(DiaryFormDateChanged(picked));
    }
  }

  Future<void> _openStickerPicker(BuildContext context) async {
    // final path = await showStickerPickerSheet(context);
    // if (path != null) {
    //   _insertImageEmbed(path);
    //   _bloc.add(DiaryFormStickerAdded(path));
    // }
  }

  void _onImagePicked(String path) {
    _insertImageEmbed(path);
    _bloc.add(DiaryFormImageAdded(path));
  }

  void _applyFontFamily(String? fontFamily) {
    final controller = _quillController!;
    // Applies the chosen font across the whole document. This is a
    // whole-entry font choice (stored on `DiaryEntry.fontFamily`), not
    // per-selection rich-text formatting — matches the original
    // requirement ("change the font" as an entry-level setting).
    controller.formatText(
      0,
      controller.document.length,
      quill.Attribute.fromKeyValue('font', fontFamily),
    );
    _bloc.add(DiaryFormFontFamilyChanged(fontFamily));
  }

  Future<void> _openBackgroundPicker(BuildContext context) async {
    final selection = await showBackgroundPickerSheet(context);
    if (selection == null) return;

    switch (selection.type) {
      case BackgroundSourceType.presetLocal:
        _bloc.add(DiaryFormBackgroundChanged(bgImagePath: selection.path));
      case BackgroundSourceType.presetRemote:
        _bloc.add(DiaryFormBackgroundChanged(bgLocalPath: selection.path));
      case BackgroundSourceType.gallery:
        _bloc.add(
          DiaryFormBackgroundChanged(bgGalleryImagePath: selection.path),
        );
    }
  }

  /// Resolves which background image to actually render, per the app's
  /// precedence rule: gallery > preset-local > preset-remote (cached).
  /// Solid `bgColor` isn't set by this milestone's picker, so it isn't
  /// resolved here.
  ImageProvider? _resolveBackgroundImage(DiaryFormState state) {
    if (state.bgGalleryImagePath != null) {
      return FileImage(File(state.bgGalleryImagePath!));
    }
    if (state.bgImagePath != null) {
      return AssetImage(state.bgImagePath!);
    }
    if (state.bgLocalPath != null) {
      return FileImage(File(state.bgLocalPath!));
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DiaryFormBloc, DiaryFormState>(
      listener: (context, state) {
        if (state.status == DiaryFormStatus.success) {
          context.pop(true);
        }
        if (state.status == DiaryFormStatus.failure &&
            state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage!)),
          );
        }

        // Initialize the title controller and Quill controller exactly
        // once, right after an existing entry finishes loading in edit
        // mode (or immediately for a blank create form).
        if (state.status == DiaryFormStatus.ready && !_controllersSynced) {
          _titleController.text = state.title;
          _initQuillController(state.content);
          _controllersSynced = true;
        }
      },
      builder: (context, state) {
        if (state.status == DiaryFormStatus.loadingEntry) {
          return const Scaffold(body: LoadingScreen());
        }

        if (state.status == DiaryFormStatus.failure && !_controllersSynced) {
          // Only show a full-screen error if we failed to even load the
          // entry (edit mode) — a save failure is shown as a snackbar
          // instead, so the user doesn't lose unsaved input.
          return Scaffold(
            body: ErrorScreen(
              message: state.errorMessage ?? 'Something went wrong.',
              onRetry: () => context.read<DiaryFormBloc>().add(
                    DiaryFormInitialized(
                      entryId: state.entryId,
                    ),
                  ),
            ),
          );
        }

        if (_quillController == null) {
          // Controllers not synced yet on this build — avoid rendering
          // the editor with a null controller.
          return const Scaffold(body: LoadingScreen());
        }

        final backgroundImage = _resolveBackgroundImage(state);

        return Scaffold(
          appBar: AppBar(
            title: Text(state.isEditMode ? 'Edit Entry' : 'New Entry'),
            actions: [
              IconButton(
                icon: const Icon(Icons.wallpaper_outlined),
                tooltip: 'Background',
                onPressed: () => _openBackgroundPicker(context),
              ),
              IconButton(
                icon: const Icon(Icons.emoji_emotions_outlined),
                tooltip: 'Add sticker',
                onPressed: () => _openStickerPicker(context),
              ),
              ImagePickerButton(onImageSelected: _onImagePicked),
            ],
          ),
          body: Container(
            decoration: backgroundImage != null
                ? BoxDecoration(
                    image: DecorationImage(
                      image: backgroundImage,
                      fit: BoxFit.cover,
                      colorFilter: ColorFilter.mode(
                        Colors.white.withValues(alpha: 0.85),
                        BlendMode.lighten,
                      ),
                    ),
                  )
                : null,
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      TextField(
                        controller: _titleController,
                        decoration: const InputDecoration(hintText: 'Title'),
                        onChanged: (value) => context
                            .read<DiaryFormBloc>()
                            .add(DiaryFormTitleChanged(value)),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: () => _pickDate(context, state.date),
                        icon: const Icon(Icons.calendar_today, size: 18),
                        label:
                            Text(AppDateUtils.toDisplayString(state.date)),
                      ),
                      const SizedBox(height: 16),
                      MoodPicker(
                        selectedMood: state.mood,
                        onMoodSelected: (mood) => context
                            .read<DiaryFormBloc>()
                            .add(DiaryFormMoodChanged(mood)),
                      ),
                      const SizedBox(height: 16),
                      FontPicker(
                        selectedFontFamily: state.fontFamily,
                        onFontSelected: _applyFontFamily,
                      ),
                      const SizedBox(height: 12),
                      Container(
                        constraints: const BoxConstraints(minHeight: 240),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: backgroundImage != null
                              ? Colors.white.withValues(alpha: 0.6)
                              : null,
                          border: Border.all(color: Colors.black12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: quill.QuillEditor.basic(
                          controller: _quillController!,
                          config: quill.QuillEditorConfig(
                            embedBuilders: FlutterQuillEmbeds.editorBuilders(
                              imageEmbedConfig: QuillEditorImageEmbedConfig(
                                imageProviderBuilder: (context, imageSource) {
                                  if (imageSource.startsWith('http://') ||
                                      imageSource.startsWith('https://')) {
                                    return NetworkImage(imageSource);
                                  }
                                  return FileImage(File(imageSource));
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                RichEditorToolbar(controller: _quillController!),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: FilledButton(
                      // Guard against duplicate submissions: disable the
                      // button entirely while a save is already in flight.
                      onPressed: state.isSubmitting
                          ? null
                          : () => context
                              .read<DiaryFormBloc>()
                              .add(const DiaryFormSubmitted()),
                      child: state.isSubmitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child:
                                  CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Save'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}