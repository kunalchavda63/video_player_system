import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../../../core/models/src/video_model/video_model.dart';

class VideoPlayerScreen extends StatefulWidget {
  final VideoModel video;
  final List<VideoModel> allVideos;
  final int initialIndex;

  const VideoPlayerScreen({
    super.key,
    required this.video,
    required this.allVideos,
    required this.initialIndex,
  });

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _controller;
  late int currentIndex;
  // bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialIndex;
    _initializeVideo(widget.video);
  }

  Future<void> _initializeVideo(VideoModel video) async {
    _controller = VideoPlayerController.file(File(video.filePath));
    await _controller.initialize();
    await _controller.setLooping(false);
    setState(() {});
  }

  void _playNextVideo() {
    if (currentIndex + 1 < widget.allVideos.length) {
      setState(() {
        currentIndex++;
        _initializeVideo(widget.allVideos[currentIndex]);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No more videos')),
      );
    }
  }

  void _playPreviousVideo() {
    if (currentIndex - 1 >= 0) {
      setState(() {
        currentIndex--;
        _initializeVideo(widget.allVideos[currentIndex]);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('This is the first video')),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.allVideos[currentIndex].title,
          overflow: TextOverflow.ellipsis,
        ),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Container(
        color: Colors.black,
        child: Column(
          children: [
            Expanded(
              child: _controller.value.isInitialized
                  ? AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              )
                  : const Center(child: CircularProgressIndicator()),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.black87,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: const Icon(Icons.skip_previous, size: 40),
                    color: Colors.white,
                    onPressed: _playPreviousVideo,
                  ),
                  IconButton(
                    icon: Icon(
                      _controller.value.isPlaying
                          ? Icons.pause_circle_filled
                          : Icons.play_circle_filled,
                      size: 60,
                    ),
                    color: Colors.white,
                    onPressed: () {
                      setState(() {
                        if (_controller.value.isPlaying) {
                          _controller.pause();
                        } else {
                          _controller.play();
                        }
                      });
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.skip_next, size: 40),
                    color: Colors.white,
                    onPressed: _playNextVideo,
                  ),
                ],
              ),
            ),
            if (_controller.value.isInitialized)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: VideoProgressIndicator(
                  _controller,
                  allowScrubbing: true,
                  colors: VideoProgressColors(
                    playedColor: Colors.deepPurple,
                    bufferedColor: Colors.grey,
                    backgroundColor: Colors.grey[800]!,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}