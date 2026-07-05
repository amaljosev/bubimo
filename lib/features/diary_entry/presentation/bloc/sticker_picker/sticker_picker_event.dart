// lib/features/diary_entry/presentation/bloc/sticker_picker/sticker_picker_event.dart

part of 'sticker_picker_bloc.dart';

sealed class StickerPickerEvent extends Equatable {
  const StickerPickerEvent();

  @override
  List<Object?> get props => [];
}

/// Fired when the sticker picker sheet opens. The bloc only actually
/// fetches from Supabase if categories haven't been loaded yet this
/// session — repeated opens of the sheet are free.
final class StickerPickerRequested extends StickerPickerEvent {
  const StickerPickerRequested();
}

/// Fired when the user taps "try again" after a load failure.
final class StickerPickerRetried extends StickerPickerEvent {
  const StickerPickerRetried();
}

/// Fired when a sticker thumbnail is tapped. Triggers the
/// download-and-cache flow; the picker sheet itself pops immediately in
/// the UI layer without waiting for this to resolve — the download
/// completes in the background and the caller is notified via
/// [StickerPickerState.lastDownloaded].
final class StickerSelected extends StickerPickerEvent {
  final String url;

  const StickerSelected(this.url);

  @override
  List<Object?> get props => [url];
}