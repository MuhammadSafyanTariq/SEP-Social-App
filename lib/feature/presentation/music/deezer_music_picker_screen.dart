import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:sep/components/styles/appColors.dart';
import 'package:sep/services/music/deezer_api.dart';

class DeezerMusicPickerScreen extends StatefulWidget {
  const DeezerMusicPickerScreen({Key? key}) : super(key: key);

  @override
  State<DeezerMusicPickerScreen> createState() =>
      _DeezerMusicPickerScreenState();
}

class _DeezerMusicPickerScreenState extends State<DeezerMusicPickerScreen> {
  final TextEditingController _searchController = TextEditingController();
  final AudioPlayer _player = AudioPlayer();

  List<DeezerTrack> _results = [];
  bool _loading = false;
  String? _playingId;
  bool _isPlaying = false;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _player.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state == PlayerState.playing;
        });
      }
    });
    _player.onPlayerComplete.listen((_) {
      if (mounted) {
        setState(() {
          _isPlaying = false;
        });
      }
    });
    // Load trending/default results on open
    _loadTrending();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _player.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _search(String query) async {
    if (query.trim().isEmpty) return;
    setState(() => _loading = true);
    final results = await DeezerApi.searchTracks(query);
    if (mounted) {
      setState(() {
        _results = results;
        _loading = false;
      });
    }
  }

  Future<void> _loadTrending() async {
    setState(() => _loading = true);
    final results = await DeezerApi.trendingTracks(limit: 30);
    if (mounted) {
      setState(() {
        _results = results;
        _loading = false;
      });
    }
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    if (value.trim().isEmpty) return;
    _debounce = Timer(const Duration(milliseconds: 600), () => _search(value));
  }

  Future<void> _togglePreview(DeezerTrack track) async {
    if (_playingId == track.previewUrl && _isPlaying) {
      await _player.pause();
      setState(() => _isPlaying = false);
      return;
    }
    if (_playingId == track.previewUrl && !_isPlaying) {
      await _player.resume();
      setState(() {
        _isPlaying = true;
      });
      return;
    }
    setState(() {
      _playingId = track.previewUrl;
      _isPlaying = false;
    });
    await _player.play(UrlSource(track.previewUrl));
  }

  void _selectTrack(DeezerTrack track) {
    _player.stop();
    Navigator.of(context).pop(track);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.black),
          onPressed: () {
            _player.stop();
            Navigator.of(context).pop();
          },
        ),
        title: const Text(
          'Add Music',
          style: TextStyle(
            color: AppColors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(64),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              controller: _searchController,
              autofocus: true,
              style: const TextStyle(color: AppColors.black),
              onChanged: _onSearchChanged,
              onSubmitted: _search,
              decoration: InputDecoration(
                hintText: 'Search songs, artists...',
                hintStyle: TextStyle(color: AppColors.greyHint),
                prefixIcon: const Icon(Icons.search, color: AppColors.grey),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.grey),
                        onPressed: () {
                          _searchController.clear();
                          _loadTrending();
                        },
                      )
                    : null,
                filled: true,
                fillColor: AppColors.colorF5,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.btnColor),
            )
          : _results.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.music_off,
                        size: 64,
                        color: AppColors.grey,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'No tracks found',
                        style: TextStyle(
                          color: AppColors.greyHint,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.info_outline,
                            size: 14,
                            color: AppColors.grey,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '30-second previews via Deezer',
                            style: TextStyle(
                              color: AppColors.greyHint,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: _results.length,
                        itemBuilder: (context, index) {
                          final track = _results[index];
                          final isCurrent = _playingId == track.previewUrl;
                          return _TrackTile(
                            track: track,
                            isCurrent: isCurrent,
                            isPlaying: isCurrent && _isPlaying,
                            onPlayPause: () => _togglePreview(track),
                            onSelect: () => _selectTrack(track),
                          );
                        },
                      ),
                    ),
                  ],
                ),
    );
  }
}

class _TrackTile extends StatelessWidget {
  final DeezerTrack track;
  final bool isCurrent;
  final bool isPlaying;
  final VoidCallback onPlayPause;
  final VoidCallback onSelect;

  const _TrackTile({
    required this.track,
    required this.isCurrent,
    required this.isPlaying,
    required this.onPlayPause,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isCurrent ? AppColors.resultcolor : AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCurrent ? AppColors.btnColor : AppColors.Grey,
          width: 1.5,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: track.coverUrl.isNotEmpty
              ? CachedNetworkImage(
                  imageUrl: track.coverUrl,
                  width: 52,
                  height: 52,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(
                    width: 52,
                    height: 52,
                    color: Colors.grey[800],
                    child: const Icon(
                      Icons.music_note,
                      color: Colors.grey,
                    ),
                  ),
                  errorWidget: (_, __, ___) => Container(
                    width: 52,
                    height: 52,
                    color: Colors.grey[800],
                    child: const Icon(Icons.music_note, color: Colors.grey),
                  ),
                )
              : Container(
                  width: 52,
                  height: 52,
                  color: Colors.grey[800],
                  child: const Icon(Icons.music_note, color: Colors.grey),
                ),
        ),
        title: Text(
          track.title,
          style: TextStyle(
            color: AppColors.blackText,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              track.artist,
              style: const TextStyle(color: AppColors.greyHint, fontSize: 12),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              '30s preview',
              style: const TextStyle(color: AppColors.grey, fontSize: 11),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: onPlayPause,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isCurrent
                      ? AppColors.btnColor.withOpacity(0.15)
                      : AppColors.colorF5,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isPlaying ? Icons.pause : Icons.play_arrow,
                  color: AppColors.black,
                  size: 20,
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onSelect,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.btnColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Use',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
