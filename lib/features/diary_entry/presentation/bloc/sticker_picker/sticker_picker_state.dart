// lib/features/diary_entry/presentation/bloc/sticker_picker/sticker_picker_state.dart

part of 'sticker_picker_bloc.dart';

/// Result of a completed sticker download, carried on
/// [StickerPickerState] so the form page can react (insert the sticker
/// as an overlay) without the bloc needing to know anything about
/// [DiaryFormBloc].
class DownloadedSticker extends Equatable {
  final String url;
  final String localPath;

  const DownloadedSticker({required this.url, required this.localPath});

  @override
  List<Object?> get props => [url, localPath];
}

class StickerPickerState extends Equatable {
  final bool isLoadingCategories;
  final String? categoriesError;
  final Map<String, List<String>> stickersByCategory;

  final bool isDownloading;
  final String? downloadError;

  /// The most recently completed download. The widget layer consumes
  /// this once (e.g. via `BlocListener`) and the form page is
  /// responsible for actually placing the sticker — this bloc doesn't
  /// hold placement/position state itself.
  final DownloadedSticker? lastDownloaded;

  const StickerPickerState({
    this.isLoadingCategories = false,
    this.categoriesError,
    this.stickersByCategory = const {},
    this.isDownloading = false,
    this.downloadError,
    this.lastDownloaded,
  });

  bool get hasLoadedCategories => stickersByCategory.isNotEmpty;

  StickerPickerState copyWith({
    bool? isLoadingCategories,
    String? categoriesError,
    bool clearCategoriesError = false,
    Map<String, List<String>>? stickersByCategory,
    bool? isDownloading,
    String? downloadError,
    bool clearDownloadError = false,
    DownloadedSticker? lastDownloaded,
  }) {
    return StickerPickerState(
      isLoadingCategories: isLoadingCategories ?? this.isLoadingCategories,
      categoriesError: clearCategoriesError
          ? null
          : (categoriesError ?? this.categoriesError),
      stickersByCategory: stickersByCategory ?? this.stickersByCategory,
      isDownloading: isDownloading ?? this.isDownloading,
      downloadError:
          clearDownloadError ? null : (downloadError ?? this.downloadError),
      lastDownloaded: lastDownloaded ?? this.lastDownloaded,
    );
  }

  @override
  List<Object?> get props => [
        isLoadingCategories,
        categoriesError,
        stickersByCategory,
        isDownloading,
        downloadError,
        lastDownloaded,
      ];
}