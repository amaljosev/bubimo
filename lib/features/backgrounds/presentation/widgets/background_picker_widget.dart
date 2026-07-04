// lib/features/backgrounds/presentation/widgets/background_picker_widget.dart

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/di/injection.dart';
import '../bloc/background_picker/background_picker_bloc.dart';
import '../bloc/background_picker/background_picker_event.dart';
import '../bloc/background_picker/background_picker_state.dart';

/// Where a selected background came from — determines which of
/// `DiaryEntry`'s three background fields the caller should set.
enum BackgroundSourceType {
  /// A bundled local asset — always available offline, no caching
  /// needed. Caller should set `bgImagePath`.
  presetLocal,

  /// A Supabase-fetched preset, already downloaded and cached locally
  /// by the time this is returned. Caller should set `bgLocalPath`.
  presetRemote,

  /// Picked from the device gallery. Caller should set
  /// `bgGalleryImagePath`.
  gallery,
}

class SelectedBackground {
  final BackgroundSourceType type;
  final String path;

  const SelectedBackground({required this.type, required this.path});
}

/// Lets the user choose a background: bundled presets, Supabase-fetched
/// presets (if online), or their own gallery photo. Returns the
/// selection via [onSelected] — this widget doesn't touch the diary
/// entry itself, the caller (diary_form_page) applies it based on
/// [SelectedBackground.type].
class BackgroundPickerWidget extends StatefulWidget {
  final ValueChanged<SelectedBackground> onSelected;

  const BackgroundPickerWidget({super.key, required this.onSelected});

  @override
  State<BackgroundPickerWidget> createState() =>
      _BackgroundPickerWidgetState();
}

class _BackgroundPickerWidgetState extends State<BackgroundPickerWidget>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _pickFromGallery() async {
    final picked = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      widget.onSelected(
        SelectedBackground(
          type: BackgroundSourceType.gallery,
          path: picked.path,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          getIt<BackgroundPickerBloc>()..add(const LoadBackgrounds()),
      child: SizedBox(
        height: 420,
        child: Column(
          children: [
            TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'Presets'),
                Tab(text: 'Gallery'),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _PresetsTab(onSelected: widget.onSelected),
                  _GalleryTab(onPickPressed: _pickFromGallery),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PresetsTab extends StatelessWidget {
  final ValueChanged<SelectedBackground> onSelected;

  const _PresetsTab({required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BackgroundPickerBloc, BackgroundPickerState>(
      builder: (context, state) {
        return ListView(
          padding: const EdgeInsets.all(12),
          children: [
            Text('Bundled', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            _BackgroundGrid(
              paths: state.localPresets,
              isAsset: true,
              onTap: (path) => onSelected(
                SelectedBackground(
                  type: BackgroundSourceType.presetLocal,
                  path: path,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text('Downloaded', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            if (!state.remoteFetchAttempted)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              )
            else if (state.remoteFetchFailed)
              Text(
                'Couldn\'t load more backgrounds — check your connection.',
                style: Theme.of(context).textTheme.bodySmall,
              )
            else if (state.remotePresets.isEmpty)
              Text(
                'No additional packs available right now.',
                style: Theme.of(context).textTheme.bodySmall,
              )
            else
              _BackgroundGrid(
                paths: state.remotePresets,
                isAsset: false,
                onTap: (path) => onSelected(
                  SelectedBackground(
                    type: BackgroundSourceType.presetRemote,
                    path: path,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _BackgroundGrid extends StatelessWidget {
  final List<String> paths;
  final bool isAsset;
  final ValueChanged<String> onTap;

  const _BackgroundGrid({
    required this.paths,
    required this.isAsset,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (paths.isEmpty) {
      return Text(
        'None available.',
        style: Theme.of(context).textTheme.bodySmall,
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1,
      ),
      itemCount: paths.length,
      itemBuilder: (context, index) {
        final path = paths[index];
        return InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () => onTap(path),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: isAsset
                ? Image.asset(path, fit: BoxFit.cover)
                : Image.file(File(path), fit: BoxFit.cover),
          ),
        );
      },
    );
  }
}

class _GalleryTab extends StatelessWidget {
  final VoidCallback onPickPressed;

  const _GalleryTab({required this.onPickPressed});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FilledButton.icon(
        onPressed: onPickPressed,
        icon: const Icon(Icons.photo_library_outlined),
        label: const Text('Choose from gallery'),
      ),
    );
  }
}

/// Shows [BackgroundPickerWidget] in a modal bottom sheet. Returns the
/// selection, or null if dismissed without choosing.
Future<SelectedBackground?> showBackgroundPickerSheet(BuildContext context) {
  return showModalBottomSheet<SelectedBackground>(
    context: context,
    isScrollControlled: true,
    builder: (sheetContext) {
      return BackgroundPickerWidget(
        onSelected: (selection) => Navigator.of(sheetContext).pop(selection),
      );
    },
  );
}