// lib/features/diary_entry/presentation/pages/diary_form_page.dart

import 'dart:async';

import 'package:bubimo/core/utils/background_image_utils.dart';
import 'package:bubimo/core/utils/overlay_tint_utils.dart';
import 'package:bubimo/core/utils/quill_document_utils.dart';
import 'package:bubimo/features/diary_entry/presentation/widgets/diary_bottom_toolbar.dart';
import 'package:bubimo/features/diary_entry/presentation/widgets/diary_form/diary_form_header.dart';
import 'package:bubimo/features/diary_entry/presentation/widgets/diary_form/diary_form_overlay_settings_sheet.dart';
import 'package:bubimo/features/diary_entry/presentation/widgets/font_picker.dart';
import 'package:bubimo/features/diary_entry/presentation/widgets/mood_popover.dart';
import 'package:bubimo/features/diary_entry/presentation/widgets/overlay/overlay_layer.dart';
import 'package:bubimo/features/diary_entry/presentation/widgets/overlay/resizable_image_embed_builder.dart';
import 'package:bubimo/features/diary_entry/presentation/widgets/overlay/sticker_picker_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/utils/id_generator.dart';
import '../../../../core/widgets/error_screen.dart';
import '../../../../core/widgets/loading_screen.dart';
import '../../../backgrounds/presentation/widgets/background_picker_widget.dart';
import '../../domain/entities/mood.dart';
import '../../domain/entities/overlay_image.dart';
import '../bloc/diary_form/diary_form_bloc.dart';
import '../bloc/diary_form/diary_form_event.dart';
import '../bloc/diary_form/diary_form_state.dart';
import '../bloc/sticker_picker/sticker_picker_bloc.dart';

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

  // Explicit, stable focus nodes for the title field and the Quill
  // editor. Without these, Flutter falls back to implicit/ambient
  // focus behavior, which — combined with this screen rebuilding on
  // every keystroke (each Quill content change dispatches to the bloc,
  // which emits a new state and rebuilds the whole tree) — was causing
  // focus to jump from the description back to the title field mid-typing.
  // Keeping these nodes alive across rebuilds (they're fields, not
  // rebuilt in `build`) anchors focus to whichever field the user
  // actually tapped.
  final FocusNode _titleFocusNode = FocusNode();
  final FocusNode _descriptionFocusNode = FocusNode();

  // Defines the coordinate space and clamp bounds for overlay images
  // and stickers — wraps the Quill editor container specifically (not
  // the whole scrollable list), matching the old project's convention
  // of confining overlay items to the text-entry area only.
  final GlobalKey _editorBoundsKey = GlobalKey();

  // Anchors the mood popover so it appears directly below the mood
  // avatar in the header, like a speech bubble pointing back up at it.
  final GlobalKey _moodAvatarKey = GlobalKey();

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
    _titleFocusNode.dispose();
    _descriptionFocusNode.dispose();
    _quillController?.removeListener(_onQuillContentChanged);
    _quillController?.dispose();
    super.dispose();
  }

  void _initQuillController(String rawContent) {
    final document = QuillDocumentUtils.documentFromContent(rawContent);
    _quillController = quill.QuillController(
      document: document,
      selection: const TextSelection.collapsed(offset: 0),
    );
    _quillController!.addListener(_onQuillContentChanged);
  }

  void _onQuillContentChanged() {
    final deltaJson = QuillDocumentUtils.contentFromController(_quillController!);
    _bloc.add(DiaryFormContentChanged(deltaJson));
  }

  /// Whether the Quill document currently has any non-whitespace text.
  /// Used for the "at least one of title/description" save validation.
  bool get _hasDescriptionText =>
      _quillController != null &&
      _quillController!.document.toPlainText().trim().isNotEmpty;

  /// Inserts an image embed (gallery photos only — stickers never go
  /// into the Quill document, they're floating overlays) at the
  /// current cursor position.
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
    FocusManager.instance.primaryFocus?.unfocus();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: isDark ? theme.colorScheme.surface : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        DateTime picked = current;
        return SafeArea(
          child: SizedBox(
            height: 300,
            child: Column(
              children: [
                Expanded(
                  child: CalendarDatePicker(
                    initialDate: current,
                    firstDate: DateTime(2000),
                    lastDate: DateTime.now(),
                    onDateChanged: (value) => picked = value,
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.1)
                            : Colors.black.withValues(alpha: 0.1),
                        width: 0.5,
                      ),
                    ),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        if (context.mounted) {
                          this
                              .context
                              .read<DiaryFormBloc>()
                              .add(DiaryFormDateChanged(picked));
                        }
                        Navigator.pop(sheetContext);
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        alignment: Alignment.center,
                        child: Text(
                          'Done',
                          style: TextStyle(
                            color: theme.colorScheme.primary,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
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

  Future<void> _openMoodPopover(BuildContext context, Mood? currentMood) async {
    final result = await showMoodPopover(
      context,
      anchorKey: _moodAvatarKey,
      selectedMood: currentMood,
    );
    // `result == null` means the popover was dismissed without a
    // choice (barrier tap) — leave the mood untouched. A non-null
    // result (even with `.mood == null`, meaning "cleared") should be
    // applied.
    if (result != null && context.mounted) {
      context.read<DiaryFormBloc>().add(DiaryFormMoodChanged(result.mood));
    }
  }

  /// Opens the sticker picker sheet. Unlike gallery overlay photos
  /// (already a local file the moment they're picked), a sticker must
  /// be downloaded from Supabase first — so that download happens here,
  /// before the item ever reaches [DiaryFormBloc]. This keeps
  /// `DiaryFormBloc` free of any network/IO concerns, matching how it
  /// never talks to Supabase directly for backgrounds either.
  Future<void> _openStickerPicker(BuildContext context) async {
    final url = await showStickerPickerSheet(context);
    if (url == null || !context.mounted) return;

    final pickerBloc = getIt<StickerPickerBloc>();
    try {
      // Show a lightweight blocking indicator while the sticker
      // downloads — this is typically instant for cached stickers and
      // brief even on first download, so a full loading screen would
      // be overkill; a snackbar-free short wait keeps the flow simple.
      final localPath = await _downloadSticker(pickerBloc, url);
      if (localPath == null || !mounted) return;

      final bounds =
          _editorBoundsKey.currentContext?.findRenderObject() as RenderBox?;
      final position = OverlayLayer.findFreePosition(
        bounds: bounds != null
            ? Rect.fromLTWH(0, 0, bounds.size.width, bounds.size.height)
            : null,
        existingImages: _bloc.state.overlayImages,
        existingStickers: _bloc.state.stickers,
        width: 100,
        height: 100,
      );

      _bloc.add(
        DiaryFormStickerAdded(
          id: IdGenerator.generate(),
          url: url,
          localPath: localPath,
          x: position.dx,
          y: position.dy,
        ),
      );
    } finally {
      pickerBloc.close();
    }
  }

  /// Drives [StickerPickerBloc] for a single download-and-return flow,
  /// outside of any widget tree — the picker sheet itself has already
  /// closed by this point, so there's nowhere to put a `BlocListener`.
  Future<String?> _downloadSticker(
    StickerPickerBloc pickerBloc,
    String url,
  ) async {
    final completer = Completer<String?>();
    late final StreamSubscription subscription;
    subscription = pickerBloc.stream.listen((state) {
      if (state.lastDownloaded?.url == url) {
        subscription.cancel();
        completer.complete(state.lastDownloaded!.localPath);
      } else if (state.downloadError != null && !state.isDownloading) {
        subscription.cancel();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.downloadError!)),
          );
        }
        completer.complete(null);
      }
    });
    pickerBloc.add(StickerSelected(url));
    return completer.future;
  }

  void _onImagePicked(String path) {
    _insertImageEmbed(path);
    _bloc.add(DiaryFormImageAdded(path));
  }

  /// Picks a photo for inline insertion into the Quill document body.
  Future<void> _pickInlineImage() async {
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (image != null && mounted) {
        _onImagePicked(image.path);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to pick image: $e')),
        );
      }
    }
  }

  /// Picks a photo for a free-floating overlay on top of the entry.
  Future<void> _pickOverlayImage() async {
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (image != null && mounted) {
        _onOverlayImagePicked(image.path);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to pick image: $e')),
        );
      }
    }
  }

  /// Adds a new floating overlay photo — entirely separate from
  /// [_onImagePicked]'s inline Quill embed. Finds an unoccupied spot
  /// within the editor bounds so new photos don't stack directly on top
  /// of each other, existing overlay images, or stickers.
  void _onOverlayImagePicked(String path) {
    final bounds =
        _editorBoundsKey.currentContext?.findRenderObject() as RenderBox?;
    final position = OverlayLayer.findFreePosition(
      bounds: bounds != null
          ? Rect.fromLTWH(0, 0, bounds.size.width, bounds.size.height)
          : null,
      existingImages: _bloc.state.overlayImages,
      existingStickers: _bloc.state.stickers,
      width: OverlayImage.baseWidth,
      height: OverlayImage.baseHeight,
    );
    _bloc.add(
      DiaryFormOverlayImageAdded(
        id: IdGenerator.generate(),
        path: path,
        x: position.dx,
        y: position.dy,
      ),
    );
  }

  void _onOverlayImageSelect(String id) {
    _bloc.add(DiaryFormOverlayImageSelected(id));
  }

  void _onOverlayImageDeselect() {
    if (_bloc.state.selectedOverlayImageId == null &&
        _bloc.state.selectedStickerId == null) {
      return;
    }
    _bloc.add(const DiaryFormOverlayImageSelected(null));
    _bloc.add(const DiaryFormStickerSelected(null));
  }

  void _onOverlayImageTransform({
    required String id,
    required double x,
    required double y,
    required double scale,
    required double rotation,
  }) {
    _bloc.add(
      DiaryFormOverlayImageTransformed(
        id: id,
        x: x,
        y: y,
        scale: scale,
        rotation: rotation,
      ),
    );
  }

  void _onOverlayImageRemove(String id) {
    _bloc.add(DiaryFormOverlayImageRemoved(id));
  }

  void _onStickerSelect(String id) {
    _bloc.add(DiaryFormStickerSelected(id));
  }

  void _onStickerTransform({
    required String id,
    required double x,
    required double y,
    required double scale,
    required double rotation,
  }) {
    _bloc.add(
      DiaryFormStickerTransformed(
        id: id,
        x: x,
        y: y,
        scale: scale,
        rotation: rotation,
      ),
    );
  }

  void _onStickerRemove(String id) {
    _bloc.add(DiaryFormStickerRemoved(id));
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

  void _openFontPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => FontPicker(
        selectedFontFamily: _bloc.state.fontFamily,
        onFontSelected: (family) {
          _applyFontFamily(family);
          Navigator.pop(context);
        },
      ),
    );
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

  /// Whether a sticker or overlay image currently has selection focus.
  /// While true, the description area's own text-scroll is disabled so
  /// scroll/drag gestures reach the selected item's pan handler instead
  /// (see [OverlayLayer] and the description's [SingleChildScrollView]
  /// physics). Deselecting — including the outside-tap handled by
  /// [OverlayLayer]'s `onDeselect` — flows back through the bloc and
  /// restores normal scrolling on the next build.
  bool _hasOverlaySelection(DiaryFormState state) =>
      state.selectedOverlayImageId != null || state.selectedStickerId != null;

  /// Opens the bottom sheet for adjusting the background overlay tint's
  /// opacity and color. Only meaningful when a background image is set,
  /// so the caller only shows the settings icon in that case.
  Future<void> _openOverlaySettingsSheet(BuildContext context) async {
    final bloc = _bloc;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return BlocProvider.value(
          value: bloc,
          child: const DiaryFormOverlaySettingsSheet(),
        );
      },
    );
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

        final backgroundImage = BackgroundImageUtils.resolveProvider(
          bgGalleryImagePath: state.bgGalleryImagePath,
          bgImagePath: state.bgImagePath,
          bgLocalPath: state.bgLocalPath,
        );

        // Save requires at least some content — either a title or a
        // non-empty description — mirroring the reference app's rule.
        final canSave =
            state.title.trim().isNotEmpty || _hasDescriptionText;

        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Text(state.isEditMode ? 'Edit Entry' : 'New Entry'),
            actions: [
              if (backgroundImage != null)
                IconButton(
                  tooltip: 'Background overlay settings',
                  icon: const Icon(Icons.tune),
                  onPressed: () => _openOverlaySettingsSheet(context),
                ),
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Center(
                  child: FilledButton(
                    onPressed: (canSave && !state.isSubmitting)
                        ? () => context
                            .read<DiaryFormBloc>()
                            .add(const DiaryFormSubmitted())
                        : null,
                    style: FilledButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                    ),
                    child: state.isSubmitting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Save'),
                  ),
                ),
              ),
            ],
          ),
          body: Container(
            decoration: backgroundImage != null
                ? BoxDecoration(
                    image: DecorationImage(
                      image: backgroundImage,
                      fit: BoxFit.cover,
                      colorFilter: OverlayTintUtils.resolveColorFilter(
                        bgOverlayColor: state.bgOverlayColor,
                        themeBrightness: Theme.of(context).brightness,
                        opacity: state.bgOverlayOpacity,
                      ),
                    ),
                  )
                : null,
            child: SafeArea(
              child: Column(
                children: [
                  // ── Fixed header: date, mood, title ──────────────────
                  // Pinned (not part of any scroll view) so the
                  // description area below can claim a stable,
                  // known-at-layout-time height — required for overlay
                  // items' bounds/positions to stay correct while
                  // dragging, and to avoid the editor shifting under a
                  // sticker mid-drag if this section were to scroll.
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                    child: Column(
                      children: [
                        DiaryFormHeaderRow(
                          date: state.date,
                          mood: state.mood,
                          moodAvatarKey: _moodAvatarKey,
                          onDateTap: () => _pickDate(context, state.date),
                          onMoodTap: () =>
                              _openMoodPopover(context, state.mood),
                        ),
                        const SizedBox(height: 20),
                        DiaryFormTitleField(
                          controller: _titleController,
                          focusNode: _titleFocusNode,
                          nextFocusNode: _descriptionFocusNode,
                          onChanged: (value) => context
                              .read<DiaryFormBloc>()
                              .add(DiaryFormTitleChanged(value)),
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                  // ── Description area: fills all remaining height ────
                  // The sticker/overlay-image coordinate space and drag
                  // bounds are scoped to exactly this box. Scrolling
                  // here is for text overflow only, and is disabled
                  // whenever an overlay item is selected so that drag
                  // gestures go to the selected item instead of the
                  // scroll view.
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        // `_editorBoundsKey` is attached to this
                        // viewport-sized box (not the scrollable
                        // content inside it), so overlay items are
                        // always positioned/clamped against the fixed
                        // visible area — matching "sticker should only
                        // be movable within the description area" and
                        // keeping bounds stable regardless of how much
                        // text the entry has.
                        return OverlayLayer(
                          boundsKey: _editorBoundsKey,
                          images: state.overlayImages,
                          stickers: state.stickers,
                          selectedImageId: state.selectedOverlayImageId,
                          selectedStickerId: state.selectedStickerId,
                          onSelectImage: _onOverlayImageSelect,
                          onSelectSticker: _onStickerSelect,
                          onDeselect: _onOverlayImageDeselect,
                          onImageTransform: _onOverlayImageTransform,
                          onStickerTransform: _onStickerTransform,
                          onRemoveImage: _onOverlayImageRemove,
                          onRemoveSticker: _onStickerRemove,
                          child: Container(
                            key: _editorBoundsKey,
                            width: constraints.maxWidth,
                            height: constraints.maxHeight,
                            padding:
                                const EdgeInsets.fromLTRB(20, 12, 20, 16),
                            child: SingleChildScrollView(
                              // Locked while a sticker/overlay image is
                              // selected: scroll gestures over the
                              // description area must reach the
                              // selected item's own pan handler instead
                              // of being consumed here.
                              physics: _hasOverlaySelection(state)
                                  ? const NeverScrollableScrollPhysics()
                                  : const BouncingScrollPhysics(),
                              child: quill.QuillEditor.basic(
                                controller: _quillController!,
                                focusNode: _descriptionFocusNode,
                                config: quill.QuillEditorConfig(
                                  placeholder: "What's on your mind?",
                                  padding: EdgeInsets.zero,
                                  scrollable: false,
                                  embedBuilders: [
                                    // Custom builder first — Quill uses
                                    // the first builder whose `key`
                                    // matches, so this takes priority
                                    // over the stock image builder below
                                    // for the image embed type, giving
                                    // it a working drag-to-resize handle
                                    // on every platform (the stock
                                    // builder only resizes via a desktop
                                    // context menu).
                                    ResizableImageEmbedBuilder(),
                                    ...FlutterQuillEmbeds.editorBuilders(),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  DiaryBottomToolbar(
                    controller: _quillController!,
                    onBackgroundPressed: () => _openBackgroundPicker(context),
                    onFontPressed: () => _openFontPicker(context),
                    onStickerPressed: () => _openStickerPicker(context),
                    onOverlayImagePressed: _pickOverlayImage,
                    onInlineImagePressed: _pickInlineImage,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}