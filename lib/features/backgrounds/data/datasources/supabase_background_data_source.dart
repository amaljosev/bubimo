// lib/features/backgrounds/data/datasources/supabase_background_data_source.dart

import 'package:bubimo/core/services/supabase_storage_asset_service.dart';
import 'package:bubimo/core/storage/media_storage_service.dart';

/// Fetches and caches background presets from Supabase Storage —
/// bucket `assets`, folder `bg_presets`. Thin wrapper around the shared
/// [SupabaseStorageAssetService], scoped to this one folder.
///
/// Fails gracefully (throws, caught by [BackgroundPickerBloc]) when
/// offline, since the app is offline-first and local bundled presets
/// must remain fully usable regardless of network state.
class SupabaseBackgroundDataSource {
  final SupabaseStorageAssetService storageService;

  const SupabaseBackgroundDataSource(this.storageService);

  static const String _folder = 'bg_presets';

  /// Fetches the current list of available remote background image
  /// URLs.
  Future<List<String>> fetchAvailablePackUrls() {
    return storageService.listPublicUrls(_folder);
  }

  /// Downloads and caches a single background image, returning its
  /// durable local path. Skips the download if already cached.
  ///
  /// Uses [MediaCategory.downloadedBackgrounds] — was previously a raw
  /// `'backgrounds_cache'` string subfolder written directly by
  /// `SupabaseStorageAssetService`, bypassing `MediaStorageService`
  /// entirely. See `MediaCategory.downloadedBackgrounds`'s doc comment:
  /// this is the category `DiaryEntry.bgLocalPath` is expected to live
  /// under.
  Future<String> downloadAndCache(String url) {
    return storageService.downloadAndCache(
      url,
      MediaCategory.downloadedBackgrounds,
    );
  }
}