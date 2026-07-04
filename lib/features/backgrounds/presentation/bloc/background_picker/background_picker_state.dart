// lib/features/backgrounds/presentation/bloc/background_picker/background_picker_state.dart

import 'package:equatable/equatable.dart';

enum BackgroundPickerStatus { initial, loaded }

class BackgroundPickerState extends Equatable {
  final BackgroundPickerStatus status;

  /// Bundled local asset paths — always available offline, shown
  /// immediately without waiting on any network call.
  final List<String> localPresets;

  /// Locally-cached file paths for Supabase-fetched packs. Populated
  /// asynchronously after [localPresets] is already shown; stays empty
  /// if the device is offline or the fetch fails.
  final List<String> remotePresets;

  /// True once a remote fetch attempt has finished (success or
  /// failure), so the UI can stop showing a "loading more" indicator
  /// for the remote section specifically.
  final bool remoteFetchAttempted;

  /// True if the remote fetch failed (e.g. offline). Non-fatal — local
  /// presets remain fully usable.
  final bool remoteFetchFailed;

  const BackgroundPickerState({
    this.status = BackgroundPickerStatus.initial,
    this.localPresets = const [],
    this.remotePresets = const [],
    this.remoteFetchAttempted = false,
    this.remoteFetchFailed = false,
  });

  BackgroundPickerState copyWith({
    BackgroundPickerStatus? status,
    List<String>? localPresets,
    List<String>? remotePresets,
    bool? remoteFetchAttempted,
    bool? remoteFetchFailed,
  }) {
    return BackgroundPickerState(
      status: status ?? this.status,
      localPresets: localPresets ?? this.localPresets,
      remotePresets: remotePresets ?? this.remotePresets,
      remoteFetchAttempted: remoteFetchAttempted ?? this.remoteFetchAttempted,
      remoteFetchFailed: remoteFetchFailed ?? this.remoteFetchFailed,
    );
  }

  @override
  List<Object?> get props => [
        status,
        localPresets,
        remotePresets,
        remoteFetchAttempted,
        remoteFetchFailed,
      ];
}