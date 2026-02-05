# Backend Changes for Video Quality Support

## Overview
To ensure videos play on all mobile devices, you need to:
1. Transcode videos to multiple qualities when uploaded
2. Store multiple quality URLs
3. Modify API response to include quality options
4. Add endpoint to get appropriate quality based on device

---

## 1. Backend Video Processing (Node.js/Express Example)

### Step 1: Install Video Processing Library
```bash
npm install fluent-ffmpeg
# or
npm install @ffmpeg-installer/ffmpeg
```

### Step 2: Create Video Transcoding Service

```javascript
// services/videoTranscodingService.js
const ffmpeg = require('fluent-ffmpeg');
const path = require('path');
const fs = require('fs').promises;

class VideoTranscodingService {
  /**
   * Transcode video to multiple qualities
   * @param {string} inputPath - Path to original video file
   * @param {string} outputDir - Directory to save transcoded videos
   * @param {string} videoId - Unique video identifier
   * @returns {Promise<Object>} Object with quality URLs
   */
  async transcodeVideo(inputPath, outputDir, videoId) {
    const qualities = [
      { name: '1080p', width: 1920, height: 1080, bitrate: '5000k' },
      { name: '720p', width: 1280, height: 720, bitrate: '2500k' },
      { name: '480p', width: 854, height: 480, bitrate: '1000k' },
      { name: '360p', width: 640, height: 360, bitrate: '500k' },
    ];

    const transcodedFiles = {};
    
    // Ensure output directory exists
    await fs.mkdir(outputDir, { recursive: true });

    for (const quality of qualities) {
      const outputPath = path.join(
        outputDir,
        `${videoId}_${quality.name}.mp4`
      );

      try {
        await this.transcodeToQuality(
          inputPath,
          outputPath,
          quality
        );
        
        // Upload to storage (S3, Cloudinary, etc.)
        const url = await this.uploadToStorage(outputPath, `${videoId}_${quality.name}.mp4`);
        transcodedFiles[quality.name] = url;
        
        // Clean up local file
        await fs.unlink(outputPath);
      } catch (error) {
        console.error(`Error transcoding to ${quality.name}:`, error);
        // Continue with other qualities even if one fails
      }
    }

    return transcodedFiles;
  }

  /**
   * Transcode video to specific quality
   */
  transcodeToQuality(inputPath, outputPath, quality) {
    return new Promise((resolve, reject) => {
      ffmpeg(inputPath)
        .videoCodec('libx264')
        .audioCodec('aac')
        .size(`${quality.width}x${quality.height}`)
        .videoBitrate(quality.bitrate)
        .outputOptions([
          '-preset fast',
          '-crf 23',
          '-movflags +faststart', // Optimize for streaming
        ])
        .on('end', () => resolve())
        .on('error', (err) => reject(err))
        .save(outputPath);
    });
  }

  /**
   * Upload transcoded video to storage
   */
  async uploadToStorage(filePath, fileName) {
    // Implement your storage upload logic here
    // Examples: AWS S3, Cloudinary, Google Cloud Storage, etc.
    // Return the public URL
    return `https://your-cdn.com/videos/${fileName}`;
  }
}

module.exports = new VideoTranscodingService();
```

---

## 2. Update Database Schema

### MongoDB Schema Update

```javascript
// models/Post.js or models/File.js

const fileSchema = {
  file: String,           // Original/primary video URL (1080p or highest quality)
  type: String,          // "video" or "image"
  thumbnail: String,      // Video thumbnail URL
  
  // NEW: Add quality variants for videos
  qualities: {
    '1080p': String,     // URL for 1080p version
    '720p': String,      // URL for 720p version
    '480p': String,      // URL for 480p version
    '360p': String,      // URL for 360p version
  },
  
  // Original video metadata
  originalWidth: Number,
  originalHeight: Number,
  duration: Number,
  fileSize: Number,
  
  // Keep existing fields
  x: Number,
  y: Number,
  _id: String,
};
```

---

## 3. Update Video Upload Endpoint

```javascript
// routes/post.js or routes/upload.js

const express = require('express');
const multer = require('multer');
const videoTranscodingService = require('../services/videoTranscodingService');
const upload = multer({ dest: 'uploads/temp/' });

router.post('/upload-video', upload.single('video'), async (req, res) => {
  try {
    const videoFile = req.file;
    const videoId = generateUniqueId(); // Your ID generation logic
    
    // Step 1: Upload original video to storage
    const originalUrl = await uploadToStorage(videoFile.path, `${videoId}_original.mp4`);
    
    // Step 2: Transcode to multiple qualities
    const transcodedQualities = await videoTranscodingService.transcodeVideo(
      videoFile.path,
      'uploads/transcoded/',
      videoId
    );
    
    // Step 3: Generate thumbnail
    const thumbnailUrl = await generateThumbnail(videoFile.path, videoId);
    
    // Step 4: Get video metadata
    const metadata = await getVideoMetadata(videoFile.path);
    
    // Step 5: Save to database
    const fileData = {
      file: originalUrl, // Keep original as primary
      type: 'video',
      thumbnail: thumbnailUrl,
      qualities: transcodedQualities, // NEW: Multiple quality URLs
      originalWidth: metadata.width,
      originalHeight: metadata.height,
      duration: metadata.duration,
      fileSize: metadata.size,
      x: metadata.width,
      y: metadata.height,
    };
    
    // Clean up temp file
    await fs.unlink(videoFile.path);
    
    res.json({
      success: true,
      data: fileData,
    });
  } catch (error) {
    console.error('Video upload error:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to process video',
    });
  }
});
```

---

## 4. Add API Endpoint to Get Optimal Video Quality

```javascript
// routes/video.js

/**
 * GET /api/video/optimal-quality
 * Returns the best quality URL for the device
 * 
 * Query params:
 * - videoId: Video file ID
 * - maxWidth: Device max supported width (optional, defaults to 1920)
 * - maxHeight: Device max supported height (optional)
 */
router.get('/optimal-quality', async (req, res) => {
  try {
    const { videoId, maxWidth = 1920, maxHeight } = req.query;
    
    // Get video file from database
    const videoFile = await File.findById(videoId);
    
    if (!videoFile || videoFile.type !== 'video') {
      return res.status(404).json({ error: 'Video not found' });
    }
    
    // Determine best quality based on device capabilities
    let selectedQuality = '1080p';
    
    if (maxWidth < 854) {
      selectedQuality = '360p';
    } else if (maxWidth < 1280) {
      selectedQuality = '480p';
    } else if (maxWidth < 1920) {
      selectedQuality = '720p';
    } else {
      selectedQuality = '1080p';
    }
    
    // Get URL for selected quality, fallback to next lower quality if not available
    let videoUrl = videoFile.qualities?.[selectedQuality];
    
    if (!videoUrl) {
      // Fallback logic: try lower qualities
      const qualityOrder = ['1080p', '720p', '480p', '360p'];
      const currentIndex = qualityOrder.indexOf(selectedQuality);
      
      for (let i = currentIndex + 1; i < qualityOrder.length; i++) {
        if (videoFile.qualities?.[qualityOrder[i]]) {
          videoUrl = videoFile.qualities[qualityOrder[i]];
          break;
        }
      }
      
      // Final fallback to original
      if (!videoUrl) {
        videoUrl = videoFile.file;
      }
    }
    
    res.json({
      success: true,
      data: {
        url: videoUrl,
        quality: selectedQuality,
        width: getQualityWidth(selectedQuality),
        height: getQualityHeight(selectedQuality),
      },
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

function getQualityWidth(quality) {
  const widths = { '360p': 640, '480p': 854, '720p': 1280, '1080p': 1920 };
  return widths[quality] || 1920;
}

function getQualityHeight(quality) {
  const heights = { '360p': 360, '480p': 480, '720p': 720, '1080p': 1080 };
  return heights[quality] || 1080;
}
```

---

## 5. Update Post Creation Response

When creating/retrieving posts, include quality information:

```javascript
// When returning post data
const postResponse = {
  _id: post._id,
  content: post.content,
  files: post.files.map(file => ({
    file: file.file,           // Original/highest quality
    type: file.type,
    thumbnail: file.thumbnail,
    
    // Include quality variants for videos
    ...(file.type === 'video' && file.qualities ? {
      qualities: file.qualities,
      availableQualities: Object.keys(file.qualities),
    } : {}),
    
    x: file.x,
    y: file.y,
    _id: file._id,
  })),
  // ... other fields
};
```

---

## 6. Alternative: HLS Adaptive Streaming (Best Practice)

For even better performance, use HLS (HTTP Live Streaming):

```javascript
// Generate HLS playlist with multiple quality segments
async function generateHLS(inputPath, outputDir, videoId) {
  const qualities = [
    { name: '1080p', resolution: '1920x1080', bitrate: '5000k' },
    { name: '720p', resolution: '1280x720', bitrate: '2500k' },
    { name: '480p', resolution: '854x480', bitrate: '1000k' },
  ];
  
  // Generate segments for each quality
  for (const quality of qualities) {
    await ffmpeg(inputPath)
      .outputOptions([
        '-c:v libx264',
        '-c:a aac',
        '-b:v ' + quality.bitrate,
        '-s ' + quality.resolution,
        '-hls_time 10',
        '-hls_playlist_type vod',
        '-hls_segment_filename', `${outputDir}/${videoId}_${quality.name}_%03d.ts`,
      ])
      .output(`${outputDir}/${videoId}_${quality.name}.m3u8`)
      .run();
  }
  
  // Create master playlist
  const masterPlaylist = `
#EXTM3U
#EXT-X-VERSION:3
#EXT-X-STREAM-INF:BANDWIDTH=5000000,RESOLUTION=1920x1080
${videoId}_1080p.m3u8
#EXT-X-STREAM-INF:BANDWIDTH=2500000,RESOLUTION=1280x720
${videoId}_720p.m3u8
#EXT-X-STREAM-INF:BANDWIDTH=1000000,RESOLUTION=854x480
${videoId}_480p.m3u8
  `;
  
  await fs.writeFile(
    `${outputDir}/${videoId}_master.m3u8`,
    masterPlaylist
  );
  
  return `${outputDir}/${videoId}_master.m3u8`;
}
```

---

## 7. Frontend Changes Required

### Update FileElement Model

```dart
// lib/feature/data/models/dataModels/post_data.dart

@freezed
class FileElement with _$FileElement {
  const factory FileElement({
    @JsonKey(name: "file") String? file,
    @JsonKey(name: "type") String? type,
    @JsonKey(name: "_id") String? id,
    @JsonKey(name: "thumbnail") String? thumbnail,
    @JsonKey(name: "x") double? x,
    @JsonKey(name: "y") double? y,
    // NEW: Add quality variants
    @JsonKey(name: "qualities") Map<String, String>? qualities,
    @JsonKey(name: "availableQualities") List<String>? availableQualities,
  }) = _FileElement;

  factory FileElement.fromJson(Map<String, dynamic> json) =>
      _$FileElementFromJson(json);
}
```

### Update Video Player to Use Optimal Quality

```dart
// lib/feature/presentation/Home/homeScreenComponents/auto_play_video_player.dart

String _getOptimalVideoUrl(FileElement fileElement) {
  // Check if HLS master playlist is available
  if (fileElement.file?.endsWith('.m3u8') == true) {
    return fileElement.file!; // HLS handles quality automatically
  }
  
  // Check if multiple qualities are available
  if (fileElement.qualities != null && fileElement.qualities!.isNotEmpty) {
    final maxResolution = _getMaxSupportedResolution();
    
    // Select appropriate quality
    if (maxResolution >= 1920 && fileElement.qualities!.containsKey('1080p')) {
      return fileElement.qualities!['1080p']!;
    } else if (maxResolution >= 1280 && fileElement.qualities!.containsKey('720p')) {
      return fileElement.qualities!['720p']!;
    } else if (maxResolution >= 854 && fileElement.qualities!.containsKey('480p')) {
      return fileElement.qualities!['480p']!;
    } else if (fileElement.qualities!.containsKey('360p')) {
      return fileElement.qualities!['360p']!;
    }
  }
  
  // Fallback to original file
  return fileElement.file ?? '';
}
```

---

## Summary

### Backend Changes:
1. ✅ Install FFmpeg for video transcoding
2. ✅ Create transcoding service to generate multiple qualities
3. ✅ Update database schema to store quality URLs
4. ✅ Modify upload endpoint to transcode videos
5. ✅ Add API endpoint to get optimal quality
6. ✅ Update post response to include quality information

### Frontend Changes:
1. ✅ Update FileElement model to include qualities
2. ✅ Update video player to select optimal quality
3. ✅ Handle HLS playlists automatically

### Result:
- Videos will automatically play at appropriate quality for each device
- No more freezing or format errors
- Better user experience
- Reduced bandwidth usage on low-end devices
