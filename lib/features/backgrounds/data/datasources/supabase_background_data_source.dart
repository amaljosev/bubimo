// lib/features/backgrounds/data/datasources/supabase_background_data_source.dart


import 'package:bubimo/core/services/supabase_storage_asset_service.dart';


/// A single remote background pack entry, as listed in Supabase.
class RemoteBackgroundItem {
  final String id;
  final String imageUrl;

  const RemoteBackgroundItem({required this.id, required this.imageUrl});

  factory RemoteBackgroundItem.fromMap(Map<String, dynamic> map) {
    return RemoteBackgroundItem(
      id: map['id'] as String,
      imageUrl: map['image_url'] as String,
    );
  }
}

/// Fetches the list of additional background packs from Supabase, and
/// downloads/caches individual images locally so they remain available
/// offline once downloaded once — this is the ONLY part of the app that
/// touches the network, and it fails gracefully (throws, caught by the
/// bloc) when offline, since the app is offline-first by design.
///
/// Assumes a Supabase table named `background_packs` with `id` and
/// `image_url` columns — adjust to match your actual schema.
// lib/features/backgrounds/data/datasources/supabase_background_data_source.dart


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
  static const String _cacheSubfolder = 'backgrounds_cache';

  /// Fetches the current list of available remote background image
  /// URLs.
  Future<List<String>> fetchAvailablePackUrls() {
    return storageService.listPublicUrls(_folder);
  }

  /// Downloads and caches a single background image, returning its
  /// local cached path. Skips the download if already cached.
  Future<String> downloadAndCache(String url) {
    return storageService.downloadAndCache(url, _cacheSubfolder);
  }
}