// lib/features/diary_entry/presentation/bloc/sticker_picker/sticker_picker_bloc.dart

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/repositories/sticker_repository.dart';

part 'sticker_picker_event.dart';
part 'sticker_picker_state.dart';

/// Drives the sticker picker bottom sheet: loads the shared Supabase
/// sticker library grouped by category, and downloads/caches a sticker
/// once the user picks one.
///
/// Deliberately its own bloc (not folded into [DiaryFormBloc]) — the
/// sticker library is shared, unauthenticated, form-independent data,
/// same reasoning as why backgrounds got their own
/// `BackgroundPickerBloc` rather than living on the diary form bloc.
/// [DiaryFormBloc] only ever sees the end result (a downloaded sticker's
/// URL + local path) via [DiaryFormStickerAdded], never the picker's
/// loading/error state.
class StickerPickerBloc extends Bloc<StickerPickerEvent, StickerPickerState> {
  final StickerRepository stickerRepository;

  StickerPickerBloc({required this.stickerRepository})
      : super(const StickerPickerState()) {
    on<StickerPickerRequested>(_onRequested);
    on<StickerPickerRetried>(_onRequested);
    on<StickerSelected>(_onSelected);
  }

  Future<void> _onRequested(
    StickerPickerEvent event,
    Emitter<StickerPickerState> emit,
  ) async {
    // Categories are shared, static-ish content — don't re-fetch every
    // time the sheet is opened, only on first open or explicit retry.
    if (state.hasLoadedCategories && event is StickerPickerRequested) return;

    emit(
      state.copyWith(isLoadingCategories: true, clearCategoriesError: true),
    );

    final result = await stickerRepository.getStickersByCategory();

    result.match(
      (failure) => emit(
        state.copyWith(
          isLoadingCategories: false,
          categoriesError: failure.message,
        ),
      ),
      (categories) => emit(
        state.copyWith(
          isLoadingCategories: false,
          stickersByCategory: categories,
        ),
      ),
    );
  }

  Future<void> _onSelected(
    StickerSelected event,
    Emitter<StickerPickerState> emit,
  ) async {
    emit(state.copyWith(isDownloading: true, clearDownloadError: true));

    final result = await stickerRepository.downloadSticker(event.url);

    result.match(
      (failure) => emit(
        state.copyWith(isDownloading: false, downloadError: failure.message),
      ),
      (localPath) => emit(
        state.copyWith(
          isDownloading: false,
          lastDownloaded:
              DownloadedSticker(url: event.url, localPath: localPath),
        ),
      ),
    );
  }
}