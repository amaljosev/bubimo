// lib/features/backgrounds/presentation/bloc/background_picker/background_picker_event.dart

import 'package:equatable/equatable.dart';

sealed class BackgroundPickerEvent extends Equatable {
  const BackgroundPickerEvent();

  @override
  List<Object?> get props => [];
}

/// Loads local bundled presets immediately, then attempts to fetch and
/// cache additional Supabase packs in the background. Fired once when
/// the background picker opens.
final class LoadBackgrounds extends BackgroundPickerEvent {
  const LoadBackgrounds();
}