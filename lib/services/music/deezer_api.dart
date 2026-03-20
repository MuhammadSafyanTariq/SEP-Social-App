import 'dart:convert';
import 'package:http/http.dart' as http;

class DeezerTrack {
  final int id;
  final String title;
  final String artist;
  final String previewUrl;
  final String coverUrl;
  final int durationSeconds;

  const DeezerTrack({
    required this.id,
    required this.title,
    required this.artist,
    required this.previewUrl,
    required this.coverUrl,
    required this.durationSeconds,
  });

  factory DeezerTrack.fromJson(Map<String, dynamic> json) {
    return DeezerTrack(
      id: json['id'] as int,
      title: json['title'] as String? ?? 'Unknown Title',
      artist: (json['artist'] as Map<String, dynamic>?)?['name'] as String? ?? 'Unknown Artist',
      previewUrl: json['preview'] as String? ?? '',
      coverUrl: (json['album'] as Map<String, dynamic>?)?['cover_medium'] as String? ?? '',
      durationSeconds: json['duration'] as int? ?? 30,
    );
  }

  String get formattedDuration {
    final m = durationSeconds ~/ 60;
    final s = durationSeconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }
}

class DeezerApi {
  static const String _baseUrl = 'https://api.deezer.com';

  /// Fetch a Deezer track by id to get a fresh `preview` URL.
  /// Deezer preview URLs are time-limited/signed, so using them later can fail.
  static Future<DeezerTrack?> getTrack(int id) async {
    try {
      final uri = Uri.parse('$_baseUrl/track/$id');
      final response =
          await http.get(uri).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final track = DeezerTrack.fromJson(data);
        return track.previewUrl.isNotEmpty ? track : null;
      }
    } catch (_) {}
    return null;
  }

  /// Return a fresh preview URL for playback.
  static Future<String?> previewUrlForTrackId(int id) async {
    final track = await getTrack(id);
    return track?.previewUrl;
  }

  /// Fetch global trending tracks (used for initial suggestions).
  static Future<List<DeezerTrack>> trendingTracks({int limit = 30}) async {
    try {
      final uri = Uri.parse(
        '$_baseUrl/chart/0/tracks?limit=$limit',
      );
      final response =
          await http.get(uri).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final items = (data['data'] as List?) ?? [];
        return items
            .map((e) => DeezerTrack.fromJson(e as Map<String, dynamic>))
            .where((t) => t.previewUrl.isNotEmpty)
            .toList();
      }
    } catch (_) {}
    return [];
  }

  static Future<List<DeezerTrack>> searchTracks(String query) async {
    if (query.trim().isEmpty) return [];

    try {
      final uri = Uri.parse(
        // Deezer often returns many tracks with empty `preview` URLs.
        // We request a higher limit so that after filtering for preview
        // we still end up with enough tracks for the UI.
        '$_baseUrl/search?q=${Uri.encodeComponent(query)}&limit=50',
      );
      final response = await http.get(uri).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final items = (data['data'] as List?) ?? [];
        return items
            .map((e) => DeezerTrack.fromJson(e as Map<String, dynamic>))
            .where((t) => t.previewUrl.isNotEmpty)
            .toList();
      }
    } catch (_) {}
    return [];
  }
}
