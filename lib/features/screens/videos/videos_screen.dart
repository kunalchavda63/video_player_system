import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_manager/photo_manager.dart';
import '../../../core/app_ui/app_ui.dart';
import '../../../core/utilities/utils.dart';
import '../../../core/models/src/video_model/video_model.dart';
import '../../../core/provider/video_provider.dart';
import 'help/video_card.dart';
import 'help/video_player_screen.dart';

class VideoGalleryScreen extends ConsumerStatefulWidget {
  const VideoGalleryScreen({super.key});

  @override
  ConsumerState<VideoGalleryScreen> createState() => _VideoGalleryScreenState();
}

class _VideoGalleryScreenState extends ConsumerState<VideoGalleryScreen> {

  @override
  void initState() {
    super.initState();
    // ✅ Screen open hote hi permission request karo
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _requestDirectPermission();
    });
  }

  Future<void> _requestDirectPermission() async {
    logger.d("Requesting permission...");

    // ✅ Direct permission request - popup ayega
    final permission = await PhotoManager.requestPermissionExtend();
    logger.d("Permission status: ${permission.isAuth}");

    if (permission.isAuth) {
      // ✅ Permission mil gayi, videos load karo
      ref.refresh(videoListProvider);
    } else if (permission.isLimited) {
      // ✅ Limited permission
      ref.refresh(videoListProvider);
    } else {
      // ❌ Permission deny kar di
      logger.d("Permission denied");
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final videosAsync = ref.watch(videoListProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          'All Videos',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              _requestDirectPermission();
            },
          ),
        ],
      ),
      body: FutureBuilder<PermissionState>(
        future: PhotoManager.requestPermissionExtend(),
        builder: (context, snapshot) {
          // ✅ Loading state
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.deepPurple),
                  SizedBox(height: 20),
                  Text(
                    'Requesting permission...',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            );
          }

          // ✅ Permission not granted
          if (!snapshot.hasData ||
              (!snapshot.data!.isAuth && !snapshot.data!.isLimited)) {
            return buildPermissionDeniedView();
          }

          // ✅ Permission granted, show videos
          return videosAsync.when(
            data: (videos) {
              if (videos.isEmpty) {
                return buildNoVideosView();
              }
              return buildVideoGridView(videos);
            },
            error: (error, stack) {
              logger.e("Error: $error");
              return buildErrorView(error);
            },
            loading: () => const Center(
              child: CircularProgressIndicator(color: Colors.deepPurple),
            ),
          );
        },
      ),
    );
  }

  Widget buildPermissionDeniedView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.video_library, size: 80, color: Colors.grey),
          const SizedBox(height: 20),
          const Text(
            'Permission Required',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 10),
          const Text(
            'This app needs access to your videos',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () async {
              logger.d("Grant Permission clicked");

              // ✅ Direct permission request - NO SETTINGS
              final result = await PhotoManager.requestPermissionExtend();
              logger.d("New permission result: ${result.isAuth}");

              if (result.isAuth || result.isLimited) {
                // ✅ Permission mil gayi
                ref.refresh(videoListProvider);
                setState(() {});
              } else {
                // ❌ Phir se deny kar di
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Permission is required to view videos'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Grant Permission',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
          const SizedBox(height: 20),
          TextButton(
            onPressed: () {
              _requestDirectPermission();
            },
            child: Text(
              'Retry',
              style: TextStyle(color: Colors.grey.shade400),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildNoVideosView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.video_library, size: 80, color: Colors.grey),
          const SizedBox(height: 20),
          const Text(
            'No Videos Found',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 10),
          Text(
            'No videos found on your device',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              _requestDirectPermission();
            },
            child: const Text('Refresh'),
          ),
        ],
      ),
    );
  }

  Widget buildVideoGridView(List<VideoModel> videos) {
    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.7,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: videos.length,
      itemBuilder: (context, index) {
        return VideoCard(
          video: videos[index],
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => VideoPlayerScreen(
                  video: videos[index],
                  allVideos: videos,
                  initialIndex: index,
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget buildErrorView(Object error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 80, color: Colors.red),
          const SizedBox(height: 20),
          const Text(
            'Error Loading Videos',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 10),
          Text(
            error.toString(),
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () {
              _requestDirectPermission();
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}