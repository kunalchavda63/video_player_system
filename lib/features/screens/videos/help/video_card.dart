import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'dart:typed_data';
import 'dart:io';
import '../../../../core/models/src/video_model/video_model.dart';

class VideoCard extends StatefulWidget {
  final VideoModel video;
  final VoidCallback onTap;

  const VideoCard({
    super.key,
    required this.video,
    required this.onTap,
  });

  @override
  State<VideoCard> createState() => _VideoCardState();
}

class _VideoCardState extends State<VideoCard> {
  Uint8List? _thumbnailBytes;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _generateThumbnail();
  }
// Add this method in your VideoCard
  Future<void> _generateThumbnailAlternative() async {
    try {
      final tempDir = await getTemporaryDirectory();
      final tempPath = tempDir.path;

      // Generate thumbnail as file
      final String? thumbnailPath = await VideoThumbnail.thumbnailFile(
        video: widget.video.filePath,
        thumbnailPath: tempPath,
        imageFormat: ImageFormat.JPEG,
        maxHeight: 200,
        quality: 70,
        timeMs: 1000,
      );

      if (thumbnailPath != null && mounted) {
        final bytes = await File(thumbnailPath).readAsBytes();
        setState(() {
          _thumbnailBytes = bytes;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Alternative method failed: $e');
      setState(() => _isLoading = false);
    }
  }
  Future<void> _generateThumbnail() async {
    try {
      print('📹 Video Path: ${widget.video.filePath}');

      // Check if file exists
      final file = File(widget.video.filePath);
      if (!await file.exists()) {
        print('❌ File does not exist: ${widget.video.filePath}');
        setState(() {
          _errorMessage = 'File not found';
          _isLoading = false;
        });
        return;
      }

      print('✅ File exists, generating thumbnail...');

      // Method 1: Try thumbnailData (for memory)
      Uint8List? uint8list = await VideoThumbnail.thumbnailData(
        video: widget.video.filePath,
        imageFormat: ImageFormat.JPEG,
        maxWidth: 200,
        quality: 70,
        timeMs: 1000,
      );

      // Method 2: If method 1 fails, try thumbnailFile (for file)
      if (uint8list == null) {
        print('⚠️ thumbnailData returned null, trying thumbnailFile...');

        String? thumbnailPath = await VideoThumbnail.thumbnailFile(
          video: widget.video.filePath,
          thumbnailPath: await widget.video.filePath,
          imageFormat: ImageFormat.JPEG,
          maxWidth: 200,
          quality: 70,
          timeMs: 1000,
        );

        if (thumbnailPath != null) {
          final thumbnailFile = File(thumbnailPath);
          if (await thumbnailFile.exists()) {
            uint8list = await thumbnailFile.readAsBytes();
            print('✅ Thumbnail generated via file method');
          }
        }
      }

      if (uint8list != null && mounted) {
        print('✅ Thumbnail generated successfully! Size: ${uint8list.length} bytes');
        setState(() {
          _thumbnailBytes = uint8list;
          _isLoading = false;
        });
      } else {
        print('❌ Failed to generate thumbnail - both methods returned null');
        setState(() {
          _errorMessage = 'Thumbnail generation failed';
          _isLoading = false;
        });
      }
    } catch (e, stacktrace) {
      print('❌ Error generating thumbnail: $e');
      print('Stacktrace: $stacktrace');
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Video Thumbnail Area
            Expanded(
              flex: 3,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Thumbnail or Placeholder
                    _buildThumbnailContent(),

                    // Play Icon Overlay
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: Center(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.4),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.play_circle_filled_rounded,
                            size: 45,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),

                    // Duration Badge
                    Positioned(
                      bottom: 10,
                      right: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.75),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.timer,
                              size: 12,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              widget.video.formattedDuration,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Error Badge (for debugging)
                    if (_errorMessage != null)
                      Positioned(
                        top: 10,
                        left: 10,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Icon(
                            Icons.error,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // Video Info
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.video.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        color: Colors.black87,
                      ),
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.storage,
                          size: 12,
                          color: Colors.grey.shade500,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          widget.video.formattedSize,
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThumbnailContent() {
    if (_isLoading) {
      return Container(
        color: Colors.grey.shade900,
        child: const Center(
          child: CircularProgressIndicator(
            color: Colors.white,
          ),
        ),
      );
    }

    if (_thumbnailBytes != null) {
      return Image.memory(
        _thumbnailBytes!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          print('Error displaying image: $error');
          return _buildPlaceholder();
        },
      );
    }

    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    return Container(
      color: Colors.grey.shade800,
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.play_circle_filled_rounded,
              size: 50,
              color: Colors.white70,
            ),
            SizedBox(height: 8),
            Text(
              'No Preview',
              style: TextStyle(
                color: Colors.white54,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}