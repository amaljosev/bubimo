// lib/features/backgrounds/presentation/bloc/background_picker/background_picker_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/datasources/supabase_background_data_source.dart';
import 'background_picker_event.dart';
import 'background_picker_state.dart';

/// Bundled local preset asset paths. Replace with your actual pack —
/// each must be declared under `flutter: assets:` in pubspec.yaml.
const List<String> _bundledBackgroundPaths = [
  'assets/backgrounds/local/bg_1.jpeg',
  'assets/backgrounds/local/bg_2.webp',
  
];

/// Drives the background picker. Local presets are bundled assets and
/// shown instantly; Supabase Storage presets (bucket `assets`, folder
/// `bg_presets`) are fetched and cached in the background afterward,
/// since the app is offline-first and must never block the picker on a
/// network call.
class BackgroundPickerBloc
    extends Bloc<BackgroundPickerEvent, BackgroundPickerState> {
  final SupabaseBackgroundDataSource remoteDataSource;

  BackgroundPickerBloc({required this.remoteDataSource})
      : super(const BackgroundPickerState()) {
    on<LoadBackgrounds>(_onLoadBackgrounds);
  }

  Future<void> _onLoadBackgrounds(
    LoadBackgrounds event,
    Emitter<BackgroundPickerState> emit,
  ) async {
    // Local presets are always available — show them immediately
    // without waiting on the network.
    emit(
      state.copyWith(
        status: BackgroundPickerStatus.loaded,
        localPresets: _bundledBackgroundPaths,
      ),
    );

    try {
      final urls = await remoteDataSource.fetchAvailablePackUrls();

      final cachedPaths = <String>[];
      for (final url in urls) {
        final localPath = await remoteDataSource.downloadAndCache(url);
        cachedPaths.add(localPath);
      }

      emit(
        state.copyWith(
          remotePresets: cachedPaths,
          remoteFetchAttempted: true,
          remoteFetchFailed: false,
        ),
      );
    } catch (_) {
      // Offline, or the request/download failed — non-fatal. Local
      // presets remain fully usable; just note the remote section
      // couldn't load.
      emit(
        state.copyWith(
          remoteFetchAttempted: true,
          remoteFetchFailed: true,
        ),
      );
    }
  }
}