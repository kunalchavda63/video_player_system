import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:volume_controller/volume_controller.dart';
import '../../../../core/models/src/video_model/video_model.dart';

// --- Riverpod Setup ---

// Arguments pass karne ke liye class
class VideoPlayerArgs {
  final List<VideoModel> allVideos;
  final int initialIndex;

  VideoPlayerArgs({required this.allVideos, required this.initialIndex});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is VideoPlayerArgs &&
              runtimeType == other.runtimeType &&
              allVideos == other.allVideos &&
              initialIndex == other.initialIndex;

  @override
  int get hashCode => allVideos.hashCode ^ initialIndex.hashCode;
}

enum PanType { none, volume, brightness, seek }

// Riverpod Provider with AutoDispose
final videoPlayerProvider = ChangeNotifierProvider.autoDispose.family<VideoPlayerNotifier, VideoPlayerArgs>((ref, args) {
  return VideoPlayerNotifier()..init(args.allVideos, args.initialIndex);
});

// Main Business Logic Class
class VideoPlayerNotifier extends ChangeNotifier {
  VideoPlayerController? controller;
  List<VideoModel> allVideos = [];
  int currentIndex = 0;

  bool isPlaying = true;
  bool isLoading = true;
  bool isLocked = false;
  double playbackSpeed = 1.0;
  Duration currentPosition = Duration.zero;
  Duration totalDuration = Duration.zero;

  bool showControls = true;
  Timer? _controlsTimer;

  double currentVolume = 0.5;
  double currentBrightness = 0.5;

  PanType currentPanType = PanType.none;
  Offset? dragStartPosition;
  Duration seekStartPosition = Duration.zero;
  int seekOffsetSeconds = 0;

  String? centerFeedbackText;
  IconData? centerFeedbackIcon;
  Timer? _feedbackTimer;

  final List<BoxFit> fitModes = [BoxFit.contain, BoxFit.cover, BoxFit.fill];
  int currentFitIndex = 0;

  Future<void> init(List<VideoModel> videos, int index) async {
    allVideos = videos;
    currentIndex = index;
    await _initVolumeAndBrightness();
    await _initializeVideo(allVideos[currentIndex]);
    startControlsTimer();
  }

  Future<void> _initVolumeAndBrightness() async {
    VolumeController().getVolume().then((vol) {
      currentVolume = vol;
      notifyListeners();
    });
    try {
      currentBrightness = await ScreenBrightness().current;
    } catch (e) {
      currentBrightness = 0.5;
    }
    notifyListeners();
  }

  Future<void> _initializeVideo(VideoModel video) async {
    isLoading = true;
    notifyListeners();

    controller = VideoPlayerController.file(File(video.filePath));
    await controller!.initialize();

    totalDuration = controller!.value.duration;
    currentPosition = Duration.zero;

    await controller!.setLooping(false);
    await controller!.setPlaybackSpeed(playbackSpeed);

    if (isPlaying) {
      await controller!.play();
    }

    controller!.addListener(_updatePosition);

    isLoading = false;
    notifyListeners();
  }

  void _updatePosition() {
    if (controller == null) return;
    final newPosition = controller!.value.position;
    // Notify listeners only when second changes to optimize UI rebuilds
    if (currentPosition.inSeconds != newPosition.inSeconds) {
      currentPosition = newPosition;
      notifyListeners();
    }
  }

  void startControlsTimer() {
    _controlsTimer?.cancel();
    _controlsTimer = Timer(const Duration(seconds: 3), () {
      if (showControls && isPlaying && currentPanType == PanType.none) {
        showControls = false;
        notifyListeners();
      }
    });
  }

  void toggleControls() {
    showControls = !showControls;
    if (showControls) startControlsTimer();
    notifyListeners();
  }

  void showFeedback(String text, IconData icon) {
    _feedbackTimer?.cancel();
    centerFeedbackText = text;
    centerFeedbackIcon = icon;
    notifyListeners();

    _feedbackTimer = Timer(const Duration(milliseconds: 1200), () {
      centerFeedbackText = null;
      centerFeedbackIcon = null;
      notifyListeners();
    });
  }

  void playPause() {
    if (controller == null) return;
    if (controller!.value.isPlaying) {
      controller!.pause();
      isPlaying = false;
      showControls = true;
      _controlsTimer?.cancel();
      showFeedback("Paused", Icons.pause);
    } else {
      controller!.play();
      isPlaying = true;
      startControlsTimer();
      showFeedback("Playing", Icons.play_arrow);
    }
    notifyListeners();
  }

  void seekTo(Duration position) {
    controller?.seekTo(position);
    showControls = true;
    startControlsTimer();
    notifyListeners();
  }

  void seekForward(int seconds) {
    final newPosition = currentPosition + Duration(seconds: seconds);
    seekTo(newPosition < totalDuration ? newPosition : totalDuration);
    showFeedback("+$seconds s", Icons.fast_forward);
  }

  void seekBackward(int seconds) {
    final newPosition = currentPosition - Duration(seconds: seconds);
    seekTo(newPosition > Duration.zero ? newPosition : Duration.zero);
    showFeedback("-$seconds s", Icons.fast_rewind);
  }

  void changePlaybackSpeed(double speed) {
    playbackSpeed = speed;
    controller?.setPlaybackSpeed(speed);
    showControls = true;
    startControlsTimer();
    showFeedback("${speed}x Speed", Icons.speed);
    notifyListeners();
  }

  void toggleAspectRatio() {
    currentFitIndex = (currentFitIndex + 1) % fitModes.length;
    String modeName = "Fit Screen";
    if (fitModes[currentFitIndex] == BoxFit.cover) modeName = "Crop";
    if (fitModes[currentFitIndex] == BoxFit.fill) modeName = "Stretch";

    showFeedback("Aspect Ratio: $modeName", Icons.aspect_ratio);
    showControls = true;
    startControlsTimer();
    notifyListeners();
  }

  void toggleLock() {
    isLocked = !isLocked;
    showControls = true;
    startControlsTimer();
    showFeedback(isLocked ? "Screen Locked" : "Screen Unlocked", isLocked ? Icons.lock : Icons.lock_open);
    notifyListeners();
  }

  void playNextVideo() {
    if (currentIndex + 1 < allVideos.length) {
      currentIndex++;
      controller?.removeListener(_updatePosition);
      controller?.dispose();
      _initializeVideo(allVideos[currentIndex]);
    } else {
      showFeedback("No more videos", Icons.error_outline);
    }
  }

  void playPreviousVideo() {
    if (currentIndex - 1 >= 0) {
      currentIndex--;
      controller?.removeListener(_updatePosition);
      controller?.dispose();
      _initializeVideo(allVideos[currentIndex]);
    } else {
      showFeedback("First video", Icons.error_outline);
    }
  }

  // --- Gesture Handling ---
  void handlePanStart(DragStartDetails details) {
    if (isLocked) return;
    dragStartPosition = details.localPosition;
    seekStartPosition = currentPosition;
    currentPanType = PanType.none;
    showControls = true;
    _controlsTimer?.cancel();
    notifyListeners();
  }

  void handlePanUpdate(DragUpdateDetails details, BoxConstraints constraints) {
    if (isLocked || dragStartPosition == null) return;

    final dx = details.localPosition.dx - dragStartPosition!.dx;
    final dy = details.localPosition.dy - dragStartPosition!.dy;

    if (currentPanType == PanType.none) {
      if (dx.abs() > 10 && dx.abs() > dy.abs()) {
        currentPanType = PanType.seek;
      } else if (dy.abs() > 10 && dy.abs() > dx.abs()) {
        currentPanType = dragStartPosition!.dx > constraints.maxWidth / 2 ? PanType.volume : PanType.brightness;
      }
    }

    if (currentPanType == PanType.volume) {
      double delta = -(details.delta.dy / (constraints.maxHeight * 0.8));
      double newVolume = (currentVolume + delta).clamp(0.0, 1.0);
      if (newVolume != currentVolume) {
        currentVolume = newVolume;
        VolumeController().setVolume(newVolume);
        showFeedback('Volume: ${(newVolume * 100).toInt()}%', Icons.volume_up);
      }
    }
    else if (currentPanType == PanType.brightness) {
      double delta = -(details.delta.dy / (constraints.maxHeight * 0.8));
      double newBrightness = (currentBrightness + delta).clamp(0.0, 1.0);
      if (newBrightness != currentBrightness) {
        currentBrightness = newBrightness;
        ScreenBrightness().setScreenBrightness(newBrightness);
        showFeedback('Brightness: ${(newBrightness * 100).toInt()}%', Icons.brightness_6);
      }
    }
    else if (currentPanType == PanType.seek) {
      seekOffsetSeconds = (dx * 0.15).toInt();
      final newPosition = seekStartPosition + Duration(seconds: seekOffsetSeconds);
      final clampedPosition = Duration(seconds: newPosition.inSeconds.clamp(0, totalDuration.inSeconds));

      String sign = seekOffsetSeconds >= 0 ? "+" : "";
      showFeedback('Seek: $sign$seekOffsetSeconds s\n${formatDuration(clampedPosition)} / ${formatDuration(totalDuration)}', Icons.screen_search_desktop_outlined);
    }
  }

  void handlePanEnd(DragEndDetails details) {
    if (currentPanType == PanType.seek) {
      final newPosition = seekStartPosition + Duration(seconds: seekOffsetSeconds);
      seekTo(Duration(seconds: newPosition.inSeconds.clamp(0, totalDuration.inSeconds)));
    }
    currentPanType = PanType.none;
    startControlsTimer();
    notifyListeners();
  }

  void handleDoubleTap(TapDownDetails details, BoxConstraints constraints) {
    if (isLocked) return;
    if (details.localPosition.dx < constraints.maxWidth / 2) {
      seekBackward(10);
    } else {
      seekForward(10);
    }
  }

  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return duration.inHours > 0 ? '$hours:$minutes:$seconds' : '$minutes:$seconds';
  }

  @override
  void dispose()  {
    controller?.pause();
    controller?.removeListener(_updatePosition);
    controller?.dispose();
    _controlsTimer?.cancel();
    _feedbackTimer?.cancel();
    super.dispose();
  }
}