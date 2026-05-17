import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';
import '../../../../core/app_ui/app_ui.dart';
import '../../../../core/models/src/video_model/video_model.dart';
import '../video_player_notifier.dart';

class VideoPlayerScreen extends ConsumerStatefulWidget {
  final List<VideoModel> allVideos;
  final int initialIndex;

  const VideoPlayerScreen({
    super.key,
    required this.allVideos,
    required this.initialIndex,
  });

  @override
  ConsumerState<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends ConsumerState<VideoPlayerScreen> {
  late final VideoPlayerArgs args;

  @override
  void initState() {
    super.initState();
    args = VideoPlayerArgs(allVideos: widget.allVideos, initialIndex: widget.initialIndex);
  }

  // Yahan se player argument hata diya kyunki iska use nahi hai
  void _exitFullscreen() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  }

  // Yahan bhi player argument hata diya. Hum ref.read() ka use karenge
  Future<void> _handleBackNavigation() async {
    // 1. ref.read se provider ko bina UI rebuild kiye access karein aur pause karein
    final player = ref.read(videoPlayerProvider(args));
    player.controller?.pause();

    // 2. System UI aur Orientation theek karein (Portrait)
    _exitFullscreen();

    // 3. Native Android ko apna UI change karne ke liye thoda extra time dein
    await Future.delayed(const Duration(milliseconds: 300));

    // 4. Phir aaram se screen Pop karein
    if (mounted) Navigator.pop(context);
  }

  void _toggleFullscreen(VideoPlayerNotifier player) {
    if (MediaQuery.of(context).orientation == Orientation.portrait) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
      player.showFeedback("Fullscreen", Icons.fullscreen);
    } else {
      _exitFullscreen();
      player.showFeedback("Portrait", Icons.fullscreen_exit);
    }
  }

  @override
  void dispose() {
    _exitFullscreen(); // Ab yahan error nahi aayegi
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final orientation = MediaQuery.of(context).orientation;
    // Watch the Riverpod Provider for UI updates
    final player = ref.watch(videoPlayerProvider(args));

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        await _handleBackNavigation(); // Ab bina error ke call hoga
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: LayoutBuilder(
          builder: (context, constraints) {
            return GestureDetector(
              onTap: player.toggleControls,
              onDoubleTapDown: (details) => player.handleDoubleTap(details, constraints),
              onPanStart: player.handlePanStart,
              onPanUpdate: (details) => player.handlePanUpdate(details, constraints),
              onPanEnd: player.handlePanEnd,
              behavior: HitTestBehavior.opaque,
              child: Stack(
                children: [
                  // Video Player Layer
                  Center(
                    child: player.isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : (player.controller != null && player.controller!.value.isInitialized)
                        ? SizedBox.expand(
                      child: FittedBox(
                        fit: player.fitModes[player.currentFitIndex],
                        child: SizedBox(
                          width: player.controller!.value.size.width,
                          height: player.controller!.value.size.height,
                          child: VideoPlayer(player.controller!),
                        ),
                      ),
                    )
                        : const SizedBox.shrink(),
                  ),

                  // Center VLC-style Feedback
                  if (player.centerFeedbackText != null)
                    Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (player.centerFeedbackIcon != null)
                              Icon(player.centerFeedbackIcon, color: Colors.white, size: 48),
                            const SizedBox(height: 8),
                            Text(
                              player.centerFeedbackText!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // Top Bar
                  AnimatedOpacity(
                    opacity: player.showControls && player.currentPanType == PanType.none ? 1.0 : 0.0,
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
                                onPressed: _handleBackNavigation, // Direct reference ab theek kaam karega
                              ),
                              Expanded(
                                child: Text(
                                  player.allVideos.isNotEmpty ? player.allVideos[player.currentIndex].title : "",
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.aspect_ratio, color: Colors.white),
                                onPressed: player.toggleAspectRatio,
                              ),
                              IconButton(
                                icon: Icon(player.isLocked ? Icons.lock : Icons.lock_open, color: Colors.white),
                                onPressed: player.toggleLock,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Center Play/Pause button
                  if (!player.isPlaying && !player.isLoading && player.showControls && player.currentPanType == PanType.none && player.centerFeedbackText == null)
                    Center(
                      child: GestureDetector(
                        onTap: player.playPause,
                        child: Container(
                          decoration: BoxDecoration(color: Colors.black.withOpacity(0.6), shape: BoxShape.circle),
                          child: const Icon(Icons.play_arrow, size: 80, color: Colors.white),
                        ),
                      ),
                    ),

                  // Bottom Controls
                  AnimatedOpacity(
                    opacity: player.showControls && player.currentPanType == PanType.none ? 1.0 : 0.0,
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
                            if (player.controller != null && player.controller!.value.isInitialized) ...[
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(player.formatDuration(player.currentPosition), style: const TextStyle(color: Colors.white, fontSize: 12)),
                                  Text(player.formatDuration(player.totalDuration), style: const TextStyle(color: Colors.white, fontSize: 12)),
                                ],
                              ),
                              SliderTheme(
                                data: SliderThemeData(
                                  trackHeight: 3,
                                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                                  activeTrackColor: Colors.deepPurple,
                                  inactiveTrackColor: Colors.grey[800],
                                  thumbColor: Colors.deepPurple,
                                ),
                                child: Slider(
                                  value: player.currentPosition.inSeconds.toDouble().clamp(0.0, player.totalDuration.inSeconds.toDouble()),
                                  max: player.totalDuration.inSeconds.toDouble() > 0 ? player.totalDuration.inSeconds.toDouble() : 1.0,
                                  onChanged: (value) => player.seekTo(Duration(seconds: value.toInt())),
                                ),
                              ),
                              const SizedBox(height: 12),
                            ],

                            // Control buttons row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                PopupMenuButton<double>(
                                  onSelected: player.changePlaybackSpeed,
                                  color: Colors.grey[900],
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(color: Colors.grey[800], borderRadius: BorderRadius.circular(20)),
                                    child: Text('${player.playbackSpeed}x', style: const TextStyle(color: Colors.white)),
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
                                  onPressed: player.playPreviousVideo,
                                ),
                                Container(
                                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
                                  child: IconButton(
                                    icon: Icon(player.isPlaying ? Icons.pause : Icons.play_arrow, size: 48, color: Colors.white),
                                    onPressed: player.playPause,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.skip_next, size: 36, color: Colors.white),
                                  onPressed: player.playNextVideo,
                                ),
                                IconButton(
                                  icon: Icon(orientation == Orientation.portrait ? Icons.fullscreen : Icons.fullscreen_exit, color: Colors.white),
                                  onPressed: () => _toggleFullscreen(player),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Lock icon
                  if (player.isLocked && player.showControls && player.centerFeedbackText == null)
                    const Center(child: Icon(Icons.lock, size: 48, color: Colors.white60)),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}