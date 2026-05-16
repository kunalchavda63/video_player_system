import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:volume_controller/volume_controller.dart';
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

class _VideoPlayerScreenState extends State<VideoPlayerScreen>
    with SingleTickerProviderStateMixin {
  late VideoPlayerController _controller;
  late int currentIndex;
  bool _isPlaying = true;
  bool _isLoading = true;
  bool _isLocked = false;
  double _playbackSpeed = 1.0;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;

  // UI state
  bool _showControls = true;
  Timer? _controlsTimer;

  // Volume & Brightness
  double _currentVolume = 1.0;
  double _currentBrightness = 0.5;
  bool _isAdjustingVolume = false;
  bool _isAdjustingBrightness = false;
  Offset? _dragStartPosition;
  double _startVolume = 1.0;
  double _startBrightness = 0.5;

  // Fullscreen
  bool _isFullscreen = false;

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialIndex;
    _loadInitialBrightness();
    // Get current system volume and brightness
    VolumeController().getVolume().then((vol) {
      if (mounted) setState(() => _currentVolume = vol);
    });


    _initializeVideo(widget.video);
    _startControlsTimer();
  }

  Future<void> _loadInitialBrightness() async {
    try {
      final brightness = await ScreenBrightness().current;
      if (mounted) {
        setState(() => _currentBrightness = brightness);
      }
    } catch (e) {
      debugPrint('Error getting brightness: $e');
      // Fallback brightness value (e.g., 0.5) set kar sakte hain
      if (mounted) {
        setState(() => _currentBrightness = 0.5);
      }
    }
  }

  void _startControlsTimer() {
    _controlsTimer?.cancel();
    _controlsTimer = Timer(const Duration(seconds: 3), () {
      if (mounted && _showControls && _isPlaying) {
        setState(() => _showControls = false);
      }
    });
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
      if (_showControls) _startControlsTimer();
    });
  }

  Future<void> _initializeVideo(VideoModel video) async {
    setState(() => _isLoading = true);

    _controller = VideoPlayerController.file(File(video.filePath));
    await _controller.initialize();
    _totalDuration = _controller.value.duration;
    _currentPosition = Duration.zero;

    await _controller.setLooping(false);
    await _controller.setPlaybackSpeed(_playbackSpeed);

    if (_isPlaying) {
      await _controller.play();
    }

    _controller.addListener(_updatePosition);

    setState(() => _isLoading = false);
  }

  void _updatePosition() {
    if (!mounted) return;
    if (_controller.value.position != _currentPosition) {
      setState(() {
        _currentPosition = _controller.value.position;
      });
    }
  }

  void _playPause() {
    setState(() {
      if (_controller.value.isPlaying) {
        _controller.pause();
        _isPlaying = false;
        _showControls = true;
        _controlsTimer?.cancel();
      } else {
        _controller.play();
        _isPlaying = true;
        _startControlsTimer();
      }
    });
  }

  void _seekTo(Duration position) {
    _controller.seekTo(position);
    _showControls = true;
    _startControlsTimer();
  }

  void _seekForward() {
    final newPosition = _currentPosition + const Duration(seconds: 10);
    if (newPosition < _totalDuration) {
      _seekTo(newPosition);
    } else {
      _seekTo(_totalDuration);
    }
  }

  void _seekBackward() {
    final newPosition = _currentPosition - const Duration(seconds: 10);
    if (newPosition > Duration.zero) {
      _seekTo(newPosition);
    } else {
      _seekTo(Duration.zero);
    }
  }

  void _changePlaybackSpeed(double speed) {
    setState(() {
      _playbackSpeed = speed;
      _controller.setPlaybackSpeed(speed);
      _showControls = true;
      _startControlsTimer();
    });
  }

  void _toggleLock() {
    setState(() {
      _isLocked = !_isLocked;
      _showControls = true;
      _startControlsTimer();
    });
  }

  void _playNextVideo() {
    if (currentIndex + 1 < widget.allVideos.length) {
      setState(() {
        currentIndex++;
        _controller.removeListener(_updatePosition);
        _controller.dispose();
        _initializeVideo(widget.allVideos[currentIndex]);
      });
    } else {
      _showSnackBar('No more videos');
    }
  }

  void _playPreviousVideo() {
    if (currentIndex - 1 >= 0) {
      setState(() {
        currentIndex--;
        _controller.removeListener(_updatePosition);
        _controller.dispose();
        _initializeVideo(widget.allVideos[currentIndex]);
      });
    } else {
      _showSnackBar('This is the first video');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 1)),
    );
  }

  // Handle vertical drag for volume (right side) and brightness (left side)
  void _handleVerticalDragStart(DragStartDetails details, bool isRightSide) {
    if (_isLocked) return;
    _dragStartPosition = details.localPosition;
    if (isRightSide) {
      _isAdjustingVolume = true;
      _startVolume = _currentVolume;
    } else {
      _isAdjustingBrightness = true;
      _startBrightness = _currentBrightness;
    }
  }

  void _handleVerticalDragUpdate(DragUpdateDetails details, bool isRightSide) {
    if (_isLocked) return;
    const double sensitivity = 0.005; // Adjust sensitivity
    final delta = details.delta.dy * sensitivity;

    if (isRightSide) {
      double newVolume = (_startVolume - delta).clamp(0.0, 1.0);
      if (newVolume != _currentVolume) {
        setState(() => _currentVolume = newVolume);
        VolumeController().setVolume(newVolume);
      }
    } else {
      double newBrightness = (_startBrightness - delta).clamp(0.0, 1.0);
      if (newBrightness != _currentBrightness) {
        setState(() => _currentBrightness = newBrightness);
        ScreenBrightness().setScreenBrightness(newBrightness);
      }
    }
    _showControls = true;
    _startControlsTimer();
  }

  void _handleVerticalDragEnd(DragEndDetails details) {
    _isAdjustingVolume = false;
    _isAdjustingBrightness = false;
    _dragStartPosition = null;
  }

  // Double tap seek
  void _handleDoubleTap(TapDownDetails details, BoxConstraints constraints) {
    if (_isLocked) return;
    final double tapX = details.localPosition.dx;
    final double screenWidth = constraints.maxWidth;
    if (tapX < screenWidth / 2) {
      _seekBackward();
      _showSeekFeedback(-10);
    } else {
      _seekForward();
      _showSeekFeedback(10);
    }
  }

  void _showSeekFeedback(int seconds) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${seconds > 0 ? "+" : ""}$seconds sec', textAlign: TextAlign.center),
        duration: const Duration(milliseconds: 500),
        backgroundColor: Colors.black87,
      ),
    );
  }

  void _enterFullscreen() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    setState(() => _isFullscreen = true);
  }

  void _exitFullscreen() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    setState(() => _isFullscreen = false);
  }

  void _toggleFullscreen() {
    if (MediaQuery.of(context).orientation == Orientation.portrait) {
      _enterFullscreen();
    } else {
      _exitFullscreen();
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_updatePosition);
    _controller.dispose();
    _controlsTimer?.cancel();
    _exitFullscreen();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return duration.inHours > 0 ? '$hours:$minutes:$seconds' : '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final orientation = MediaQuery.of(context).orientation;
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.black,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return GestureDetector(
            onTap: _toggleControls,
            onDoubleTapDown: (details) => _handleDoubleTap(details, constraints),
            child: Stack(
              children: [
                // Video Player
                Center(
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : AspectRatio(
                    aspectRatio: _controller.value.isInitialized
                        ? _controller.value.aspectRatio
                        : 16 / 9,
                    child: VideoPlayer(_controller),
                  ),
                ),

                // Gesture detection areas for volume/brightness
                if (!_isLocked)
                  Row(
                    children: [
                      // Left half for brightness
                      Expanded(
                        child: GestureDetector(
                          onVerticalDragStart: (details) => _handleVerticalDragStart(details, false),
                          onVerticalDragUpdate: (details) => _handleVerticalDragUpdate(details, false),
                          onVerticalDragEnd: _handleVerticalDragEnd,
                          behavior: HitTestBehavior.translucent,
                        ),
                      ),
                      // Right half for volume
                      Expanded(
                        child: GestureDetector(
                          onVerticalDragStart: (details) => _handleVerticalDragStart(details, true),
                          onVerticalDragUpdate: (details) => _handleVerticalDragUpdate(details, true),
                          onVerticalDragEnd: _handleVerticalDragEnd,
                          behavior: HitTestBehavior.translucent,
                        ),
                      ),
                    ],
                  ),

                // Top Bar
                AnimatedOpacity(
                  opacity: _showControls ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  child: Container(
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.black.withOpacity(0.7), Colors.transparent],
                      ),
                    ),
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_back, color: Colors.white),
                              onPressed: () => Navigator.pop(context),
                            ),
                            Expanded(
                              child: Text(
                                widget.allVideos[currentIndex].title,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                            ),
                            IconButton(
                              icon: Icon(_isLocked ? Icons.lock : Icons.lock_open, color: Colors.white),
                              onPressed: _toggleLock,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // Center Play/Pause when paused
                if (!_isPlaying && !_isLoading && _showControls)
                  Center(
                    child: GestureDetector(
                      onTap: _playPause,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.play_arrow, size: 80, color: Colors.white),
                      ),
                    ),
                  ),

                // Volume Overlay
                if (_isAdjustingVolume && _showControls)
                  _buildVolumeOverlay(),

                // Brightness Overlay
                if (_isAdjustingBrightness && _showControls)
                  _buildBrightnessOverlay(),

                // Bottom Controls
                AnimatedOpacity(
                  opacity: _showControls ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      padding: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [Colors.black.withOpacity(0.7), Colors.transparent],
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_controller.value.isInitialized) ...[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(_formatDuration(_currentPosition), style: const TextStyle(color: Colors.white, fontSize: 12)),
                                Text(_formatDuration(_totalDuration), style: const TextStyle(color: Colors.white, fontSize: 12)),
                              ],
                            ),
                            // Custom seek slider with better touch
                            SliderTheme(
                              data: SliderThemeData(
                                trackHeight: 3,
                                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                                activeTrackColor: Colors.deepPurple,
                                inactiveTrackColor: Colors.grey[800],
                                thumbColor: Colors.deepPurple,
                              ),
                              child: Slider(
                                value: _currentPosition.inSeconds.toDouble(),
                                max: _totalDuration.inSeconds.toDouble(),
                                onChanged: (value) {
                                  _seekTo(Duration(seconds: value.toInt()));
                                },
                              ),
                            ),
                            const SizedBox(height: 12),
                          ],

                          // Control buttons row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              // Speed button
                              PopupMenuButton<double>(
                                onSelected: _changePlaybackSpeed,
                                color: Colors.grey[900],
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[800],
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text('${_playbackSpeed}x', style: const TextStyle(color: Colors.white)),
                                ),
                                itemBuilder: (context) => const [
                                  PopupMenuItem(value: 0.5, child: Text('0.5x', style: TextStyle(color: Colors.white))),
                                  PopupMenuItem(value: 1.0, child: Text('1.0x', style: TextStyle(color: Colors.white))),
                                  PopupMenuItem(value: 1.5, child: Text('1.5x', style: TextStyle(color: Colors.white))),
                                  PopupMenuItem(value: 2.0, child: Text('2.0x', style: TextStyle(color: Colors.white))),
                                ],
                              ),

                              IconButton(
                                icon: const Icon(Icons.skip_previous, size: 36, color: Colors.white),
                                onPressed: _playPreviousVideo,
                              ),

                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: IconButton(
                                  icon: Icon(
                                    _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
                                    size: 48,
                                    color: Colors.white,
                                  ),
                                  onPressed: _playPause,
                                ),
                              ),

                              IconButton(
                                icon: const Icon(Icons.skip_next, size: 36, color: Colors.white),
                                onPressed: _playNextVideo,
                              ),

                              IconButton(
                                icon: Icon(
                                  orientation == Orientation.portrait ? Icons.fullscreen : Icons.fullscreen_exit,
                                  color: Colors.white,
                                ),
                                onPressed: _toggleFullscreen,
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          if (_showControls && !_isLocked)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.black54,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.touch_app, size: 14, color: Colors.white70),
                                      SizedBox(width: 4),
                                      Text(
                                        'Left: Brightness | Right: Volume | Double-tap: ±10s',
                                        style: TextStyle(color: Colors.white70, fontSize: 10),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Lock overlay
                if (_isLocked && _showControls)
                  const Center(
                    child: Icon(Icons.lock, size: 48, color: Colors.white60),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildVolumeOverlay() {
    return Positioned(
      right: 30,
      top: MediaQuery.of(context).size.height / 2 - 80,
      child: Container(
        width: 60,
        height: 160,
        decoration: BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.volume_up, color: Colors.white, size: 24),
            const SizedBox(height: 10),
            Expanded(
              child: RotatedBox(
                quarterTurns: 3,
                child: SliderTheme(
                  data: SliderThemeData(
                    trackHeight: 3,
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                    activeTrackColor: Colors.deepPurple,
                    inactiveTrackColor: Colors.grey,
                  ),
                  child: Slider(
                    value: _currentVolume,
                    onChanged: (value) {
                      setState(() => _currentVolume = value);
                      VolumeController().setVolume(value);
                    },
                    min: 0,
                    max: 1,
                  ),
                ),
              ),
            ),
            Text('${(_currentVolume * 100).toInt()}%', style: const TextStyle(color: Colors.white, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildBrightnessOverlay() {
    return Positioned(
      left: 30,
      top: MediaQuery.of(context).size.height / 2 - 80,
      child: Container(
        width: 60,
        height: 160,
        decoration: BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.brightness_6, color: Colors.white, size: 24),
            const SizedBox(height: 10),
            Expanded(
              child: RotatedBox(
                quarterTurns: 3,
                child: SliderTheme(
                  data: SliderThemeData(
                    trackHeight: 3,
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                    activeTrackColor: Colors.yellow,
                    inactiveTrackColor: Colors.grey,
                  ),
                  child: Slider(
                    value: _currentBrightness,
                    onChanged: (value) {
                      setState(() => _currentBrightness = value);
                      ScreenBrightness().setScreenBrightness(value);
                    },
                    min: 0,
                    max: 1,
                  ),
                ),
              ),
            ),
            Text('${(_currentBrightness * 100).toInt()}%', style: const TextStyle(color: Colors.white, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}