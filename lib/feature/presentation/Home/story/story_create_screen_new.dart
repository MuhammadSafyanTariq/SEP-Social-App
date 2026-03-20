import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sep/components/styles/appColors.dart';
import 'package:sep/services/networking/urls.dart';
import 'package:sep/feature/presentation/controller/createpost/createpost_ctrl.dart';
import 'package:sep/feature/presentation/controller/story/story_controller.dart';
import 'package:sep/services/story_service.dart';
import 'package:sep/utils/appUtils.dart';
import 'package:sep/components/coreComponents/EditText.dart';
import 'package:video_player/video_player.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:sep/components/coreComponents/sep_image_filter.dart';
import 'package:sep/services/music/deezer_api.dart';
import 'package:sep/feature/presentation/music/deezer_music_picker_screen.dart';

enum StoryMediaType { image, video, audio }

class StoryCreateScreenNew extends StatefulWidget {
  const StoryCreateScreenNew({Key? key}) : super(key: key);

  @override
  State<StoryCreateScreenNew> createState() => _StoryCreateScreenNewState();
}

class _StoryCreateScreenNewState extends State<StoryCreateScreenNew> {
  File? _selectedFile;
  DeezerTrack? _selectedDeezerTrack;
  StoryMediaType _mediaType = StoryMediaType.image;
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _captionController = TextEditingController();
  final StoryService _storyService = StoryService();
  bool _isUploading = false;
  VideoPlayerController? _videoController;
  AudioPlayer? _audioPlayer;
  String? _musicFileName;
  bool _isMusicPlaying = false;
  int _selectedFilterIndex = 0;

  @override
  void dispose() {
    _captionController.dispose();
    _videoController?.dispose();
    _audioPlayer?.dispose();
    super.dispose();
  }

  Future<void> _pickMedia(StoryMediaType type, {bool fromCamera = false}) async {
    try {
      if (type == StoryMediaType.image) {
        final XFile? image = await _picker.pickImage(
          source: fromCamera ? ImageSource.camera : ImageSource.gallery,
          maxWidth: 1080,
          maxHeight: 1920,
          imageQuality: 85,
        );

        if (image != null) {
          setState(() {
            _selectedFile = File(image.path);
            _mediaType = StoryMediaType.image;
            _videoController?.dispose();
            _videoController = null;
          });
        }
      } else if (type == StoryMediaType.video) {
        final XFile? video = await _picker.pickVideo(
          source: fromCamera ? ImageSource.camera : ImageSource.gallery,
          maxDuration: Duration(seconds: 60),
        );

        if (video != null) {
          final file = File(video.path);
          setState(() {
            _selectedFile = file;
            _mediaType = StoryMediaType.video;
            // Clear music when selecting video
            _selectedDeezerTrack = null;
            _musicFileName = null;
            _audioPlayer?.stop();
          });

          // Initialize video player
          _videoController?.dispose();
          _videoController = VideoPlayerController.file(file);
          await _videoController!.initialize();
          await _videoController!.setLooping(true);
          await _videoController!.play();
          setState(() {});
        }
      }
    } catch (e) {
      AppUtils.toastError('Error picking media: $e');
    }
  }

  Future<void> _pickMusicForImage() async {
    if (_mediaType != StoryMediaType.image) {
      AppUtils.toastError('Music can only be added to image stories');
      return;
    }

    final track = await Navigator.of(context).push<DeezerTrack>(
      MaterialPageRoute(
        builder: (_) => const DeezerMusicPickerScreen(),
        fullscreenDialog: true,
      ),
    );

    if (track != null) {
      setState(() {
        _selectedDeezerTrack = track;
        _musicFileName = track.title;
        _isMusicPlaying = false;
      });
      // Auto-play the Deezer preview
      _startMusicPlayback();
      AppUtils.toast('Music added: ${track.title}');
    }
  }

  Future<void> _startMusicPlayback() async {
    if (_selectedDeezerTrack == null || _mediaType != StoryMediaType.image) {
      return;
    }

    try {
      _audioPlayer ??= AudioPlayer();
      await _audioPlayer!.setReleaseMode(ReleaseMode.loop);
      await _audioPlayer!.play(UrlSource(_selectedDeezerTrack!.previewUrl));
      setState(() {
        _isMusicPlaying = true;
      });
    } catch (e) {
      AppUtils.toastError('Error playing preview: $e');
    }
  }

  Future<void> _toggleMusicPlayback() async {
    if (_selectedDeezerTrack == null || _mediaType != StoryMediaType.image) {
      return;
    }

    try {
      if (_isMusicPlaying) {
        await _audioPlayer?.pause();
        setState(() => _isMusicPlaying = false);
      } else {
        await _startMusicPlayback();
      }
    } catch (e) {
      AppUtils.toastError('Error playing preview: $e');
    }
  }

  void _removeMusicFile() {
    setState(() {
      _selectedDeezerTrack = null;
      _musicFileName = null;
      _audioPlayer?.stop();
      _audioPlayer?.dispose();
      _audioPlayer = null;
      _isMusicPlaying = false;
    });
    AppUtils.toast('Music removed');
  }

  // _pickAudio placeholder is currently unused.

  Future<void> _createStory() async {
    if (_selectedFile == null) {
      AppUtils.toastError('Please select media');
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      final createPostCtrl = Get.find<CreatePostCtrl>();

      // Upload main file (image or video)
      AppUtils.log('Uploading file: ${_selectedFile!.path}');
      final uploadedFiles = await createPostCtrl.uploadFiles([_selectedFile!]);

      if (uploadedFiles.isEmpty) {
        AppUtils.toastError('Failed to upload file');
        setState(() {
          _isUploading = false;
        });
        return;
      }

      // Get the uploaded file URL
      final fileUrl = uploadedFiles[0]['file'] as String;
      final fullUrl = fileUrl.startsWith('http') ? fileUrl : '$baseUrl$fileUrl';

      AppUtils.log('File uploaded: $fullUrl');

      // Use Deezer preview URL directly (no upload required)
      String? musicUrl;
      if (_mediaType == StoryMediaType.image && _selectedDeezerTrack != null) {
        // Deezer preview URLs are time-limited. Store track id too,
        // and resolve a fresh preview when viewing the story later.
        musicUrl =
            '${_selectedDeezerTrack!.previewUrl}::trackId=${_selectedDeezerTrack!.id}';
        AppUtils.log('Using Deezer preview URL for story: $musicUrl');
      }

      // Extra debug for testing Deezer audio persistence.
      if (_selectedDeezerTrack != null && musicUrl != null) {
        final expMatch = RegExp(r'exp=(\d+)').firstMatch(musicUrl);
        final expUnix = expMatch?.group(1);
        AppUtils.log(
          'DEBUG Story music payload. trackId=${_selectedDeezerTrack!.id} exp=$expUnix musicPrefix="${musicUrl.length > 60 ? musicUrl.substring(0, 60) + "..." : musicUrl}"',
        );
      }

      // Create story based on media type
      String? storyId;
      final caption = _captionController.text.trim();

      if (_mediaType == StoryMediaType.image) {
        final story = await _storyService.createImageStory(
          imageUrl: fullUrl,
          audioUrl: musicUrl, // Pass the audio URL
          caption: caption.isEmpty ? null : caption,
        );
        storyId = story?.id;
      } else if (_mediaType == StoryMediaType.video) {
        final story = await _storyService.createVideoStory(
          videoUrl: fullUrl,
          caption: caption.isEmpty ? null : caption,
        );
        storyId = story?.id;
      }

      if (storyId != null) {
        AppUtils.log('Story created with ID: $storyId');

        // Refresh stories list with a small delay to ensure backend has processed
        try {
          AppUtils.log('⏱️ Waiting 500ms before refreshing stories...');
          await Future.delayed(Duration(milliseconds: 500));

          final storyController = Get.find<StoryController>();
          AppUtils.log('🔄 Refreshing stories after story creation...');
          await storyController.refreshStories();
          AppUtils.log('✅ Stories refreshed successfully');
        } catch (e) {
          AppUtils.log('❌ StoryController not found or refresh failed: $e');
        }

        Navigator.pop(context, true);
      } else {
        AppUtils.toastError('Failed to create story');
      }
    } catch (e) {
      AppUtils.toastError('Error creating story: $e');
      AppUtils.log('Create story error: $e');
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  void _showCameraOptionsDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[700],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Camera Options',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 24),
            _buildMediaTypeOption(
              icon: Icons.photo_camera,
              title: 'Take Photo',
              subtitle: 'Capture a photo with camera',
              onTap: () {
                Navigator.pop(context);
                _pickMedia(StoryMediaType.image, fromCamera: true);
              },
            ),
            SizedBox(height: 12),
            _buildMediaTypeOption(
              icon: Icons.videocam,
              title: 'Record Video',
              subtitle: 'Record a video (max 60s)',
              onTap: () {
                Navigator.pop(context);
                _pickMedia(StoryMediaType.video, fromCamera: true);
              },
            ),
            SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _showMediaTypeDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[700],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Choose Media Type',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 24),
            _buildMediaTypeOption(
              icon: Icons.camera_alt,
              title: 'Camera',
              subtitle: 'Take a photo or record a video',
              onTap: () {
                Navigator.pop(context);
                _showCameraOptionsDialog();
              },
            ),
            SizedBox(height: 12),
            _buildMediaTypeOption(
              icon: Icons.image_outlined,
              title: 'Image Story',
              subtitle: 'Create a story with an image + optional music',
              onTap: () {
                Navigator.pop(context);
                _pickMedia(StoryMediaType.image);
              },
            ),
            SizedBox(height: 12),
            _buildMediaTypeOption(
              icon: Icons.video_library_outlined,
              title: 'Video Story',
              subtitle: 'Create a story with a video (max 60s)',
              onTap: () {
                Navigator.pop(context);
                _pickMedia(StoryMediaType.video);
              },
            ),
            SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaTypeOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[850],
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey[800]!, width: 1),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primaryColor.withOpacity(0.8),
                      AppColors.primaryColor.withOpacity(0.6),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.white, size: 24),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(color: Colors.grey[400], fontSize: 13),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: Colors.grey[600], size: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMediaPreview() {
    if (_selectedFile == null) {
      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black,
              AppColors.primaryColor.withOpacity(0.1),
              Colors.black,
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(24),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primaryColor.withOpacity(0.3),
                      AppColors.primaryColor.withOpacity(0.1),
                    ],
                  ),
                ),
                child: Icon(
                  Icons.add_photo_alternate_outlined,
                  size: 64,
                  color: Colors.white70,
                ),
              ),
              SizedBox(height: 24),
              Text(
                'Create Your Story',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 12),
              Text(
                'Share moments with images or videos',
                style: TextStyle(color: Colors.white60, fontSize: 15),
              ),
              SizedBox(height: 8),
              Text(
                'Add music to image stories',
                style: TextStyle(color: Colors.white54, fontSize: 13),
              ),
              SizedBox(height: 40),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primaryColor,
                      AppColors.primaryColor.withOpacity(0.8),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryColor.withOpacity(0.4),
                      blurRadius: 12,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton.icon(
                  onPressed: _showMediaTypeDialog,
                  icon: Icon(Icons.add_circle_outline, size: 24),
                  label: Text('Select Media', style: TextStyle(fontSize: 16)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    shadowColor: Colors.transparent,
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final settings = EnhancementPresets.byIndex(_selectedFilterIndex);

    if (_mediaType == StoryMediaType.image) {
      return SepImageFilter(
        settings: settings,
        child: Image.file(_selectedFile!, fit: BoxFit.contain),
      );
    } else if (_mediaType == StoryMediaType.video &&
        _videoController != null) {
      return SepImageFilter(
        settings: settings,
        child: Stack(
          alignment: Alignment.center,
          children: [
            AspectRatio(
              aspectRatio: _videoController!.value.aspectRatio,
              child: VideoPlayer(_videoController!),
            ),
            if (!_videoController!.value.isPlaying)
              const Icon(
                Icons.play_circle_outline,
                size: 80,
                color: Colors.white70,
              ),
          ],
        ),
      );
    }

    return SizedBox();
  }

  // _getMediaTypeLabel helper is currently unused.

  Widget _buildModernActionButton({
    required IconData icon,
    required VoidCallback onPressed,
    required String heroTag,
    required Color backgroundColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: backgroundColor.withOpacity(0.4),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: FloatingActionButton(
        mini: true,
        backgroundColor: backgroundColor,
        heroTag: heroTag,
        elevation: 0,
        onPressed: onPressed,
        child: Icon(icon, color: Colors.white, size: 22),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Create Story', style: TextStyle(color: Colors.white)),
        actions: [
          if (_selectedFile != null)
            TextButton(
              onPressed: _isUploading ? null : _createStory,
              child: _isUploading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      'Share',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
        ],
      ),
      body: _selectedFile == null
          ? _buildMediaPreview()
          : Column(
              children: [
                Expanded(
                  child: Stack(
                    children: [
                      Center(child: _buildMediaPreview()),
                      // Change media button
                      Positioned(
                        top: 20,
                        right: 20,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 8,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              // Add music button for images only
                              if (_mediaType == StoryMediaType.image)
                                Padding(
                                  padding: const EdgeInsets.only(top: 12.0),
                                  child: _buildModernActionButton(
                                    icon: _selectedDeezerTrack != null
                                        ? Icons.library_music
                                        : Icons.library_music_outlined,
                                    onPressed: _pickMusicForImage,
                                    heroTag: 'music',
                                    backgroundColor: _selectedDeezerTrack != null
                                        ? AppColors.primaryColor.withOpacity(
                                            0.9,
                                          )
                                        : Colors.black.withOpacity(0.6),
                                  ),
                                ),
                              // Play/pause for music (images) or video
                              if (_mediaType == StoryMediaType.video)
                                Padding(
                                  padding: const EdgeInsets.only(top: 12.0),
                                  child: _buildModernActionButton(
                                    icon:
                                        _videoController?.value.isPlaying ??
                                            false
                                        ? Icons.pause
                                        : Icons.play_arrow,
                                    onPressed: () {
                                      setState(() {
                                        if (_videoController!.value.isPlaying) {
                                          _videoController!.pause();
                                        } else {
                                          _videoController!.play();
                                        }
                                      });
                                    },
                                    heroTag: 'play',
                                    backgroundColor: Colors.black.withOpacity(
                                      0.6,
                                    ),
                                  ),
                                ),
                              if (_mediaType == StoryMediaType.image &&
                                  _selectedDeezerTrack != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 12.0),
                                  child: _buildModernActionButton(
                                    icon: _isMusicPlaying
                                        ? Icons.pause
                                        : Icons.play_arrow,
                                    onPressed: _toggleMusicPlayback,
                                    heroTag: 'play_music',
                                    backgroundColor: Colors.black.withOpacity(
                                      0.6,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      // Music indicator for images
                      if (_mediaType == StoryMediaType.image &&
                          _selectedDeezerTrack != null)
                        Positioned(
                          bottom: 20,
                          left: 20,
                          right: 20,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.primaryColor.withOpacity(0.95),
                                  AppColors.primaryColor.withOpacity(0.85),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 8,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    _isMusicPlaying
                                        ? Icons.music_note
                                        : Icons.music_note_outlined,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        _isMusicPlaying
                                            ? 'Playing'
                                            : 'Audio Added',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      SizedBox(height: 2),
                                      Text(
                                        _musicFileName ?? 'Music',
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.9),
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(width: 8),
                                Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(20),
                                    onTap: _removeMusicFile,
                                    child: Container(
                                      padding: EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.2),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.close,
                                        color: Colors.white,
                                        size: 18,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                _buildStoryFilterRow(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 8,
                        offset: Offset(0, -2),
                      ),
                    ],
                  ),
                  child: EditText(
                    controller: _captionController,
                    hint: '✨ Add a caption... (optional)',
                    textStyle:
                        const TextStyle(color: Colors.white, fontSize: 15),
                    hintStyle:
                        const TextStyle(color: Colors.white54, fontSize: 15),
                    isFilled: true,
                    filledColor: Colors.grey,
                    borderColor: Colors.transparent,
                    radius: 16,
                    maxLength: 100,
                    noOfLines: 1,
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildStoryFilterRow() {
    final names = EnhancementPresets.names;
    return Container(
      height: 70,
      color: Colors.black,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        scrollDirection: Axis.horizontal,
        itemCount: names.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final selected = index == _selectedFilterIndex;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedFilterIndex = index;
              });
            },
            child: Container(
              width: 80,
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.btnColor.withOpacity(0.15)
                    : Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: selected ? AppColors.btnColor : Colors.white24,
                  width: selected ? 2 : 1,
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        color: Colors.black,
                        child: EnhancementPresets.assetForIndex(index) != null
                            ? Image.asset(
                                EnhancementPresets.assetForIndex(index)!,
                                fit: BoxFit.cover,
                              )
                            : const Icon(
                                Icons.filter_alt,
                                size: 20,
                                color: Colors.white70,
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    names[index],
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
